package handler

import (
	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database/model"
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

func (ph *PsychiatristHandler) CreatePsychiatrist(c *gin.Context) {
	// Temporary struct for input binding
	var input struct {
		FirstName string `json:"first_name" binding:"required"`
		LastName  string `json:"last_name" binding:"required"`
		Email     string `json:"email" binding:"required,email"`
		Password  string `json:"password" binding:"required"`
	}
	

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	// Hash the password
	hashedPassword, err := util.HashPassword(input.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to hash password: " + err.Error(),
		})
		return
	}

	// Manually construct the model
	psych := model.Psychiatrist{
		FirstName:    input.FirstName,
		LastName:     input.LastName,
		Email:        input.Email,
		PasswordHash: hashedPassword,
	}

	// Call the controller
	createdPsych, err := ph.PsychiatristController.CreatePsychiatrist(&psych)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to create psychiatrist: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"status":  http.StatusCreated,
		"message": "Psychiatrist created successfully",
		"psychiatrist": gin.H{
			"id":        createdPsych.ID,
			"firstName": createdPsych.FirstName,
			"lastName":  createdPsych.LastName,
			"email":     createdPsych.Email,
		},
	})
}


func (ph *PsychiatristHandler) GetPsychiatristByID(c *gin.Context) {
	psychID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"status":  http.StatusUnauthorized,
			"message": "Unauthorized access",
		})
		return
	}

	psych, err := ph.PsychiatristController.GetPsychiatristByID(psychID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve psychiatrist: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":       http.StatusOK,
		"psychiatrist": psych,
	})
}

func (ph *PsychiatristHandler) GetAllPsychiatrists(c *gin.Context) {
	psychs, err := ph.PsychiatristController.GetAllPsychiatrists()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve psychiatrists: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":       http.StatusOK,
		"psychiatrists": psychs,
	})
}

func (ph *PsychiatristHandler) UpdatePsychiatrist(c *gin.Context) {
	var updated model.Psychiatrist

	if err := c.ShouldBindJSON(&updated); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	psychID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"status":  http.StatusUnauthorized,
			"message": "Unauthorized access",
		})
		return
	}

	psych, err := ph.PsychiatristController.UpdatePsychiatrist(psychID.(uint), &updated)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to update psychiatrist: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"message": "Psychiatrist updated successfully",
		"psychiatrist": gin.H{
			"id":        psych.ID,
			"firstName": psych.FirstName,
			"lastName":  psych.LastName,
			"email":     psych.Email,
		},
	})
}

func (ph *PsychiatristHandler) DeletePsychiatrist(c *gin.Context) {
	psychID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"status":  http.StatusUnauthorized,
			"message": "Unauthorized access",
		})
		return
	}

	if err := ph.PsychiatristController.DeletePsychiatrist(psychID.(uint)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to delete psychiatrist: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"message": "Psychiatrist deleted successfully",
	})
}

func (ph *PsychiatristHandler) LogInPsychiatrist(c *gin.Context) {
	var loginData struct {
		Email    string `json:"email" binding:"required,email"`
		Password string `json:"password" binding:"required"`
	}

	if err := c.ShouldBindJSON(&loginData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	token, err := ph.PsychiatristController.LogInPsychiatrist(loginData.Email, loginData.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"status":  http.StatusUnauthorized,
			"message": "Login failed: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"message": "Login successful",
		"token":   token,
	})
}

func (ph *PsychiatristHandler) LogOutPsychiatrist(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Authorization token is required",
		})
		return
	}

	if err := ph.PsychiatristController.LogOutPsychiatrist(token); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to log out: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"message": "Logged out successfully",
	})
}
