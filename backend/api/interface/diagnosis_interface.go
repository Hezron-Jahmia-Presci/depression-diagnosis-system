package interfaces

import "depression-diagnosis-system/database/model"

type DiagnosisInterface interface {
	CreateDiagnosis(sessionID uint) (*model.Diagnosis, error)
	GetDiagnosisBySessionID(sessionID uint) (*model.Diagnosis, error)
	
}