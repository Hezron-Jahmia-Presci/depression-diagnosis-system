package handler

import (
	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database/model"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type PatientHandler struct {
	PatientController interfaces.PatientInterface
}

func NewPatientHandler() *PatientHandler {
	return &PatientHandler{
		PatientController: controller.NewPatientController(),
	}
}

func (ph *PatientHandler) CreatePatient(c *gin.Context) {
	// Step 1: Define input struct
	var req struct {
		FirstName string `json:"first_name" binding:"required"`
		LastName  string `json:"last_name" binding:"required"`
		Email     string `json:"email" binding:"required,email"`
	}

	// Step 2: Bind JSON
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	// Step 3: Get psychiatrist ID from context
	psychID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"status":  http.StatusUnauthorized,
			"message": "Unauthorized access",
		})
		return
	}

	// Step 4: Build patient model
	patient := &model.Patient{
		FirstName:      req.FirstName,
		LastName:       req.LastName,
		Email:          req.Email,
		PsychiatristID: psychID.(uint),
	}

	// Step 5: Create patient
	created, err := ph.PatientController.CreatePatient(patient)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to create patient: " + err.Error(),
		})
		return
	}

	// Step 6: Return response
	c.JSON(http.StatusCreated, gin.H{
		"status":  http.StatusCreated,
		"message": "Patient registered successfully",
		"patient": gin.H{
			"id":        created.ID,
			"firstName": created.FirstName,
			"lastName":  created.LastName,
			"email":     created.Email,
		},
	})
}


func (ph *PatientHandler) GetAllPatients(c *gin.Context) {
	patients, err := ph.PatientController.GetAllPatients()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve patients: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":   http.StatusOK,
		"patients": patients,
	})
}

func (ph *PatientHandler) GetPatientsByPsychiatrist(c *gin.Context) {
	psychID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Missing psychiatrist ID",
		})
		return
	}

	patients, err := ph.PatientController.GetPatientsByPsychiatrist(psychID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve patients: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":   http.StatusOK,
		"patients": patients,
	})
}

func (ph *PatientHandler) GetPatientByID(c *gin.Context) {
	patientID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil || patientID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid patient ID",
		})
		return
	}

	patient, err := ph.PatientController.GetPatientByID(uint(patientID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve patient: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"patient": patient,
	})
}

func (ph *PatientHandler) GetPatientByPsychiatrist(c *gin.Context) {
	patientID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil || patientID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid patient ID",
		})
		return
	}

	psychID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Missing psychiatrist ID",
		})
		return
	}

	patient, err := ph.PatientController.GetPatientByPsychiatrist(psychID.(uint), uint(patientID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve patient: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"patient": patient,
	})
}

func (ph *PatientHandler) UpdatePatient(c *gin.Context) {
	var updatedPatient model.Patient

	if err := c.ShouldBindJSON(&updatedPatient); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	patientID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Missing patient ID",
		})
		return
	}

	patient, err := ph.PatientController.UpdatePatient(patientID.(uint), &updatedPatient)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to update patient: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"message": "Patient updated successfully",
		"patient": gin.H{
			"id":        patient.ID,
			"firstName": patient.FirstName,
			"lastName":  patient.LastName,
			"email":     patient.Email,
		},
	})
}

func (ph *PatientHandler) DeletePatient(c *gin.Context) {
	patientID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil || patientID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid patient ID",
		})
		return
	}

	err = ph.PatientController.DeletePatient(uint(patientID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to delete patient: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"message": "Patient deleted successfully",
	})
}
