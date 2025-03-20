package model

import "gorm.io/gorm"

type SessionSummary struct {
	gorm.Model
	SessionID	uint 		`gorm:"not null;index" json:"session_id"`
	Session		*Session	`gorm:"foreignKey:SessionID" json:"omitempty"`
	Notes		string 		`gorm:"not null" json:"notes"`
}