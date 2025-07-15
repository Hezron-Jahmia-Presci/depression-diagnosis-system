package util

import (
	cryptorand "crypto/rand"
	"encoding/hex"
	"fmt"
	"math/rand"
	"strings"
)

// GeneratePatientCode generates a unique patient code using department name and a random 4-digit number.
func GeneratePatientCode(departmentName string) string {
	prefix := strings.ToUpper(departmentName)
	if len(prefix) > 3 {
		prefix = prefix[:3]
	}
	suffix := rand.Intn(9000) + 1000
	return fmt.Sprintf("%s-%d", prefix, suffix)
}

// GenerateSessionCode creates a short unique session code like "DEP-S-c7c1c134".
func GenerateSessionCode(departmentName string) string {
	prefix := strings.ToUpper(departmentName)
	if len(prefix) > 3 {
		prefix = prefix[:3]
	}

	randomBytes := make([]byte, 4) // 4 bytes = 8 hex characters
	if _, err := cryptorand.Read(randomBytes); err != nil {
		panic("failed to generate session code: " + err.Error())
	}
	suffix := hex.EncodeToString(randomBytes)

	return fmt.Sprintf("%s-S-%s", prefix, suffix)
}

// GenerateEmployeeID creates a unique employee ID like "DEP-EMP-9283"
func GenerateEmployeeID(departmentName string) string {
	prefix := strings.ToUpper(departmentName)
	if len(prefix) > 3 {
		prefix = prefix[:3]
	}
	suffix := rand.Intn(9000) + 1000
	return fmt.Sprintf("%s-EMP-%d", prefix, suffix)
}
