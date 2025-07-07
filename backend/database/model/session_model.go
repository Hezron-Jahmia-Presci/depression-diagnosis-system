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
	SessionCode             string         `gorm:"not null;uniqueIndex" json:"session_code"`  // e.g. DEP-S-9832
	HealthWorkerID          uint           `gorm:"not null;index" json:"health_worker_id"`    // Admitting health worker
	HealthWorker            HealthWorker   `gorm:"foreignKey:HealthWorkerID"`
	PatientID               uint           `gorm:"not null;index" json:"patient_id"`
	Patient                 Patient        `gorm:"foreignKey:PatientID"`
	Date                    time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP" json:"date"`
	Status                  string         `gorm:"not null;check:status IN ('ongoing', 'completed', 'cancelled')" json:"status"`

	// NEW fields
	PatientStateAtRegistration string      `gorm:"type:text" json:"patient_state"`
	PreviousSessionID          *uint       `json:"previous_session_id,omitempty"` // FK to another session
	PreviousSession            *Session    `gorm:"foreignKey:PreviousSessionID"`
	SessionIssue               string      `gorm:"type:text" json:"session_issue"`     // why patient came in
	Description                string      `gorm:"type:text" json:"description"`       // summary of what was discussed or done
	NextSessionDate            *time.Time  `json:"next_session_date"`                  // appointment scheduler
	CurrentPrescription        string      `gorm:"type:text" json:"current_prescription"`

	// Existing related models
	Diagnosis      Diagnosis      `gorm:"foreignKey:SessionID;constraint:OnDelete:CASCADE"`
	SessionSummary SessionSummary `gorm:"foreignKey:SessionID;constraint:OnDelete:CASCADE"`
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
