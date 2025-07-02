package interfaces

import "depression-diagnosis-system/database/model"

type DiagnosisInterface interface {
	CreateDiagnosis(diagnosis *model.Diagnosis) (*model.Diagnosis, error)
	GetDiagnosisBySessionID(sessionID uint) (*model.Diagnosis, error)
}
