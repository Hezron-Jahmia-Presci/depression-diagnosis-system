package controller

import (
	interfaces "depression-diagnosis-system/api/interface"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"encoding/json"
)

type DiagnosisController struct{}

func NewDiagnosisController() interfaces.DiagnosisInterface {
	return &DiagnosisController{}
}


func (dc *DiagnosisController) CreateDiagnosis(sessionID uint) (*model.Diagnosis, error) {
	var phq9Responses []model.Phq9Response
	if err := database.DB.Where("session_id = ?", sessionID).Find(&phq9Responses).Error; err != nil {
		return nil, err
	}


	phq9Score := 0
	for _, response := range phq9Responses {
		var responseStructs []model.Phq9ResponseStruct
		if err := json.Unmarshal(response.Responses, &responseStructs); err != nil {
			return nil, err
		}

		for _, resp := range responseStructs {
			phq9Score += resp.Response
		}
	}

	calculatedSeverity := util.DetermineSeverity(phq9Score)

	diagnosis := model.Diagnosis{
		SessionID: sessionID,
		Phq9Score: phq9Score,
		Severity:  calculatedSeverity,
	}

	if err := database.DB.Create(&diagnosis).Error; err != nil {
		return nil, err
	}

	return &diagnosis, nil
}

func (dc *DiagnosisController) GetDiagnosisBySessionID(sessionID uint) (*model.Diagnosis, error) {
	var diagnosis model.Diagnosis
	if err := database.DB.Where("session_id = ?", sessionID).First(&diagnosis).Error; err != nil {
		return nil, err
	}
	return &diagnosis, nil
}
