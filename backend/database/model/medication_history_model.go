package model

import (
	"gorm.io/gorm"
)

type MedicationHistory struct {
	gorm.Model
	PatientID		 		uint   	 		`json:"patient_id"`
	Patient  		 		Patient 		`gorm:"foreignKey:PatientID"`
	Prescription 			string 			`gorm:"type:text" json:"prescription"`
	PrescribingDoctorID 	*uint         	`json:"prescribing_doctor_id"` // nullable
	PrescribingDoctor 		*HealthWorker	`gorm:"foreignKey:PrescribingDoctorID" json:"prescribing_doctor"`

	ExternalDoctorName    	string 			`json:"external_doctor_name"`
	ExternalDoctorContact 	string 			`json:"external_doctor_contact"`
	HealthCenter 			string 			`json:"health_center"`
}
