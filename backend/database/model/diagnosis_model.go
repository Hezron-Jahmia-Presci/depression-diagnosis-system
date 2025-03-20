package model

import (
	"gorm.io/gorm"
)

type Diagnosis struct {
	gorm.Model
	SessionID  		uint			`gorm:"not null;index" json:"session_id"`
	Session   		*Session 		`gorm:"foreignKey:SessionID"`
	Phq9Score  		int				`gorm:"not null" json:"phq9_score"`
	Severity   		string			`gorm:"not null" json:"severity"`
}

