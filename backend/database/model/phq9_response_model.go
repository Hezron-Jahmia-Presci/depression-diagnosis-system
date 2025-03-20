package model

import (
	"encoding/json"

	"gorm.io/gorm"
)


type Phq9ResponseStruct struct {
	QuestionID uint `json:"question_id"`
	Response   int  `json:"response"`
}

type Phq9Response struct {
	gorm.Model
	SessionID 	uint 			`gorm:"not null;index" json:"session_id"`
	Session		Session			`gorm:"foreignKey:SessionID"`
	Responses   json.RawMessage `gorm:"type:jsonb" json:"responses"` 
}
