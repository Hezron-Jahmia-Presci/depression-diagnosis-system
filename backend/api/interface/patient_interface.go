package interfaces

import "depression-diagnosis-system/database/model"

type PatientInterface interface {
	RegisterPatient(firstName, lastName, email, password string, psychiatristID uint) (*model.Patient, error)
	GetPatientsByPsychiatrist(psychiatristID uint) ([]model.Patient, error)
	GetAllPatients() ([]model.Patient, error)
	GetPateintDetailsByPsychiatirst(psychiatristID, patientID uint) (*model.Patient, error)
	GetPatientDetailsByID(patientID uint) (*model.Patient, error)
	UpdatePatient(patientID uint, firstName, lastName, email string) (*model.Patient, error)
}
