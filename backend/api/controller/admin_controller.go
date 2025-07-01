package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/middleware"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"
)

type AdminController struct{}

func NewAdminController() interfaces.AdminInterface {
	return &AdminController{}
}

func (ac *AdminController) CreateAdmin(admin *model.Admin) (*model.Admin, error) {
	if !util.IsValidEmail(admin.Email) {
		return nil, errors.New("invalid email format")
	}

	var existing model.Admin
	if err := database.DB.Where("email = ?", admin.Email).First(&existing).Error; err == nil {
		return nil, errors.New("admin with this email already exists")
	}

	if err := database.DB.Create(admin).Error; err != nil {
		return nil, err
	}

	return admin, nil
}

func (ac *AdminController) GetAdminByID(id uint) (*model.Admin, error) {
	var admin model.Admin
	if err := database.DB.First(&admin, id).Error; err != nil {
		return nil, err
	}
	return &admin, nil
}

func (ac *AdminController) UpdateAdmin(id uint, updatedAdmin *model.Admin) (*model.Admin, error) {
	var admin model.Admin
	if err := database.DB.First(&admin, id).Error; err != nil {
		return nil, err
	}

	if updatedAdmin.Email != "" && !util.IsValidEmail(updatedAdmin.Email) {
		return nil, errors.New("invalid email format")
	}

	admin.FirstName = updatedAdmin.FirstName
	admin.LastName = updatedAdmin.LastName
	admin.Email = updatedAdmin.Email

	if err := database.DB.Save(&admin).Error; err != nil {
		return nil, err
	}

	return &admin, nil
}

func (ac *AdminController) DeleteAdmin(id uint) error {
	var admin model.Admin
	if err := database.DB.First(&admin, id).Error; err != nil {
		return err
	}
	if err := database.DB.Delete(&admin).Error; err != nil {
		return err
	}
	return nil
}

func (ac *AdminController) LogInAdmin(email, password string) (string, error) {
	var admin model.Admin
	if err := database.DB.Where("email = ?", email).First(&admin).Error; err != nil {
		return "", errors.New("admin does not exist")
	}

	if !util.CheckPassword(admin.PasswordHash, password) {
		return "", errors.New("invalid password")
	}


	token, err := middleware.GenerateToken(admin.ID, admin.Email)
	if err != nil {
		return "", err
	}

	return token, nil
}

func (ac *AdminController) LogOutAdmin(token string) error {
	if err := middleware.InvalidateToken(token); err != nil {
		return errors.New("failed to logout")
	}
	return nil
}
