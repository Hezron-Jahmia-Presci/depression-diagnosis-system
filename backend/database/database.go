package database

import (
	"depression-diagnosis-system/database/model"
	"log"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB
var err error

func Conn() {
	// Open (or create) SQLite database file
	DB, err = gorm.Open(sqlite.Open("dds_sqlite.db"), &gorm.Config{})
	if err != nil {
		log.Fatalf("❌ Failed to connect to SQLite database: %v\n", err)
	} else {
		log.Println("✅ SQLite database connection successful")
	}
}

func DBMigrate() {
	if err := DB.AutoMigrate(
		&model.HealthWorker{},
		&model.Department{},
		&model.PersonnelType{},
		&model.Patient{},
		&model.MedicationHistory{},
		&model.Session{},
		&model.Diagnosis{},
		&model.Phq9Question{},
		&model.Phq9Response{},
		&model.SessionSummary{},
		&model.Message{},
	); err != nil {
		log.Fatalf("❌ Error migrating database: %v\n", err)
	} else {
		log.Println("✅ Database migration successful")
	}
}
