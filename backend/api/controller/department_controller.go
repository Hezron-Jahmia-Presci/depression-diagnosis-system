package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"
	"strings"
)

type DepartmentController struct{}

func NewDepartmentController() interfaces.DepartmentInterface {
	return &DepartmentController{}
}

// CreateDepartment creates a new department
func (c *DepartmentController) CreateDepartment(dept *model.Department) (*model.Department, error) {
	dept.Name = strings.TrimSpace(dept.Name)
	if dept.Name == "" {
		return nil, errors.New("department name is required")
	}

	var exists model.Department
	if err := database.DB.Where("LOWER(name) = ?", strings.ToLower(dept.Name)).First(&exists).Error; err == nil {
		return nil, errors.New("a department with this name already exists")
	}

	if err := database.DB.Create(dept).Error; err != nil {
		return nil, err
	}
	return dept, nil
}

// GetDepartmentByID retrieves a department by its ID, including health workers
func (c *DepartmentController) GetDepartmentByID(id uint) (*model.Department, error) {
	var dept model.Department
	if err := database.DB.Preload("HealthWorkers").First(&dept, id).Error; err != nil {
		return nil, err
	}
	return &dept, nil
}

// GetAllDepartments fetches all departments with their associated health workers
func (c *DepartmentController) GetAllDepartments() ([]model.Department, error) {
	var departments []model.Department
	if err := database.DB.Preload("HealthWorkers").Find(&departments).Error; err != nil {
		return nil, err
	}
	return departments, nil
}

// UpdateDepartment updates a department's details
func (c *DepartmentController) UpdateDepartment(id uint, updated *model.Department) (*model.Department, error) {
	var dept model.Department
	if err := database.DB.First(&dept, id).Error; err != nil {
		return nil, err
	}

	if updated.Name != "" {
		dept.Name = strings.TrimSpace(updated.Name)
	}

	if err := database.DB.Save(&dept).Error; err != nil {
		return nil, err
	}
	return &dept, nil
}

// DeleteDepartment deletes a department by ID
func (c *DepartmentController) DeleteDepartment(id uint) error {
	var dept model.Department
	if err := database.DB.First(&dept, id).Error; err != nil {
		return err
	}
	return database.DB.Delete(&dept).Error
}

// GetDepartmentByName fetches a department by its name
func (c *DepartmentController) GetDepartmentByName(name string) (*model.Department, error) {
	var dept model.Department
	if err := database.DB.Where("LOWER(name) = ?", strings.ToLower(strings.TrimSpace(name))).First(&dept).Error; err != nil {
		return nil, err
	}
	return &dept, nil
}

// Search departments

func (c* DepartmentController) SearchDepartments (queryParams map[string]string) ([]model.Department, error) {
	var dept []model.Department
	dbQuery := database.DB.Preload("HealthWorker")

	if name, ok := queryParams["name"]; ok && name != "" {
        dbQuery = dbQuery.Where("name = ?", name)
    }

	if err := dbQuery.Find(&dept).Error; err != nil {
        return nil, err
    }

    return dept, nil
}
