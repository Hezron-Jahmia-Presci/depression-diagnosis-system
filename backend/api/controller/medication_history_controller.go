package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"
)

type MedicationHistoryController struct{}

func NewMedicationHistoryController() interfaces.MedicationHistoryInterface {
	return &MedicationHistoryController{}
}

// CreateMedicationHistory creates a new medication history record
func (mc *MedicationHistoryController) CreateMedicationHistory(medHist *model.MedicationHistory) (*model.MedicationHistory, error) {
	// Check patient exists
	var patient model.Patient
	if err := database.DB.First(&patient, medHist.PatientID).Error; err != nil {
		return nil, errors.New("invalid patient ID")
	}

	// Optional: if PrescribingDoctorID != nil, verify doctor exists
	if medHist.PrescribingDoctorID != nil {
		var doctor model.HealthWorker
		if err := database.DB.First(&doctor, *medHist.PrescribingDoctorID).Error; err != nil {
			return nil, errors.New("invalid prescribing doctor ID")
		}
	}

	if err := database.DB.Create(medHist).Error; err != nil {
		return nil, err
	}

	return medHist, nil
}

// GetMedicationHistoryByID fetches a medication history record by ID
func (mc *MedicationHistoryController) GetMedicationHistoryByID(id uint) (*model.MedicationHistory, error) {
	var medHist model.MedicationHistory
	if err := database.DB.
		Preload("Patient").
		Preload("PrescribingDoctor").
		First(&medHist, id).Error; err != nil {
		return nil, err
	}
	return &medHist, nil
}

// GetMedicationHistoriesByPatient fetches all medication histories for a patient
func (mc *MedicationHistoryController) GetMedicationHistoriesByPatient(patientID uint) ([]model.MedicationHistory, error) {
	var medHists []model.MedicationHistory
	if err := database.DB.
		Preload("PrescribingDoctor").
		Where("patient_id = ?", patientID).
		Find(&medHists).Error; err != nil {
		return nil, err
	}
	return medHists, nil
}

// UpdateMedicationHistory updates an existing medication history record
func (mc *MedicationHistoryController) UpdateMedicationHistory(id uint, updated *model.MedicationHistory) (*model.MedicationHistory, error) {
	var medHist model.MedicationHistory
	if err := database.DB.First(&medHist, id).Error; err != nil {
		return nil, err
	}

	// Optional: Validate patient ID if changed
	if updated.PatientID != 0 && updated.PatientID != medHist.PatientID {
		var patient model.Patient
		if err := database.DB.First(&patient, updated.PatientID).Error; err != nil {
			return nil, errors.New("invalid patient ID")
		}
		medHist.PatientID = updated.PatientID
	}

	// Optional: Validate prescribing doctor ID if changed
	if updated.PrescribingDoctorID != nil && (medHist.PrescribingDoctorID == nil || *updated.PrescribingDoctorID != *medHist.PrescribingDoctorID) {
		var doctor model.HealthWorker
		if err := database.DB.First(&doctor, *updated.PrescribingDoctorID).Error; err != nil {
			return nil, errors.New("invalid prescribing doctor ID")
		}
		medHist.PrescribingDoctorID = updated.PrescribingDoctorID
	}

	// Update fields
	medHist.Prescription = updated.Prescription
	medHist.ExternalDoctorName = updated.ExternalDoctorName
	medHist.ExternalDoctorContact = updated.ExternalDoctorContact
	medHist.HealthCenter = updated.HealthCenter

	if err := database.DB.Save(&medHist).Error; err != nil {
		return nil, err
	}

	return &medHist, nil
}

// DeleteMedicationHistory deletes a medication history record
func (mc *MedicationHistoryController) DeleteMedicationHistory(id uint) error {
	var medHist model.MedicationHistory
	if err := database.DB.First(&medHist, id).Error; err != nil {
		return err
	}
	return database.DB.Delete(&medHist).Error
}

// GetAllMedicationHistories returns all medication histories
func (mc *MedicationHistoryController) GetAllMedicationHistories() ([]model.MedicationHistory, error) {
	var medHists []model.MedicationHistory
	if err := database.DB.
		Preload("Patient").
		Preload("PrescribingDoctor").
		Find(&medHists).Error; err != nil {
		return nil, err
	}
	return medHists, nil
}

// SearchMedicationHistories searches medication histories by query params
func (mc *MedicationHistoryController) SearchMedicationHistories(queryParams map[string]string) ([]model.MedicationHistory, error) {
	var medHists []model.MedicationHistory
	dbQuery := database.DB.Preload("Patient").Preload("PrescribingDoctor")

	if patientID, ok := queryParams["patient_id"]; ok && patientID != "" {
		dbQuery = dbQuery.Where("patient_id = ?", patientID)
	}

	if prescribingDoctorID, ok := queryParams["prescribing_doctor_id"]; ok && prescribingDoctorID != "" {
		dbQuery = dbQuery.Where("prescribing_doctor_id = ?", prescribingDoctorID)
	}

	if healthCenter, ok := queryParams["health_center"]; ok && healthCenter != "" {
		dbQuery = dbQuery.Where("health_center ILIKE ?", "%"+healthCenter+"%")
	}

	if externalDoctorName, ok := queryParams["external_doctor_name"]; ok && externalDoctorName != "" {
		dbQuery = dbQuery.Where("external_doctor_name ILIKE ?", "%"+externalDoctorName+"%")
	}

	if err := dbQuery.Find(&medHists).Error; err != nil {
		return nil, err
	}

	return medHists, nil
}

