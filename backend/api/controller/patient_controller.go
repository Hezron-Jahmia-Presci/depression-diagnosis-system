package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"
)

type PatientController struct{}

func NewPatientController() interfaces.PatientInterface {
	return &PatientController{}
}

func (pc *PatientController) CreatePatient(patient *model.Patient) (*model.Patient, error) {
	if !util.IsValidEmail(patient.Email) {
		return nil, errors.New("invalid email format")
	}

	if err := database.DB.Create(patient).Error; err != nil {
		return nil, err
	}

	return patient, nil
}

func (pc *PatientController) GetAllPatients() ([]model.Patient, error) {
	var patients []model.Patient
	if err := database.DB.Find(&patients).Error; err != nil {
		return nil, err
	}
	return patients, nil
}

func (pc *PatientController) GetPatientsByPsychiatrist(psychiatristID uint) ([]model.Patient, error) {
	var patients []model.Patient
	if err := database.DB.Preload("Psychiatrist").Where("psychiatrist_id = ?", psychiatristID).Find(&patients).Error; err != nil {
		return nil, err
	}
	return patients, nil
}

func (pc *PatientController) GetPatientByID(id uint) (*model.Patient, error) {
	var patient model.Patient
	if err := database.DB.First(&patient, id).Error; err != nil {
		return nil, err
	}
	return &patient, nil
}

func (pc *PatientController) GetPatientByPsychiatrist(psychiatristID, patientID uint) (*model.Patient, error) {
	var patient model.Patient
	if err := database.DB.Preload("Psychiatrist").
		Where("psychiatrist_id = ?", psychiatristID).
		First(&patient, patientID).Error; err != nil {
		return nil, err
	}
	return &patient, nil
}

func (pc *PatientController) UpdatePatient(id uint, updatedPatient *model.Patient) (*model.Patient, error) {
	var patient model.Patient
	if err := database.DB.First(&patient, id).Error; err != nil {
		return nil, err
	}

	if updatedPatient.Email != "" && !util.IsValidEmail(updatedPatient.Email) {
		return nil, errors.New("invalid email format")
	}

	patient.FirstName = updatedPatient.FirstName
	patient.LastName = updatedPatient.LastName
	patient.Email = updatedPatient.Email

	if err := database.DB.Save(&patient).Error; err != nil {
		return nil, err
	}

	return &patient, nil
}

func (pc *PatientController) DeletePatient(id uint) error {
	var patient model.Patient
	if err := database.DB.First(&patient, id).Error; err != nil {
		return err
	}
	if err := database.DB.Delete(&patient).Error; err != nil {
		return err
	}
	return nil
}
