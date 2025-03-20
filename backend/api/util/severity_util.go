package util

func DetermineSeverity(phq9Score int) string {
	switch {
	case phq9Score >= 1 && phq9Score <= 9:
		return "Minimal/No Depression"
	case phq9Score >= 10 && phq9Score <= 18:
		return "Mild Depression"
	case phq9Score >= 19 && phq9Score <= 27:
		return "Moderate Depression"
	case phq9Score >= 28 && phq9Score <= 36:
		return "Moderately Severe Depression"
	case phq9Score >= 37 && phq9Score <= 45:
		return "Severe Depression"
	default:
		return "Unknown"
	}
}