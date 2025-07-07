package interfaces

import "depression-diagnosis-system/database/model"

type PersonnelTypeInterface interface {
	CreatePersonnelType(pt *model.PersonnelType) (*model.PersonnelType, error)
	GetAllPersonnelTypes() ([]model.PersonnelType, error)
	GetPersonnelTypeByID(id uint) (*model.PersonnelType, error)
	GetPersonnelTypeByName(name string) (*model.PersonnelType, error)
	DeletePersonnelType(id uint) error

	SearchPersonnelType(queryParams map[string]string) ([]model.PersonnelType, error)
}
