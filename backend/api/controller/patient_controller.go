package controller

import (
	interfaces "depression-diagnosis-system/api/interface"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
)

type PatientController struct{}

func NewPatientController() interfaces.PatientInterface {
	return &PatientController{}
}

func (pc *PatientController) RegisterPatient(firstName, lastName, email, password string, psychiatristID uint) (*model.Patient, error) {
	hashedPassword, err := util.HashPassword(password)
	if err != nil {
		return nil, err
	}

	patient := model.Patient{
		FirstName:      firstName,
		LastName:       lastName,
		Email:          email,
		PasswordHash:   hashedPassword,
		PsychiatristID: psychiatristID,
	}

	if err := database.DB.Create(&patient).Error; err != nil {
		return nil, err
	}

	return &patient, nil
}

func (pc *PatientController) GetPatientsByPsychiatrist(psychiatristID uint) ([]model.Patient, error) {
	var patients []model.Patient
	if err := database.DB.Preload("Psychiatrist").Where("psychiatrist_id = ?", psychiatristID).Find(&patients).Error; err != nil {
		return nil, err
	}
	return patients, nil
}

func (pc *PatientController) GetAllPatients() ([]model.Patient, error) {
	var patients []model.Patient
	if err := database.DB.Find(&patients).Error; err != nil {
		return nil, err
	}
	return patients, nil
}

func (pc *PatientController) GetPateintDetailsByPsychiatirst(psychiatristID, patientID uint) (*model.Patient, error) {
	var patient model.Patient
	if err := database.DB.Preload("Psychiatrist").
    Where("psychiatrist_id = ?", psychiatristID).
    First(&patient, patientID).Error; err != nil {
    return nil, err
}

	return &patient, nil
}

func (pc *PatientController) GetPatientDetailsByID(patientID uint) (*model.Patient, error) {
	var patient model.Patient
	err := database.DB.First(&patient, patientID).Error

	if err != nil {
		return nil, err
	}
	return &patient, nil
}

func (pc *PatientController) UpdatePatient(patientID uint, firstName, lastName, email string) (*model.Patient, error) {
	var patient model.Patient
	if err := database.DB.First(&patient, patientID).Error; err != nil {
		return nil, err
	}

	patient.FirstName = firstName
	patient.LastName = lastName
	patient.Email = email

	if err := database.DB.Save(&patient).Error; err != nil {
		return nil, err
	}

	return &patient, nil
}
