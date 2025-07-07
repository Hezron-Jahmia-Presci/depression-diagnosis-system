package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"
)

type DiagnosisController struct{}

func NewDiagnosisController() interfaces.DiagnosisInterface {
	return &DiagnosisController{}
}

// CreateDiagnosis creates a new diagnosis linked to a session
func (c *DiagnosisController) CreateDiagnosis(diagnosis *model.Diagnosis) (*model.Diagnosis, error) {
	// Check if session exists
	var session model.Session
	if err := database.DB.First(&session, diagnosis.SessionID).Error; err != nil {
		return nil, errors.New("session not found")
	}

	// Validate severity (optional, add your own validation logic if needed)
	if diagnosis.Severity == "" {
		return nil, errors.New("severity cannot be empty")
	}

	if err := database.DB.Create(diagnosis).Error; err != nil {
		return nil, err
	}
	return diagnosis, nil
}

// GetDiagnosisByID fetches a diagnosis by its ID
func (c *DiagnosisController) GetDiagnosisByID(id uint) (*model.Diagnosis, error) {
	var diagnosis model.Diagnosis
	if err := database.DB.Preload("Session").First(&diagnosis, id).Error; err != nil {
		return nil, err
	}
	return &diagnosis, nil
}

// GetDiagnosisBySessionID fetches diagnosis for a given session
func (c *DiagnosisController) GetDiagnosisBySessionID(sessionID uint) (*model.Diagnosis, error) {
	var diagnosis model.Diagnosis
	if err := database.DB.Preload("Session").Where("session_id = ?", sessionID).First(&diagnosis).Error; err != nil {
		return nil, err
	}
	return &diagnosis, nil
}

// UpdateDiagnosis updates an existing diagnosis
func (c *DiagnosisController) UpdateDiagnosis(id uint, updated *model.Diagnosis) (*model.Diagnosis, error) {
	var diagnosis model.Diagnosis
	if err := database.DB.First(&diagnosis, id).Error; err != nil {
		return nil, err
	}

	if updated.Phq9Score != 0 {
		diagnosis.Phq9Score = updated.Phq9Score
	}
	if updated.Severity != "" {
		diagnosis.Severity = updated.Severity
	}

	if err := database.DB.Save(&diagnosis).Error; err != nil {
		return nil, err
	}
	return &diagnosis, nil
}

// DeleteDiagnosis deletes diagnosis by ID
func (c *DiagnosisController) DeleteDiagnosis(id uint) error {
	var diagnosis model.Diagnosis
	if err := database.DB.First(&diagnosis, id).Error; err != nil {
		return err
	}
	return database.DB.Delete(&diagnosis).Error
}
