package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"
	"strings"
)

type PatientController struct{}

func NewPatientController() interfaces.PatientInterface {
	return &PatientController{}
}

// CreatePatient creates a new patient and generates a unique PatientCode
func (pc *PatientController) CreatePatient(patient *model.Patient) (*model.Patient, error) {
	if patient.Email != "" && !util.IsValidEmail(patient.Email) {
		return nil, errors.New("invalid email format")
	}

	var department model.Department
	if err := database.DB.First(&department, patient.DepartmentID).Error; err != nil {
		return nil, errors.New("invalid department ID")
	}

	patient.PatientCode = util.GeneratePatientCode(department.Name)

	// First, save the patient
	if err := database.DB.Create(patient).Error; err != nil {
		return nil, err
	}

	// Save medication histories if any
	if len(patient.MedicationHistories) > 0 {
		for i := range patient.MedicationHistories {
			patient.MedicationHistories[i].PatientID = patient.ID
			if err := database.DB.Create(&patient.MedicationHistories[i]).Error; err != nil {
				return nil, errors.New("failed to create medication history: " + err.Error())
			}
		}
	}

	return patient, nil
}


// GetAllPatients retrieves all patients
func (pc *PatientController) GetAllPatients() ([]model.Patient, error) {
	var patients []model.Patient
	if err := database.DB.
		Preload("Department").
		Preload("AdmittedBy").
		Preload("MedicationHistories.PrescribingDoctor").
		Find(&patients).Error; err != nil {
		return nil, err
	}
	return patients, nil
}

// GetPatientByID fetches a patient by their database ID
func (pc *PatientController) GetPatientByID(id uint) (*model.Patient, error) {
	var patient model.Patient
	if err := database.DB.
		Preload("Department").
		Preload("AdmittedBy").
		Preload("MedicationHistories.PrescribingDoctor").
		First(&patient, id).Error; err != nil {
		return nil, err
	}
	return &patient, nil
}

// GetPatientsByHealthWorker returns all patients admitted by a specific health worker
func (pc *PatientController) GetPatientsByHealthWorker(healthWorkerID uint) ([]model.Patient, error) {
	var patients []model.Patient
	if err := database.DB.
		Preload("Department").
		Preload("AdmittedBy").
		Preload("MedicationHistories.PrescribingDoctor").
		Where("admitted_by_id = ?", healthWorkerID).
		Find(&patients).Error; err != nil {
		return nil, err
	}
	return patients, nil
}

// GetPatientByHealthWorker fetches a specific patient only if admitted by that health worker
func (pc *PatientController) GetPatientByHealthWorker(healthWorkerID, patientID uint) (*model.Patient, error) {
	var patient model.Patient
	if err := database.DB.
		Preload("Department").
		Preload("AdmittedBy").
		Preload("MedicationHistories.PrescribingDoctor").
		Where("admitted_by_id = ?", healthWorkerID).
		First(&patient, patientID).Error; err != nil {
		return nil, err
	}
	return &patient, nil
}

// GetPatientsByDepartment fetches patients assigned to a given department
func (pc *PatientController) GetPatientsByDepartment(departmentID uint) ([]model.Patient, error) {
	var patients []model.Patient
	if err := database.DB.
		Preload("Department").
		Preload("AdmittedBy").
		Preload("MedicationHistories.PrescribingDoctor").
		Where("department_id = ?", departmentID).
		Find(&patients).Error; err != nil {
		return nil, err
	}
	return patients, nil
}

// UpdatePatient modifies an existing patient record
func (pc *PatientController) UpdatePatient(id uint, updated *model.Patient) (*model.Patient, error) {
	var patient model.Patient
	if err := database.DB.First(&patient, id).Error; err != nil {
		return nil, err
	}

	if updated.Email != "" && !util.IsValidEmail(updated.Email) {
		return nil, errors.New("invalid email format")
	}

	// Update basic fields
	patient.FirstName = updated.FirstName
	patient.LastName = updated.LastName
	patient.Email = updated.Email
	patient.Address = updated.Address
	patient.Contact = updated.Contact
	patient.Gender = updated.Gender
	patient.DateOfBirth = updated.DateOfBirth
	patient.NationalID = updated.NationalID
	patient.Description = updated.Description
	patient.PreviousDiagnosis = updated.PreviousDiagnosis
	patient.AdmissionDate = updated.AdmissionDate
	patient.DepartmentID = updated.DepartmentID
	patient.AdmittedByID = updated.AdmittedByID

	if err := database.DB.Save(&patient).Error; err != nil {
		return nil, err
	}

	// Update medication histories (optional strategy: delete and recreate)
	if len(updated.MedicationHistories) > 0 {
		// Delete existing histories
		if err := database.DB.Where("patient_id = ?", patient.ID).Delete(&model.MedicationHistory{}).Error; err != nil {
			return &patient, errors.New("failed to clear old medication histories: " + err.Error())
		}

		// Save new histories
		for i := range updated.MedicationHistories {
			updated.MedicationHistories[i].PatientID = patient.ID
			if err := database.DB.Create(&updated.MedicationHistories[i]).Error; err != nil {
				return &patient, errors.New("failed to add medication history: " + err.Error())
			}
		}
	}

	return &patient, nil
}


// DeletePatient deletes a patient from the system
func (pc *PatientController) DeletePatient(id uint) error {
    var patient model.Patient
    if err := database.DB.First(&patient, id).Error; err != nil {
        return err
    }

    if patient.IsActive {
        return errors.New("cannot delete an active patient; please deactivate first")
    }

    return database.DB.Delete(&patient).Error
}


func (pc *PatientController) SetActiveStatus(id uint, active bool) (*model.Patient, error) {
    var patient model.Patient
    if err := database.DB.First(&patient, id).Error; err != nil {
        return nil, err
    }

    patient.IsActive = active

    if err := database.DB.Save(&patient).Error; err != nil {
        return nil, err
    }

    return &patient, nil
}

func (pc *PatientController) SearchPatients(queryParams map[string]string) ([]model.Patient, error) {
    var patients []model.Patient
	dbQuery := database.DB.Preload("Department").Preload("AdmittedBy").Preload("MedicationHistories.PrescribingDoctor")


	if name, ok := queryParams["name"]; ok && name != "" {
        likePattern := "%" + name + "%"
        dbQuery = dbQuery.Where("first_name ILIKE ? OR last_name ILIKE ?", likePattern, likePattern)
    }

	if email, ok := queryParams["email"]; ok && email != "" {
        dbQuery = dbQuery.Where("email = ?", email)
    }

	if patientID, ok := queryParams["patient_id"]; ok && patientID != "" {
        dbQuery = dbQuery.Where("patient_id = ?", patientID)
    }

    if deptID, ok := queryParams["department_id"]; ok && deptID != "" {
        dbQuery = dbQuery.Where("department_id = ?", deptID)
    }

    if activeStr, ok := queryParams["is_active"]; ok && activeStr != "" {
		// assuming is_active is a boolean field in model
        switch strings.ToLower(activeStr) {
        case "true":
            dbQuery = dbQuery.Where("is_active = ?", true)
        case "false":
            dbQuery = dbQuery.Where("is_active = ?", false)
        }
    }

    if err := dbQuery.Find(&patients).Error; err != nil {
        return nil, err
    }

    return patients, nil
}
