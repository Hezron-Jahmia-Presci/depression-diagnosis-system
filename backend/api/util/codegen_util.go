package util

import (
	"fmt"
	"math/rand"
	"strings"
)

// GeneratePatientCode generates a unique patient code using the department name and a random or sequential number.
// Example: "Depression" -> "DEP-8371"
func GeneratePatientCode(departmentName string) string {
	// Get first 3 uppercase letters from the department name
	prefix := strings.ToUpper(departmentName)
	if len(prefix) > 3 {
		prefix = prefix[:3]
	}

	// Append a random 4-digit number (can change to timestamp or sequential from DB if needed)
	suffix := rand.Intn(9000) + 1000 // Ensures 4-digit number
	return fmt.Sprintf("%s-%d", prefix, suffix)
}

// GenerateSessionCode creates a session code based on department name.
// Example: "Depression" → "DEP-S-7482"
func GenerateSessionCode(departmentName string) string {
	prefix := strings.ToUpper(departmentName)
	if len(prefix) > 3 {
		prefix = prefix[:3]
	}

	suffix := rand.Intn(9000) + 1000 // random 4-digit number

	return fmt.Sprintf("%s-S-%d", prefix, suffix)
}

// GenerateEmployeeID creates a unique employee ID e.g. DEP-EMP-9283
func GenerateEmployeeID(departmentName string) string {
	prefix := strings.ToUpper(departmentName)
	if len(prefix) > 3 {
		prefix = prefix[:3]
	}
	suffix := rand.Intn(9000) + 1000
	return fmt.Sprintf("%s-EMP-%d", prefix, suffix)
}

