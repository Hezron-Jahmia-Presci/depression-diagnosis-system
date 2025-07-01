package interfaces

import (
	"depression-diagnosis-system/database/model"
	"time"
)

type SessionInterface interface {
	CreateSession(session *model.Session) (*model.Session, error)
	GetAllSessions() ([]model.Session, error)
	GetSessionsByPsychiatrist(psychiatristID uint) ([]model.Session, error)
	GetSessionByID(id uint) (*model.Session, error)
	UpdateSessionStatus(id uint, status string) error
	CreateFollowUpSession(originalSessionID uint, date time.Time) (*model.Session, error)
}
