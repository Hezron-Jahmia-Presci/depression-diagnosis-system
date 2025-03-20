package interfaces

import "depression-diagnosis-system/database/model"

type SessionSummary interface {
	CreateSummaryForSession(sessionID uint, notes string) (*model.SessionSummary, error)
	GetSummaryForSession(sessionID uint) (*model.SessionSummary, error) 	
}