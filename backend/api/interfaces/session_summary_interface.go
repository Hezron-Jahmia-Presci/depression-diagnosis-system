package interfaces

import "depression-diagnosis-system/database/model"

type SessionSummaryInterface interface {
	CreateSessionSummary(summary *model.SessionSummary) (*model.SessionSummary, error)
	GetSessionSummaryBySessionID(sessionID uint) (*model.SessionSummary, error)
}
