package interfaces

import "depression-diagnosis-system/database/model"

type PatientInterface interface {
	CreatePatient(patient *model.Patient) (*model.Patient, error)
	GetAllPatients() ([]model.Patient, error)
	GetPatientByID(id uint) (*model.Patient, error)
	GetPatientsByHealthWorker(healthWorkerID uint) ([]model.Patient, error)
	GetPatientByHealthWorker(healthWorkerID, patientID uint) (*model.Patient, error)
	UpdatePatient(id uint, updated *model.Patient) (*model.Patient, error)
	DeletePatient(id uint) error
	GetPatientsByDepartment(departmentID uint) ([]model.Patient, error)
	
	SearchPatients(queryParams map[string]string) ([]model.Patient, error)
	SetActiveStatus(id uint, active bool) (*model.Patient, error) 
}
