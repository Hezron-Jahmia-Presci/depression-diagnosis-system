package interfaces

import "depression-diagnosis-system/database/model"

type SessionSummaryInterface interface {
	CreateSummary(s *model.SessionSummary) (*model.SessionSummary, error)
	GetSummaryBySessionID(sessionID uint) (*model.SessionSummary, error)
	UpdateSummary(id uint, updated *model.SessionSummary) (*model.SessionSummary, error)
	DeleteSummary(id uint) error
}
