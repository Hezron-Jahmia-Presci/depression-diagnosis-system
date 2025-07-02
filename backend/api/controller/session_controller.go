package controller

import (
	"errors"
	"time"

	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
)

type SessionController struct{}

func NewSessionController() interfaces.SessionInterface {
	return &SessionController{}
}

func (sc *SessionController) CreateSession(session *model.Session) (*model.Session, error) {
	if session.PsychiatristID == 0 || session.PatientID == 0 || session.Date.IsZero() {
		return nil, errors.New("invalid session data: psychiatristID, patientID, and date are required")
	}

	session.Status = model.SessionOngoing // Set default status
	if err := database.DB.Create(session).Error; err != nil {
		return nil, err
	}

	return session, nil
}

func (sc *SessionController) CreateFollowUpSession(originalSessionID uint, date time.Time) (*model.Session, error) {
	var original model.Session
	if err := database.DB.First(&original, originalSessionID).Error; err != nil {
		return nil, errors.New("original session not found")
	}

	followUp := &model.Session{
		PsychiatristID:  original.PsychiatristID,
		PatientID:       original.PatientID,
		Date:            date,
		Status:          model.SessionOngoing,
		ParentSessionID: &original.ID,
	}

	if err := database.DB.Create(followUp).Error; err != nil {
		return nil, err
	}

	return followUp, nil
}

func (sc *SessionController) UpdateSessionStatus(id uint, status string) error {
	var session model.Session
	if err := database.DB.First(&session, id).Error; err != nil {
		return errors.New("session not found")
	}

	valid := map[string]bool{
		model.SessionOngoing:   true,
		model.SessionCompleted: true,
		model.SessionCancelled: true,
	}
	if !valid[status] {
		return errors.New("invalid session status")
	}

	session.Status = status
	return database.DB.Save(&session).Error
}

func (sc *SessionController) GetAllSessions() ([]model.Session, error) {
	var sessions []model.Session
	if err := database.DB.Find(&sessions).Error; err != nil {
		return nil, err
	}
	return sessions, nil
}

func (sc *SessionController) GetSessionsByPsychiatrist(psychiatristID uint) ([]model.Session, error) {
	var sessions []model.Session
	if err := database.DB.Where("psychiatrist_id = ?", psychiatristID).Find(&sessions).Error; err != nil {
		return nil, err
	}
	return sessions, nil
}

func (sc *SessionController) GetSessionByID(id uint) (*model.Session, error) {
	var session model.Session
	if err := database.DB.Preload("Psychiatrist").
		Preload("Patient").
		Preload("Diagnosis").
		First(&session, id).Error; err != nil {
		return nil, err
	}
	return &session, nil
}
