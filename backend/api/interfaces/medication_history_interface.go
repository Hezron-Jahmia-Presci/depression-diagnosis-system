package interfaces

import "depression-diagnosis-system/database/model"

type MedicationHistoryInterface interface {
	CreateMedicationHistory(medHist *model.MedicationHistory) (*model.MedicationHistory, error)
	GetMedicationHistoryByID(id uint) (*model.MedicationHistory, error)
	GetMedicationHistoriesByPatient(patientID uint) ([]model.MedicationHistory, error)
	UpdateMedicationHistory(id uint, updated *model.MedicationHistory) (*model.MedicationHistory, error)
	DeleteMedicationHistory(id uint) error

	GetAllMedicationHistories() ([]model.MedicationHistory, error)
	SearchMedicationHistories(queryParams map[string]string) ([]model.MedicationHistory, error)
}
