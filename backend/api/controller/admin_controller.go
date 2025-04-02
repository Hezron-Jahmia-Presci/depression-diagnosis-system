package controller

import (
	interfaces "depression-diagnosis-system/api/interface"
	"depression-diagnosis-system/api/middleware"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"
)

type AdminController struct{}

func NewAdminController() interfaces.AdminInterface{
	return &AdminController{}
}

func (pc * AdminController) RegisterAdmin(firstName, lastName, email, password string) (*model.Admin, error) {
	hashedPassword, err := util.HashPassword(password) 
	if err != nil {
		return nil, err
	}

	admin := model.Admin{
		FirstName: firstName,
		LastName: lastName,
		Email: email,
		PasswordHash: hashedPassword,
	}

	if err := database.DB.Create(&admin).Error; err != nil {
		return nil, err
	}
	return &admin, nil
}

func (pc *AdminController) LoginAdmin(email, password string) (string, error) {
	var admin model.Admin

	if err := database.DB.Where("email = ?", email).First(&admin).Error; err != nil {
		return "", errors.New("user does not exist")
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

func (pc *AdminController) LogoutAdmin(token string) (error) {
	if err := middleware.InvalidateToken(token); err != nil {
		return errors.New("failed to logout")
	}
	return nil
}

func (pc *AdminController) GetAdminDetails(adminID uint) (*model.Admin, error) {
	var admin model.Admin
	if err := database.DB.First(&admin, adminID).Error; err != nil {
		return nil, err
	}
	return &admin, nil
}

func (pc *AdminController) UpdateAdmin(adminID uint, firstName, lastName, email string) (*model.Admin, error) {
	var admin model.Admin
	if err := database.DB.First(&admin, adminID).Error; err != nil {
		return nil, err
	}

	admin.FirstName = firstName
	admin.LastName = lastName
	admin.Email = email

	if err := database.DB.Save(&admin).Error; err != nil {
		return nil, err
	}

	return &admin, nil
}
