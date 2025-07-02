package model

import "gorm.io/gorm"

type Admin struct {
	gorm.Model
	FirstName    string `gorm:"not null" json:"first_name"`
	LastName     string `gorm:"not null" json:"last_name"`
	Email        string `gorm:"not null;uniqueIndex" json:"email"`
	PasswordHash string `json:"-"`
}