package model

import "gorm.io/gorm"

type Phq9Question struct {
	gorm.Model
	Question	string	`gorm:"not null" json:"question"`
}
