package interfaces

import "depression-diagnosis-system/database/model"

type AdminInterface interface {
	CreateAdmin(admin *model.Admin) (*model.Admin, error)
	GetAdminByID(id uint) (*model.Admin, error)
	UpdateAdmin(id uint, admin *model.Admin) (*model.Admin, error)
	DeleteAdmin(id uint) error
	LogInAdmin(email, password string) (string, error)
	LogOutAdmin(token string) error
}
