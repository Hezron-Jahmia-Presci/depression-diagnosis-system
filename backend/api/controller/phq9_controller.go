package controller

import (
	interfaces "depression-diagnosis-system/api/interface"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"encoding/json"
	"fmt"
)

type Phq9Controller struct{}

func NewPhq9Controller() interfaces.Phq9Interface {
	return &Phq9Controller{}
}

func (pqc *Phq9Controller) CreateQuestion(question *model.Phq9Question) (*model.Phq9Question, error) {
	if err := database.DB.Create(question).Error; err != nil {
		return nil, err
	}
	return question, nil
}

func (pqc *Phq9Controller) GetAllQuestions() ([]model.Phq9Question, error) {
	var questions []model.Phq9Question
	if err := database.DB.Find(&questions).Error; err != nil {
		return nil, err
	}
	return questions, nil
}

func (pqc *Phq9Controller) GetQuestionByID(questionID uint) (*model.Phq9Question, error) {
	var question model.Phq9Question
	if err := database.DB.Where("id = ?", questionID).Find(&question).Error; err != nil {
		return nil, err
	}
	return &question, nil
}

func (pqc *Phq9Controller) GetResponsesBySession(sessionID uint) (*model.Phq9Response, error) {
	var response model.Phq9Response
	if err := database.DB.Where("session_id = ?", sessionID).First(&response).Error; err != nil {
		return nil, err
	}
	return &response, nil
}

func (pqc *Phq9Controller) RecordResponsesForSession(sessionID uint, responses []model.Phq9ResponseStruct) (*model.Phq9Response, error) {
	for _, response := range responses {
		if response.QuestionID == 0 || response.Response == 0 {
			return nil, fmt.Errorf("invalid response data: missing question_id or response")
		}
	}

	responsesJSON, err := json.Marshal(responses)
	if err != nil {
		return nil, err
	}

	response := &model.Phq9Response{
		SessionID: sessionID,
		Responses: responsesJSON,
	}

	if err := database.DB.Create(response).Error; err != nil {
		return nil, err
	}

	return response, nil
}

func (pqc *Phq9Controller) GetResponsesForSession(sessionID uint) ([]model.Phq9ResponseStruct, error) {
	var response model.Phq9Response
	if err := database.DB.Where("session_id = ?", sessionID).First(&response).Error; err != nil {
		return nil, err
	}

	var responses []model.Phq9ResponseStruct
	err := json.Unmarshal(response.Responses, &responses)
	if err != nil {
		return nil, err
	}

	return responses, nil
}
