package interfaces

import "depression-diagnosis-system/database/model"

type DepartmentInterface interface {
	CreateDepartment(dept *model.Department) (*model.Department, error)
	GetDepartmentByID(id uint) (*model.Department, error)
	GetAllDepartments() ([]model.Department, error)
	UpdateDepartment(id uint, updated *model.Department) (*model.Department, error)
	DeleteDepartment(id uint) error

	// Optional
	GetDepartmentByName(name string) (*model.Department, error)
	SearchDepartments(queryParams map[string]string) ([]model.Department, error)
}
