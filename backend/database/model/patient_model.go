package model

import (
	"time"

	"gorm.io/gorm"
)

type Patient struct {
	gorm.Model
	FirstName         string       `gorm:"not null" json:"first_name"`
	LastName          string       `gorm:"not null" json:"last_name"`
	Email			  string  	   `gorm:"not null" json:"email"`
	ImageURL 		  string 	   `json:"image_url"`
	Address           string       `json:"address"`
	Contact           string       `json:"contact"`
	Gender            string       `gorm:"not null" json:"gender"`            // Male, Female, Other
	DateOfBirth       time.Time    `json:"date_of_birth"`
	NationalID        string       `gorm:"uniqueIndex" json:"national_id"`    // NIN
	Description       string       `gorm:"type:text" json:"description"`      // Circumstances on arrival
	AdmissionDate     time.Time    `json:"admission_date"`
	PatientCode       string       `gorm:"uniqueIndex" json:"patient_code"`   // e.g. Dd-192
	
	PreviousDiagnosis string       `gorm:"type:text" json:"previous_diagnosis"` // Previous diagnosis if any
	
	DepartmentID      uint         `json:"department_id"`
	Department        Department   `gorm:"foreignKey:DepartmentID"`
	AdmittedByID      uint         `json:"admitted_by_id"`
	AdmittedBy        HealthWorker `gorm:"foreignKey:AdmittedByID"`

	MedicationHistories []MedicationHistory `gorm:"foreignKey:PatientID" json:"medication_histories"`

	IsActive bool `gorm:"default:true" json:"is_active"`

}
