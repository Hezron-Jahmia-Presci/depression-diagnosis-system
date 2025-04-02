package interfaces

import "depression-diagnosis-system/database/model"

type AdminInterface interface {
	RegisterAdmin(firstName, lastName, email, password string) (*model.Admin, error)
	LoginAdmin(email, password string) (string, error)
	LogoutAdmin(token string) error
	GetAdminDetails(adminID uint) (*model.Admin, error)
	UpdateAdmin(adminID uint, firstName, lastName, email string) (*model.Admin, error)
}