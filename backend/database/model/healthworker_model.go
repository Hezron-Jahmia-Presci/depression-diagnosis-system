package model

import "gorm.io/gorm"

const (
	RoleAdmin       = "admin"
	RoleHealthWorker = "healthworker"
)

type HealthWorker struct {
	gorm.Model
	FirstName       string       `gorm:"not null" json:"first_name"`
	LastName        string       `gorm:"not null" json:"last_name"`
	Email           string       `gorm:"not null;uniqueIndex" json:"email"`
	PersonnelTypeID uint          `json:"personnel_type_id"`
	PersonnelType   PersonnelType `gorm:"foreignKey:PersonnelTypeID"` // e.g. Intern, Senior, Consultant
	JobTitle        string       `json:"job_title"`     
	ImageURL 		string 		 `json:"image_url"`
	Address         string       `json:"address"`
	Contact         string       `json:"contact"`
	Bio             string       `gorm:"type:text" json:"bio"`           // Brief bio
	Qualification   string       `json:"qualification"`
	EducationLevel  string       `json:"education_level"`               // e.g. Bachelor's, Master's
	YearsOfPractice int          `json:"years_of_practice"`
	EmployeeID      string       `gorm:"uniqueIndex" json:"employee_id"`
	DepartmentID    uint         `json:"department_id"`                 // FK to Department
	Department      Department   `gorm:"foreignKey:DepartmentID"`
	SupervisorID    *uint        `json:"supervisor_id"`                // FK to another HealthWorker
	Supervisor      *HealthWorker `gorm:"foreignKey:SupervisorID"`
	Role 			string 		 `gorm:"default:'healthworker'" json:"role"` 
	PasswordHash    string       `json:"-"` // stored as hash
	IsActive bool `gorm:"default:true" json:"is_active"`
}
