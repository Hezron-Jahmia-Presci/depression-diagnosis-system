package controller

import (
	interfaces "depression-diagnosis-system/api/interface"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"
	"time"
)

type SessionController struct{}

func NewSessionController() interfaces.SessionInterface {
	return &SessionController{}
}

func (sc *SessionController) CreateSession(psychiatristID, patientID uint, date time.Time) (*model.Session, error) {
	session := model.Session{
		PsychiatristID: psychiatristID,
		PatientID:      patientID,
		Date:           date,
		Status:         model.SessionOngoing, 
	}

	if err := database.DB.Create(&session).Error; err != nil {
		return nil, err
	}

	return &session, nil
}

func (sc *SessionController) CreateFollowUpSession(originalSessionID uint, date time.Time) (*model.Session, error) {
	var originalSession model.Session
	if err := database.DB.First(&originalSession, originalSessionID).Error; err != nil {
		return nil, errors.New("original session not found")
	}

	followUpSession := model.Session{
		PsychiatristID: originalSession.PsychiatristID,
		PatientID:      originalSession.PatientID,
		Date:           date,
		Status:         model.SessionOngoing, 
		ParentSessionID: &originalSession.ID, 
	}

	if err := database.DB.Create(&followUpSession).Error; err != nil {
		return nil, err
	}

	return &followUpSession, nil
}



func (sc *SessionController) UpdateSessionStatus(sessionID uint, status string) error {
	var session model.Session
	if err := database.DB.First(&session, sessionID).Error; err != nil {
		return errors.New("session not found")
	}

	validStatuses := map[string]bool{
		model.SessionOngoing:   true,
		model.SessionCompleted: true,
		model.SessionCancelled: true,
	}
	if !validStatuses[status] {
		return errors.New("invalid session status")
	}

	session.Status = status
	if err := database.DB.Save(&session).Error; err != nil {
		return err
	}

	return nil
}

func (sc *SessionController) GetSessionsByPsychiatrist(psychiatristID uint) ([]model.Session, error) {
	var sessions []model.Session
	if err := database.DB.Where("psychiatrist_id = ?", psychiatristID).Find(&sessions).Error; err != nil {
		return nil, err
	}
	return sessions, nil
}

func (sc *SessionController) GetAllSessions() ([]model.Session, error) {
	var sessions []model.Session
	if err := database.DB.Find(&sessions).Error; err != nil {
		return nil, err
	}
	return sessions, nil
}

func (sc *SessionController) GetSessionByID(sessionID uint) (*model.Session, error) {
    var session model.Session
    err := database.DB.Preload("Psychiatrist").
        Preload("Patient").Preload("Diagnosis").First(&session, sessionID).Error

	if err != nil {
        return nil, err 
    }
    return &session, nil
}

