package handler

import (
	"depression-diagnosis-system/api/controller"
	interfaces "depression-diagnosis-system/api/interface"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database"
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

func (ph *PatientHandler) RegisterPatient(c *gin.Context) {
	var request struct {
		FirstName string `json:"firstName" binding:"required"`
		LastName  string `json:"lastName" binding:"required"`
		Email     string `json:"email" binding:"required,email"`
		Password  string `json:"password" binding:"required,min=6"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "error: " + err.Error(),
		})
		return
	}

	psychID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusNotFound, util.ResponseStructure{
			Status:  http.StatusNotFound,
			Message: "error: not found",
		})
		return
	}

	var psych model.Psychiatrist
	if err := database.DB.First(&psych, psychID).Error; err != nil {
		c.JSON(http.StatusUnauthorized, util.ResponseStructure{
			Status:  http.StatusUnauthorized,
			Message: "error: unauthorized - psychiatrist not found",
		})
		return
	}

	createdPatient, err := ph.PatientController.RegisterPatient(
		request.FirstName, request.LastName, request.Email, request.Password, psychID.(uint),
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Patient registered successfully",
		"patient": gin.H{
			"id":        createdPatient.ID,
			"firstName": createdPatient.FirstName,
			"lastName":  createdPatient.LastName,
			"email":     createdPatient.Email,
		},
	})
}


func (ph *PatientHandler) GetPatientsByPsychiatrist(c *gin.Context) {
	psychID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusNotFound, util.ResponseStructure{
			Status:  http.StatusNotFound,
			Message: "error: not found",
		})
		return
	}

	patients, err := ph.PatientController.GetPatientsByPsychiatrist(psychID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: could not retrieve patients",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"patients": patients})
}


func (ph *PatientHandler) GetAllPatients(c *gin.Context) {
	patients, err := ph.PatientController.GetAllPatients()
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: could not retrieve patients",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"patients": patients})
}

func (ph *PatientHandler) GetPateintDetailsByPsychiatirst(c *gin.Context) {
	patientID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "Invalid patient ID",
		})
		return
	}


	psychID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusNotFound, util.ResponseStructure{
			Status:  http.StatusNotFound,
			Message: "error: not found",
		})
		return
	}

	var psych model.Psychiatrist
	if err := database.DB.First(&psych, psychID).Error; err != nil {
		c.JSON(http.StatusUnauthorized, util.ResponseStructure{
			Status:  http.StatusUnauthorized,
			Message: "error: unauthorized - psychiatrist not found",
		})
		return
	}

	patient, err := ph.PatientController.GetPateintDetailsByPsychiatirst(psychID.(uint), uint(patientID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"patient": patient})
}

func(ph *PatientHandler) GetPatientDetailsByID(c *gin.Context) {
	patientID, exists := c.Get("userID")
		if !exists {
		c.JSON(http.StatusNotFound, util.ResponseStructure{
			Status:  http.StatusNotFound,
			Message: "error: not found",
		})
		return
	}

	patient, err := ph.PatientController.GetPatientDetailsByID(patientID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: could not retrieve session",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"patient": patient})
}

func (ph *PatientHandler) UpdatePatient(c* gin.Context) {
	var request struct {
		FirstName string `json:"firstName" binding:"required"`
		LastName  string `json:"lastName" binding:"required"`
		Email     string `json:"email" binding:"required,email"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "error: " + err.Error(),
		})
		return
	}

	patientID, exists := c.Get("userID")
		if !exists {
		c.JSON(http.StatusNotFound, util.ResponseStructure{
			Status:  http.StatusNotFound,
			Message: "error: not found",
		})
		return
	}


	patient, err := ph.PatientController.UpdatePatient(patientID.(uint), request.FirstName, request.LastName, request.Email)

	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: " + err.Error(),
		})
		return
	}

		c.JSON(http.StatusOK, gin.H{
		"message":    "Psychiatrist details updated successfully",
		"psychiatrist": gin.H{
			"id":        patient.ID,
			"firstName": patient.FirstName,
			"lastName":  patient.LastName,
			"email":     patient.Email,
		},
	})
}