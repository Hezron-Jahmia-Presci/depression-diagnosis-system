package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"
	"strings"
)

type PersonnelTypeController struct{}

func NewPersonnelTypeController() interfaces.PersonnelTypeInterface {
	return &PersonnelTypeController{}
}

// CreatePersonnelType adds a new personnel type if it doesn't exist
func (c *PersonnelTypeController) CreatePersonnelType(pt *model.PersonnelType) (*model.PersonnelType, error) {
	pt.Name = strings.TrimSpace(strings.ToLower(pt.Name))
	if pt.Name == "" {
		return nil, errors.New("personnel type name cannot be empty")
	}

	var existing model.PersonnelType
	if err := database.DB.Where("LOWER(name) = ?", pt.Name).First(&existing).Error; err == nil {
		return &existing, nil // Already exists, return it
	}

	if err := database.DB.Create(pt).Error; err != nil {
		return nil, err
	}
	return pt, nil
}

// GetAllPersonnelTypes returns all personnel types for dropdown usage
func (c *PersonnelTypeController) GetAllPersonnelTypes() ([]model.PersonnelType, error) {
	var types []model.PersonnelType
	if err := database.DB.Find(&types).Error; err != nil {
		return nil, err
	}
	return types, nil
}

// GetPersonnelTypeByID finds a type by its ID
func (c *PersonnelTypeController) GetPersonnelTypeByID(id uint) (*model.PersonnelType, error) {
	var pt model.PersonnelType
	if err := database.DB.First(&pt, id).Error; err != nil {
		return nil, err
	}
	return &pt, nil
}

// GetPersonnelTypeByName allows lookup by name
func (c *PersonnelTypeController) GetPersonnelTypeByName(name string) (*model.PersonnelType, error) {
	var pt model.PersonnelType
	if err := database.DB.Where("LOWER(name) = ?", strings.ToLower(name)).First(&pt).Error; err != nil {
		return nil, err
	}
	return &pt, nil
}

// DeletePersonnelType deletes a type by ID
func (c *PersonnelTypeController) DeletePersonnelType(id uint) error {
	var pt model.PersonnelType
	if err := database.DB.First(&pt, id).Error; err != nil {
		return err
	}
	return database.DB.Delete(&pt).Error
}


// Search PersonnelType
func (c *PersonnelTypeController) SearchPersonnelType(queryParams map[string]string) ([]model.PersonnelType, error) {
	var pt []model.PersonnelType
	dbQuery := database.DB

	if name, ok := queryParams["name"]; ok && name != "" {
        dbQuery = dbQuery.Where("name = ?", name)
    }

	if err := dbQuery.Find(&pt).Error; err != nil {
        return nil, err
    }

    return pt, nil
}