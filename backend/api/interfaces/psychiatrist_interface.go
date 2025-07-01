package interfaces

import "depression-diagnosis-system/database/model"

type PsychiatristInterface interface {
	CreatePsychiatrist(psych *model.Psychiatrist) (*model.Psychiatrist, error)
	GetAllPsychiatrists() ([]model.Psychiatrist, error)
	GetPsychiatristByID(id uint) (*model.Psychiatrist, error)
	UpdatePsychiatrist(id uint, psych *model.Psychiatrist) (*model.Psychiatrist, error)
	DeletePsychiatrist(id uint) error

	LogInPsychiatrist(email, password string) (string, error)
	LogOutPsychiatrist(token string) error
}
