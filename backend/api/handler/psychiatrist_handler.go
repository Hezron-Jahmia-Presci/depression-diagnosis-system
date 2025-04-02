package handler

import (
	"depression-diagnosis-system/api/controller"
	interfaces "depression-diagnosis-system/api/interface"
	"depression-diagnosis-system/api/util"

	"net/http"

	"github.com/gin-gonic/gin"
)

type PsychiatristHandler struct {
	PsychiatristController interfaces.PsychiatristInterface
}

func NewPsychiatristHandler() *PsychiatristHandler {
	return &PsychiatristHandler{
		PsychiatristController: controller.NewPsychiatristController(),
	}
}

func (ph *PsychiatristHandler) RegisterPsych(c *gin.Context) {
	var psych struct {
		FirstName string `json:"firstName" binding:"required"`
		LastName  string `json:"lastName" binding:"required"`
		Email     string `json:"email" binding:"required,email"`
		Password  string `json:"password" binding:"required,min=6"`
	}

	if err := c.ShouldBindJSON(&psych); err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status: http.StatusBadRequest,
			Message: "error:" + err.Error(),
		})
		return
	}

	createdPsych, err := ph.PsychiatristController.RegisterPsych(psych.FirstName,psych.LastName,psych.Email, psych.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":    "Psychiatrist registered successfully",
		"psychiatrist": gin.H{
			"id":        createdPsych.ID,
			"firstName": createdPsych.FirstName,
			"lastName":  createdPsych.LastName,
			"email":     createdPsych.Email,
		},
	})
}

func (ph *PsychiatristHandler) LoginPsych(c *gin.Context){
	var logginRequest struct {
		Email 	 string `json:"email" binding:"required"`
		Password string `json:"password" binding:"required"`
	}

	if err := c.ShouldBindJSON(&logginRequest); err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status: http.StatusBadRequest,
			Message: "error:" + err.Error(),
		})
		return
	}

	token, err := ph.PsychiatristController.LoginPsych(logginRequest.Email, logginRequest.Password) 
	if err != nil {
		c.JSON(http.StatusUnauthorized, util.ResponseStructure{
			Status:  http.StatusUnauthorized,
			Message: "error: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"token":   token,
		
	})

}

func (ph *PsychiatristHandler) LogoutPsych(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing token"})
		return
	}

	err := ph.PsychiatristController.LogoutPsych(token)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Logged out successfully"})
}

func (ph *PsychiatristHandler) GetPsychiatristDetails(c *gin.Context) {
	psychID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusNotFound, util.ResponseStructure{
			Status:  http.StatusNotFound,
			Message: "error: not found",
		})
		return
	}

	psych, err := ph.PsychiatristController.GetPsychiatristDetails(psychID.(uint))

	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: could not retrieve session",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"psych": psych})
}

func (ph *PsychiatristHandler) UpdatePsychiatrist(c *gin.Context) {
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

	psychID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusNotFound, util.ResponseStructure{
			Status:  http.StatusNotFound,
			Message: "error: not found",
		})
		return
	}

	psych, err := ph.PsychiatristController.UpdatePsychiatrist(psychID.(uint), request.FirstName, request.LastName, request.Email)
	
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
			"id":        psych.ID,
			"firstName": psych.FirstName,
			"lastName":  psych.LastName,
			"email":     psych.Email,
		},
	})
}

func (ph *PsychiatristHandler) GetAllPsychiatrists(c *gin.Context) {
	psych, err := ph.PsychiatristController.GetAllPsychiatrists()
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: could not retrieve psychiatrist",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"psych": psych})
}