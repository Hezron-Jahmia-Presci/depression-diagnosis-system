package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"
	"time"
)

type SessionController struct{}

func NewSessionController() interfaces.SessionInterface {
	return &SessionController{}
}

// CreateSession handles creation and unique code generation
func (c *SessionController) CreateSession(s *model.Session) (*model.Session, error) {
	// Fetch patient to get department for session code prefix
	var patient model.Patient
	if err := database.DB.Preload("Department").First(&patient, s.PatientID).Error; err != nil {
		return nil, errors.New("invalid patient")
	}

	// Generate session code
	sessionCode := util.GenerateSessionCode(patient.Department.Name)

	// Assign code and default date
	s.SessionCode = sessionCode
	if s.Date.IsZero() {
		s.Date = time.Now()
	}

	s.Status = model.SessionOngoing // Set default status

	// Create session
	if err := database.DB.Create(s).Error; err != nil {
		return nil, err
	}
	return s, nil
}

// GetAllSessions returns all sessions
func (c *SessionController) GetAllSessions() ([]model.Session, error) {
	var sessions []model.Session
	if err := database.DB.Preload("Patient").Preload("HealthWorker").Find(&sessions).Error; err != nil {
		return nil, err
	}
	return sessions, nil
}

// GetSessionByID fetches a session by its numeric ID
func (c *SessionController) GetSessionByID(id uint) (*model.Session, error) {
	var session model.Session
	if err := database.DB.Preload("Patient").Preload("HealthWorker").First(&session, id).Error; err != nil {
		return nil, err
	}
	return &session, nil
}

// GetSessionByCode retrieves session via unique string code
func (c *SessionController) GetSessionByCode(code string) (*model.Session, error) {
	var session model.Session
	if err := database.DB.Preload("Patient").Preload("HealthWorker").Where("session_code = ?", code).First(&session).Error; err != nil {
		return nil, err
	}
	return &session, nil
}

// GetSessionsByPatient returns all sessions for a given patient
func (c *SessionController) GetSessionsByPatient(patientID uint) ([]model.Session, error) {
	var sessions []model.Session
	if err := database.DB.Preload("Patient").Preload("HealthWorker").
		Where("patient_id = ?", patientID).Find(&sessions).Error; err != nil {
		return nil, err
	}
	return sessions, nil
}

// GetSessionsByHealthWorker returns all sessions handled by a specific health worker
func (c *SessionController) GetSessionsByHealthWorker(healthWorkerID uint) ([]model.Session, error) {
	var sessions []model.Session
	if err := database.DB.Preload("Patient").Preload("HealthWorker").
		Where("health_worker_id = ?", healthWorkerID).Find(&sessions).Error; err != nil {
		return nil, err
	}
	return sessions, nil
}

// UpdateSession allows modification of session data
func (c *SessionController) UpdateSession(id uint, updated *model.Session) (*model.Session, error) {
	var session model.Session
	if err := database.DB.First(&session, id).Error; err != nil {
		return nil, err
	}

	// Update basic fields
	session.Status = updated.Status
	session.SessionIssue = updated.SessionIssue
	session.Description = updated.Description
	session.PatientStateAtRegistration = updated.PatientStateAtRegistration
	session.NextSessionDate = updated.NextSessionDate
	session.CurrentPrescription = updated.CurrentPrescription
	session.PreviousSessionID = updated.PreviousSessionID

	if err := session.ValidateStatus(); err != nil {
		return nil, err
	}

	if err := database.DB.Save(&session).Error; err != nil {
		return nil, err
	}
	return &session, nil
}

// DeleteSession removes a session by ID
func (c *SessionController) DeleteSession(id uint) error {
	var session model.Session
	if err := database.DB.First(&session, id).Error; err != nil {
		return err
	}
	return database.DB.Delete(&session).Error
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

func (c *SessionController) SearchSessions (queryParams map[string]string,) ([]model.Session, error) {
	var sessions []model.Session
	dbQuery := database.DB.Preload("HealthWorker").Preload("Patient").Preload("Diagnosis").Preload("SessionSummary")

	if sessionCode, ok := queryParams["session_code"]; ok && sessionCode != "" {
        dbQuery = dbQuery.Where("session_code = ?", sessionCode)
    }
	if HealthWorkerID, ok := queryParams["health_worker_id"]; ok && HealthWorkerID != "" {
        dbQuery = dbQuery.Where("health_worker_id = ?", HealthWorkerID)
    }

	if PatientID, ok := queryParams["patient_id"]; ok && PatientID != "" {
        dbQuery = dbQuery.Where("patient_id = ?", PatientID)
    }

	if status, ok := queryParams["status"]; ok && status != "" {
        // assuming is_active is a boolean field in model
        switch status {
		case model.SessionOngoing:
            dbQuery = dbQuery.Where("status = ?", true)
        case model.SessionCompleted:
            dbQuery = dbQuery.Where("status = ?", true)
		case model.SessionCancelled:
			dbQuery = dbQuery.Where("status = ?", true)
		}
    }

	err := dbQuery.Find(&sessions).Error
    if err != nil {
        return nil, err
    }

    return sessions, nil
}