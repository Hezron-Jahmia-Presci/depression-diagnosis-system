package controller

import (
	"encoding/json"
	"errors"
	"fmt"

	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"

	"gorm.io/gorm"
)

type Phq9Controller struct{}

func NewPhq9Controller() interfaces.Phq9Interface {
	return &Phq9Controller{}
}

// Question management

func (pqc *Phq9Controller) CreateQuestion(question *model.Phq9Question) (*model.Phq9Question, error) {
	if err := database.DB.Create(question).Error; err != nil {
		return nil, err
	}
	return question, nil
}

func (pqc *Phq9Controller) GetQuestionByID(id uint) (*model.Phq9Question, error) {
	var question model.Phq9Question
	if err := database.DB.First(&question, id).Error; err != nil {
		return nil, err
	}
	return &question, nil
}

func (pqc *Phq9Controller) GetAllQuestions() ([]model.Phq9Question, error) {
	var questions []model.Phq9Question
	if err := database.DB.Find(&questions).Error; err != nil {
		return nil, err
	}
	return questions, nil
}

// Response management

func (pqc *Phq9Controller) RecordResponses(sessionID uint, responses []model.Phq9ResponseStruct) (*model.Phq9Response, error) {
	if sessionID == 0 || len(responses) == 0 {
		return nil, errors.New("sessionID and responses are required")
	}

	// 🔒 Prevent duplicate response submissions
	var existing model.Phq9Response
	if err := database.DB.Where("session_id = ?", sessionID).First(&existing).Error; err == nil {
		return nil, fmt.Errorf("PHQ-9 responses already recorded for session %d", sessionID)
	}

	// Validate response content
	for _, r := range responses {
		if r.QuestionID == 0 {
			return nil, fmt.Errorf("invalid response data: missing question ID")
		}
	}

	// Encode JSON and create new response
	responseJSON, err := json.Marshal(responses)
	if err != nil {
		return nil, err
	}

	response := &model.Phq9Response{
		SessionID: sessionID,
		Responses: responseJSON,
	}

	if err := database.DB.Create(response).Error; err != nil {
		return nil, err
	}

	return response, nil
}

func (pqc *Phq9Controller) GetResponses(sessionID uint) ([]model.Phq9ResponseStruct, error) {
	var response model.Phq9Response
	if err := database.DB.Where("session_id = ?", sessionID).First(&response).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return []model.Phq9ResponseStruct{}, nil
		}
		return nil, err
	}
	

	var responseStructs []model.Phq9ResponseStruct
	if err := json.Unmarshal(response.Responses, &responseStructs); err != nil {
		return nil, err
	}

	return responseStructs, nil
}

func (pqc *Phq9Controller) GetResponseSummary(sessionID uint) (*model.Phq9Response, error) {
	var response model.Phq9Response
	if err := database.DB.Where("session_id = ?", sessionID).First(&response).Error; err != nil {
		return nil, err
	}
	return &response, nil
}
