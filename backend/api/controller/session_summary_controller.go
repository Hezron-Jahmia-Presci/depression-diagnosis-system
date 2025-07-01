package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"

	"gorm.io/gorm"
)

type SessionSummaryController struct{}

func NewSessionSummaryController() interfaces.SessionSummaryInterface {
	return &SessionSummaryController{}
}

func (ssc *SessionSummaryController) CreateSessionSummary(summary *model.SessionSummary) (*model.SessionSummary, error) {
	if summary.SessionID == 0 || summary.Notes == "" {
		return nil, errors.New("session ID and notes are required")
	}

	if err := database.DB.Create(summary).Error; err != nil {
		return nil, err
	}
	return summary, nil
}

func (ssc *SessionSummaryController) GetSessionSummaryBySessionID(sessionID uint) (*model.SessionSummary, error) {
	var summary model.SessionSummary
	if err := database.DB.Preload("Session").Where("session_id = ?", sessionID).First(&summary).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	
	return &summary, nil
}
