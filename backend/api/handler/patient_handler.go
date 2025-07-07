package handler

import (
	"net/http"
	"strconv"

	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database/model"

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
	// Get the user's personnel type from context
	ptypeI, exists := c.Get("userPersonnelType")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Unauthorized"})
		return
	}

	ptype, ok := ptypeI.(string)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Invalid personnel type"})
		return
	}

	// Define allowed types
	allowedTypes := map[string]bool{
		"admin":            true,
		"psychiatrist":     true,
		"psychologist":     true,
		"clinical_officer": true,
	}

	// Check permission
	if !allowedTypes[ptype] {
		c.JSON(http.StatusForbidden, gin.H{"message": "Not allowed to register patients"})
		return
	}

	// Bind and validate input
	var input model.Patient
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
		return
	}

	// Call controller to create patient
	createdPatient, err := ph.PatientController.CreatePatient(&input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create patient: " + err.Error()})
		return
	}

	// Respond
	c.JSON(http.StatusCreated, gin.H{
		"message": "Patient created successfully",
		"patient": createdPatient,
	})
}


func (ph *PatientHandler) GetPatientByID(c *gin.Context) {
	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	patient, err := ph.PatientController.GetPatientByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Patient not found: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"patient": patient})
}

func (ph *PatientHandler) GetAllPatients(c *gin.Context) {
	patients, err := ph.PatientController.GetAllPatients()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to retrieve patients: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"patients": patients})
}

func (ph *PatientHandler) UpdatePatient(c *gin.Context) {
	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	var updated model.Patient
	if err := c.ShouldBindJSON(&updated); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
		return
	}

	patient, err := ph.PatientController.UpdatePatient(id, &updated)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update patient: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Patient updated successfully",
		"patient": patient,
	})
}

func (ph *PatientHandler) DeletePatient(c *gin.Context) {
	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	if err := ph.PatientController.DeletePatient(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to delete patient: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Patient deleted successfully"})
}

func (ph *PatientHandler) GetPatientsByHealthWorker(c *gin.Context) {
	healthWorkerID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Missing heakth wirker ID",
		})
		return
	}

	patients, err := ph.PatientController.GetPatientsByHealthWorker(healthWorkerID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to retrieve patients: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"patients": patients})
}

func (ph *PatientHandler) GetPatientByHealthWorker(c *gin.Context) {
	patientID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil || patientID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid patient ID",
		})
		return
	}

	healthWorkerID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Missing health worker ID",
		})
		return
	}
	patient, err := ph.PatientController.GetPatientByHealthWorker(healthWorkerID.(uint), uint(patientID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Patient not found: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"patient": patient})
}

func (ph *PatientHandler) GetPatientsByDepartment(c *gin.Context) {
	deptID, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid department ID"})
		return
	}

	patients, err := ph.PatientController.GetPatientsByDepartment(deptID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to retrieve patients: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"patients": patients})
}

func (ph *PatientHandler) SetActiveStatus(c *gin.Context) {
    id, err := util.GetIDParam(c)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid patient ID"})
        return
    }

    var body struct {
        IsActive bool `json:"is_active"`
    }
    if err := c.ShouldBindJSON(&body); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
        return
    }

    patient, err := ph.PatientController.SetActiveStatus(id, body.IsActive)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update status: " + err.Error()})
        return
    }

    status := "deactivated"
    if body.IsActive {
        status = "activated"
    }

    c.JSON(http.StatusOK, gin.H{
        "message": "Patient " + status + " successfully",
        "patient": patient,
    })
}

func (ph *PatientHandler) SearchPatients(c *gin.Context) {
	 // Extract query params
    queryParams := map[string]string{
        "name":          c.Query("name"),
        "email":         c.Query("email"),
        "patient_id":    c.Query("patient_id"),
        "department_id": c.Query("department_id"),
        "is_active":     c.Query("is_active"),
    }

    patients, err := ph.PatientController.SearchPatients(queryParams)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to search patients: " + err.Error()})
        return
    }

    c.JSON(http.StatusOK, gin.H{"patients": patients})
}
