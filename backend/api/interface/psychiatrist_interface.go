package interfaces

import "depression-diagnosis-system/database/model"

type PsychiatristInterface interface {
	RegisterPsych(firstName, lastName, email, password string) (*model.Psychiatrist, error)
	LoginPsych(email, password string) (string, error)
	LogoutPsych(token string) (error)
	GetAllPsychiatrists()([]model.Psychiatrist, error)
	GetPsychiatristDetails(psychiatristID uint) (*model.Psychiatrist, error)
	UpdatePsychiatrist(psychiatristID uint, firstName, lastName, email string) (*model.Psychiatrist, error) 
}
