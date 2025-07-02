package interfaces

import "depression-diagnosis-system/database/model"

type PatientInterface interface {
	CreatePatient(patient *model.Patient) (*model.Patient, error)
	GetAllPatients() ([]model.Patient, error)
	GetPatientsByPsychiatrist(psychiatristID uint) ([]model.Patient, error)
	GetPatientByID(id uint) (*model.Patient, error)
	GetPatientByPsychiatrist(psychiatristID, patientID uint) (*model.Patient, error)
	UpdatePatient(id uint, patient *model.Patient) (*model.Patient, error)
	DeletePatient(id uint) error
}
