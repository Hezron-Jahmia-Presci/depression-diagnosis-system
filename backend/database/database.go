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
		&model.Psychiatrist{},
		&model.Patient{},
		&model.Session{},
		&model.SessionSummary{},
		&model.Phq9Question{},
		&model.Phq9Response{},
		&model.Diagnosis{},
		); err != nil {
		log.Fatalf("❌ Error migrating database: %v\n", err)
	} else {
		log.Println("✅ Database migration successful")
	}
}



func SeedPHQ9Questions() {
    questions := []model.Phq9Question{
        {Question: "Little interest or pleasure in doing things?"},
        {Question: "Feeling down, depressed, or hopeless?"},
        {Question: "Trouble falling or staying asleep, or sleeping too much?"},
        {Question: "Feeling tired or having little energy?"},
        {Question: "Poor appetite or overeating?"},
        {Question: "Feeling bad about yourself — or that you are a failure or have let yourself or your family down?"},
        {Question: "Trouble concentrating on things, such as reading the newspaper or watching television?"},
        {Question: "Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual?"},
        {Question: "Thoughts that you would be better off dead, or of hurting yourself in some way?"},
    }

    for _, question := range questions {
        var existing model.Phq9Question
		result := DB.Where("question = ?", question.Question).First(&existing)
        if result.Error != nil {
            DB.Create(&question) 
        }
    }

}