package util

import (
	"os"
	"time"

	"github.com/sirupsen/logrus"
)

var Logger *logrus.Logger

func InitLogger() {
	Logger = logrus.New()

	if _, err := os.Stat("logs"); os.IsNotExist(err) {
		os.Mkdir("logs", 0755)
	}

	logFile, err := os.OpenFile("logs/system.log", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err != nil {
		Logger.Fatalf("Failed to open log file: %v", err)
	}

	Logger.SetOutput(logFile)

	Logger.SetFormatter(&logrus.JSONFormatter{
		TimestampFormat: time.RFC3339, 
	})
	Logger.SetLevel(logrus.InfoLevel)
}

func LogError(err error, message string) {
	if err != nil {
		Logger.WithError(err).Error(message)
	}
}
