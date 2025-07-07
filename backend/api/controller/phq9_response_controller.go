package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"encoding/json"
	"errors"
	"fmt"

	"gorm.io/gorm"
)

type Phq9ResponseController struct{}

func NewPhq9ResponseController() interfaces.Phq9ResponseInterface {
	return &Phq9ResponseController{}
}

func (c *Phq9ResponseController) CreateResponse(sessionID uint, resp []model.Phq9ResponseStruct) (*model.Phq9Response, error) {
	if sessionID == 0 || len(resp) == 0 {
		return nil, errors.New("sessionID and responses are required")
	}
	//🔒 Prevent duplicate response submissions
	var existing model.Phq9Response
	if err := database.DB.Where("session_id = ?", sessionID).First(&existing).Error; err == nil {
		return nil, fmt.Errorf("PHQ-9 responses already recorded for session %d", sessionID)
	}

	// Validate response content
	for _, r := range resp {
		if r.QuestionID == 0 {
			return nil, fmt.Errorf("invalid response data: missing question ID")
		}
	}

	// Encode JSON and create new response
	responseJSON, err := json.Marshal(resp)
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

func (c *Phq9ResponseController) GetResponseBySessionID(sessionID uint) ([]model.Phq9ResponseStruct, error) {
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

func (c *Phq9ResponseController) UpdateResponse(id uint, updated *model.Phq9Response) (*model.Phq9Response, error) {
	var resp model.Phq9Response
	if err := database.DB.First(&resp, id).Error; err != nil {
		return nil, err
	}

	if updated.Responses != nil {
		resp.Responses = updated.Responses
	}
	if updated.SessionID != 0 {
		resp.SessionID = updated.SessionID
	}

	if err := database.DB.Save(&resp).Error; err != nil {
		return nil, err
	}
	return &resp, nil
}

func (c *Phq9ResponseController) DeleteResponse(id uint) error {
	var resp model.Phq9Response
	if err := database.DB.First(&resp, id).Error; err != nil {
		return err
	}
	return database.DB.Delete(&resp).Error
}
