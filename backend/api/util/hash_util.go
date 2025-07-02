package util

import (
	"regexp"

	"golang.org/x/crypto/bcrypt"
)

func HashPassword(password string) (string, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(hashedPassword), nil
}

func CheckPassword(hashedPassword, password string) bool {
	return bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(password)) == nil
}

func IsValidPassword(password string) bool {
	const passwordRegex = `^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*.,?]).{8,}$`
	matched, _ := regexp.MatchString(passwordRegex, password)
	return matched
}


func IsValidEmail(email string) bool {
	const emailRegex = `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
	matched, _ := regexp.MatchString(emailRegex, email)
	return matched
}

func IsValidUsername(username string) bool {
	const usernameRegex = `^[a-zA-Z0-9_]{3,20}$`
	matched, _ := regexp.MatchString(usernameRegex, username)
	return matched
}

