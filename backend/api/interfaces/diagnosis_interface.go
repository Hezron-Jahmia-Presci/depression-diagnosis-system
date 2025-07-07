package interfaces

import "depression-diagnosis-system/database/model"

type DiagnosisInterface interface {
	CreateDiagnosis(diagnosis *model.Diagnosis) (*model.Diagnosis, error)
	GetDiagnosisByID(id uint) (*model.Diagnosis, error)
	GetDiagnosisBySessionID(sessionID uint) (*model.Diagnosis, error)
	UpdateDiagnosis(id uint, updated *model.Diagnosis) (*model.Diagnosis, error)
	DeleteDiagnosis(id uint) error
}
