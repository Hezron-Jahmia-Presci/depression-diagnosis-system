package model

import "gorm.io/gorm"

type Patient struct {
	gorm.Model
	FirstName      string      `gorm:"not null" json:"first_name"`
	LastName       string      `gorm:"not null" json:"last_name"`
	Email          string      `gorm:"not null;uniqueIndex" json:"email"`
	PsychiatristID uint        `gorm:"not null;index" json:"psychiatrist_id"`
	Psychiatrist   Psychiatrist `gorm:"foreignKey:PsychiatristID"`
}
 