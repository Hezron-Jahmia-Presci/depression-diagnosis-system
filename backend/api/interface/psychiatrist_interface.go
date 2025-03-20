package interfaces

import "depression-diagnosis-system/database/model"

type PsychiatristInterface interface {
	Register(firstName, lastName, email, password string) (*model.Psychiatrist, error)
	Login(email, password string) (string, error)
	Logout(token string) (error)
	GetPsychiatristDetails(psychiatristID uint) (*model.Psychiatrist, error)
	UpdatePsychiatrist(psychiatristID uint, firstName, lastName, email string) (*model.Psychiatrist, error) 
}
