package controller

import (
	interfaces "depression-diagnosis-system/api/interface"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
)


type SessionSummaryController struct {}

func NewSessionSummaryController() interfaces.SessionSummary {
	return &SessionSummaryController {}
}

func (ssc *SessionSummaryController) CreateSummaryForSession(sessionID uint, notes string) (*model.SessionSummary, error) {
	sessionSummary := model.SessionSummary{
		SessionID: sessionID,
		Notes: notes,
	}

	if err := database.DB.Create(&sessionSummary).Error; err != nil {
		return nil, err
	}
	return &sessionSummary, nil
}

func (ssc *SessionSummaryController) GetSummaryForSession(sessionID uint) (*model.SessionSummary, error) {
	var sessionSummary model.SessionSummary
	err := database.DB.Preload("Session").First(&sessionSummary, sessionID).Error

	if err != nil {
		return nil, err
	}

	return &sessionSummary, nil
}