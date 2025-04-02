package controller

import (
	interfaces "depression-diagnosis-system/api/interface"
	"depression-diagnosis-system/api/middleware"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"
)

type PsychiatristController struct{}

func NewPsychiatristController() interfaces.PsychiatristInterface{
	return &PsychiatristController{}
}

func (pc * PsychiatristController) RegisterPsych(firstName, lastName, email, password string) (*model.Psychiatrist, error) {
	hashedPassword, err := util.HashPassword(password) 
	if err != nil {
		return nil, err
	}

	psych := model.Psychiatrist{
		FirstName: firstName,
		LastName: lastName,
		Email: email,
		PasswordHash: hashedPassword,
	}

	if err := database.DB.Create(&psych).Error; err != nil {
		return nil, err
	}
	return &psych, nil
}

func (pc *PsychiatristController) LoginPsych(email, password string) (string, error) {
	var psych model.Psychiatrist

	if err := database.DB.Where("email = ?", email).First(&psych).Error; err != nil {
		return "", errors.New("user does not exist")
	}

	if !util.CheckPassword(psych.PasswordHash, password) {
		return "", errors.New("invalid password")
	}

	token, err := middleware.GenerateToken(psych.ID, psych.Email)
	if err != nil {
		return "", err
	}
	
	return token, nil
}

func (pc *PsychiatristController) LogoutPsych(token string) (error) {
	if err := middleware.InvalidateToken(token); err != nil {
		return errors.New("failed to logout")
	}
	return nil
}

func (pc *PsychiatristController) GetPsychiatristDetails(psychiatristID uint) (*model.Psychiatrist, error) {
	var psych model.Psychiatrist
	if err := database.DB.First(&psych, psychiatristID).Error; err != nil {
		return nil, err
	}
	return &psych, nil
}

func (pc *PsychiatristController) UpdatePsychiatrist(psychiatristID uint, firstName, lastName, email string) (*model.Psychiatrist, error) {
	var psych model.Psychiatrist
	if err := database.DB.First(&psych, psychiatristID).Error; err != nil {
		return nil, err
	}

	psych.FirstName = firstName
	psych.LastName = lastName
	psych.Email = email

	if err := database.DB.Save(&psych).Error; err != nil {
		return nil, err
	}

	return &psych, nil
}

func (pc *PsychiatristController) GetAllPsychiatrists() ([]model.Psychiatrist, error) {
	var psych []model.Psychiatrist
	if err := database.DB.Find(&psych).Error; err != nil {
		return nil, err
	}
	return psych, nil
}
