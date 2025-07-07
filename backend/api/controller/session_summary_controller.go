package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"
)

type SessionSummaryController struct{}

func NewSessionSummaryController() interfaces.SessionSummaryInterface {
	return &SessionSummaryController{}
}

// CreateSummary creates a session summary entry
func (c *SessionSummaryController) CreateSummary(s *model.SessionSummary) (*model.SessionSummary, error) {
	// Check if session exists
	var session model.Session
	if err := database.DB.First(&session, s.SessionID).Error; err != nil {
		return nil, errors.New("session not found")
	}

	// Ensure notes are not empty
	if s.Notes == "" {
		return nil, errors.New("summary notes cannot be empty")
	}

	if err := database.DB.Create(s).Error; err != nil {
		return nil, err
	}
	return s, nil
}

// GetSummaryBySessionID retrieves the summary for a given session
func (c *SessionSummaryController) GetSummaryBySessionID(sessionID uint) (*model.SessionSummary, error) {
	var summary model.SessionSummary
	if err := database.DB.Preload("Session").Where("session_id = ?", sessionID).First(&summary).Error; err != nil {
		return nil, err
	}
	return &summary, nil
}

// UpdateSummary updates notes for a summary
func (c *SessionSummaryController) UpdateSummary(id uint, updated *model.SessionSummary) (*model.SessionSummary, error) {
	var summary model.SessionSummary
	if err := database.DB.First(&summary, id).Error; err != nil {
		return nil, err
	}

	if updated.Notes != "" {
		summary.Notes = updated.Notes
	}

	if err := database.DB.Save(&summary).Error; err != nil {
		return nil, err
	}
	return &summary, nil
}

// DeleteSummary deletes the session summary by ID
func (c *SessionSummaryController) DeleteSummary(id uint) error {
	var summary model.SessionSummary
	if err := database.DB.First(&summary, id).Error; err != nil {
		return err
	}
	return database.DB.Delete(&summary).Error
}
