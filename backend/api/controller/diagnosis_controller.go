package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"encoding/json"
	"errors"

	"gorm.io/gorm"
)

type DiagnosisController struct{}

func NewDiagnosisController() interfaces.DiagnosisInterface {
	return &DiagnosisController{}
}

func (dc *DiagnosisController) CreateDiagnosis(diagnosis *model.Diagnosis) (*model.Diagnosis, error) {
	if diagnosis.SessionID == 0 {
		return nil, errors.New("session ID is required")
	}

	var phq9Responses []model.Phq9Response
	if err := database.DB.Where("session_id = ?", diagnosis.SessionID).Find(&phq9Responses).Error; err != nil {
		return nil, err
	}

	totalScore := 0
	for _, response := range phq9Responses {
		var responseStructs []model.Phq9ResponseStruct
		if err := json.Unmarshal(response.Responses, &responseStructs); err != nil {
			return nil, err
		}

		for _, r := range responseStructs {
			totalScore += r.Response
		}
	}

	diagnosis.Phq9Score = totalScore
	diagnosis.Severity = util.DetermineSeverity(totalScore)

	if err := database.DB.Create(diagnosis).Error; err != nil {
		return nil, err
	}

	return diagnosis, nil
}

func (dc *DiagnosisController) GetDiagnosisBySessionID(sessionID uint) (*model.Diagnosis, error) {
	var diagnosis model.Diagnosis
	if err := database.DB.Where("session_id = ?", sessionID).First(&diagnosis).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	
	return &diagnosis, nil
}
