package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/middleware"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"
)

type PsychiatristController struct{}

func NewPsychiatristController() interfaces.PsychiatristInterface {
	return &PsychiatristController{}
}

func (pc *PsychiatristController) CreatePsychiatrist(psych *model.Psychiatrist) (*model.Psychiatrist, error) {
	if !util.IsValidEmail(psych.Email) {
		return nil, errors.New("invalid email format")
	}

	var existing model.Psychiatrist
	if err := database.DB.Where("email = ?", psych.Email).First(&existing).Error; err == nil {
		return nil, errors.New("admin with this email already exists")
	}

	if err := database.DB.Create(psych).Error; err != nil {
		return nil, err
	}
	return psych, nil
}

func (pc *PsychiatristController) GetAllPsychiatrists() ([]model.Psychiatrist, error) {
	var psychs []model.Psychiatrist
	if err := database.DB.Find(&psychs).Error; err != nil {
		return nil, err
	}
	return psychs, nil
}

func (pc *PsychiatristController) GetPsychiatristByID(id uint) (*model.Psychiatrist, error) {
	var psych model.Psychiatrist
	if err := database.DB.First(&psych, id).Error; err != nil {
		return nil, err
	}
	return &psych, nil
}

func (pc *PsychiatristController) UpdatePsychiatrist(id uint, updatedPsych *model.Psychiatrist) (*model.Psychiatrist, error) {
	var psych model.Psychiatrist
	if err := database.DB.First(&psych, id).Error; err != nil {
		return nil, err
	}

	if updatedPsych.Email != "" && !util.IsValidEmail(updatedPsych.Email) {
		return nil, errors.New("invalid email format")
	}

	psych.FirstName = updatedPsych.FirstName
	psych.LastName = updatedPsych.LastName
	psych.Email = updatedPsych.Email

	if err := database.DB.Save(&psych).Error; err != nil {
		return nil, err
	}

	return &psych, nil
}

func (pc *PsychiatristController) DeletePsychiatrist(id uint) error {
	var psych model.Psychiatrist
	if err := database.DB.First(&psych, id).Error; err != nil {
		return err
	}
	if err := database.DB.Delete(&psych).Error; err != nil {
		return err
	}
	return nil
}

func (pc *PsychiatristController) LogInPsychiatrist(email, password string) (string, error) {
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

func (pc *PsychiatristController) LogOutPsychiatrist(token string) error {
	if err := middleware.InvalidateToken(token); err != nil {
		return errors.New("failed to logout")
	}
	return nil
}
