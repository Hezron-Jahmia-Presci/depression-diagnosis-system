package model

import (
	"errors"
	"time"

	"gorm.io/gorm"
)
const (
	SessionOngoing   = "ongoing"
	SessionCompleted = "completed"
	SessionCancelled = "cancelled"
)

type Session struct {
	gorm.Model
	PsychiatristID  uint           `gorm:"not null;index" json:"psychiatrist_id"`
	Psychiatrist    Psychiatrist   `gorm:"foreignKey:PsychiatristID"`
	PatientID       uint           `gorm:"not null;index" json:"patient_id"`
	Patient         Patient        `gorm:"foreignKey:PatientID"`
	Date            time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP" json:"date"`
	Status          string         `gorm:"not null;check:status IN ('ongoing', 'completed', 'cancelled')" json:"status"`
	ParentSessionID *uint          `json:"parentSessionId,omitempty"`
	Diagnosis		Diagnosis      `gorm:"foreignKey:SessionID;constraint:OnDelete:CASCADE"`
	SessionSummary	SessionSummary `gorm:"foreignKey:SessionID;constraint:OnDelete:CASCADE"`
}

func (s *Session) ValidateStatus() error {
	validStatuses := map[string]bool{
		SessionOngoing:   true,
		SessionCompleted: true,
		SessionCancelled: true,
	}
	if !validStatuses[s.Status] {
		return errors.New("invalid status: must be 'ongoing', 'completed', or 'cancelled'")
	}
	return nil
}

func (s *Session) BeforeSave(tx *gorm.DB) error {
	if err := s.ValidateStatus(); err != nil {
		return err
	}
	return nil
}
