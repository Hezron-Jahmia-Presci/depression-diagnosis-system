package interfaces

import "depression-diagnosis-system/database/model"

type SessionInterface interface {
	CreateSession(s *model.Session) (*model.Session, error)
	GetSessionByID(id uint) (*model.Session, error)
	GetAllSessions() ([]model.Session, error)
	UpdateSession(id uint, updated *model.Session) (*model.Session, error)
	DeleteSession(id uint) error

	// Custom queries
	GetSessionsByPatient(patientID uint) ([]model.Session, error)
	GetSessionsByHealthWorker(healthWorkerID uint) ([]model.Session, error)
	GetSessionByCode(code string) (*model.Session, error)
	UpdateSessionStatus(id uint, status string) error

	SearchSessions(queryParams map[string]string) ([]model.Session, error)
}
