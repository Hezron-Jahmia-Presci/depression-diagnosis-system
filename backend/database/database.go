package database

import (
	"depression-diagnosis-system/database/model"
	"fmt"
	"log"
	"os"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB
var err error

func Conn() {
	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=disable",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_PORT"),
	)

	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("❌ Failed to connect to database: %v\n", err)
	} else {
		log.Println("✅ Database connection successful")
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




