package interfaces

import (
	"depression-diagnosis-system/database/model"
	"time"
)

type SessionInterface interface {
	CreateSession(psychiatristID, patientID uint, date time.Time) (*model.Session, error)
	GetSessionsByPsychiatrist(psychiatristID uint) ([]model.Session, error)
	GetAllSessions() ([]model.Session, error)
	UpdateSessionStatus(sessionID uint, status string) error
	GetSessionByID(sessionID uint) (*model.Session, error)
	CreateFollowUpSession(originalSessionID uint, date time.Time) (*model.Session, error)
}
