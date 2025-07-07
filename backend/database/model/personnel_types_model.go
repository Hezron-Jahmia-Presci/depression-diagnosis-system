// model/personnel_type.go
package model

import "gorm.io/gorm"

type PersonnelType struct {
	gorm.Model
	Name string `gorm:"unique;not null" json:"name"`
}
