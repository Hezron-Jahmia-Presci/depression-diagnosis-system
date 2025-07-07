package model

import "gorm.io/gorm"

type Department struct {
	gorm.Model
	Name          string          `gorm:"not null;uniqueIndex" json:"name"`
	Description   string          `json:"description"`
	HealthWorkers []HealthWorker  `gorm:"foreignKey:DepartmentID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;" json:"health_workers"`
}

