package handler

import (
	"net/http"
	"strings"

	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/middleware"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database/model"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

type HealthWorkerHandler struct {
	HealthWorkerController interfaces.HealthWorkerInterface
}

func NewHealthWorkerHandler() *HealthWorkerHandler {
	return &HealthWorkerHandler{
		HealthWorkerController: controller.NewHealthWorkerController(),
	}
}

// helper to parse "id" URL param to uint

func (hwh *HealthWorkerHandler) CreateHealthWorker(c *gin.Context) {
    role, exists := c.Get("userRole")
    if !exists || role != model.RoleAdmin {
        c.JSON(http.StatusForbidden, gin.H{"message": "Only admins can create health workers"})
        return
    }

    var input model.HealthWorker
    if err := c.ShouldBindJSON(&input); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
        return
    }

    createdHW, err := hwh.HealthWorkerController.CreateHealthWorker(&input)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create health worker: " + err.Error()})
        return
    }

    c.JSON(http.StatusCreated, gin.H{
        "message": "Health worker created successfully",
        "health_worker": createdHW,
    })
}


func (hwh *HealthWorkerHandler) GetHealthWorkerByID(c *gin.Context) {
	healthworkerID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Admin ID not provided",
		})
		return
	}
	
	hw, err := hwh.HealthWorkerController.GetHealthWorkerByID(healthworkerID.(uint))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"status":  http.StatusNotFound,
			"message": "Health worker not found: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":       http.StatusOK,
		"health_worker": hw,
	})
}

func (hwh *HealthWorkerHandler) GetAllHealthWorkers(c *gin.Context) {
	workers, err := hwh.HealthWorkerController.GetAllHealthWorkers()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve health workers: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":         http.StatusOK,
		"health_workers": workers,
	})
}

func (hwh *HealthWorkerHandler) UpdateHealthWorker(c *gin.Context) {
	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	var updated model.HealthWorker
	if err := c.ShouldBindJSON(&updated); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	hw, err := hwh.HealthWorkerController.UpdateHealthWorker(id, &updated)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to update health worker: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"message": "Health worker updated successfully",
		"health_worker": gin.H{
			"id":        hw.ID,
			"firstName": hw.FirstName,
			"lastName":  hw.LastName,
			"email":     hw.Email,
			"role":      hw.Role,
		},
	})
}

func (hwh *HealthWorkerHandler) DeleteHealthWorker(c *gin.Context) {
	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	if err := hwh.HealthWorkerController.DeleteHealthWorker(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to delete health worker: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"message": "Health worker deleted successfully",
	})
}

func (hwh *HealthWorkerHandler) SetActiveStatus(c *gin.Context) {
    id, err := util.GetIDParam(c)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
        return
    }

    var payload struct {
        IsActive bool `json:"is_active"`
    }

    if err := c.ShouldBindJSON(&payload); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input"})
        return
    }

    hw, err := hwh.HealthWorkerController.SetActiveStatus(id, payload.IsActive)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update status: " + err.Error()})
        return
    }

    status := "deactivated"
    if hw.IsActive {
        status = "activated"
    }

    c.JSON(http.StatusOK, gin.H{
        "message": "Health worker account " + status + " successfully",
        "health_worker": hw,
    })
}


// Login authenticates a health worker by email or employee ID
func (hwh *HealthWorkerHandler) Login(c *gin.Context) {
	var input struct {
		Identifier string `json:"identifier" binding:"required"` // email or employee ID
		Password   string `json:"password" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid login input: " + err.Error()})
		return
	}

	hw, err := hwh.HealthWorkerController.Login(input.Identifier, input.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Authentication failed: " + err.Error()})
		return
	}

	// Validate password
	if err := bcrypt.CompareHashAndPassword([]byte(hw.PasswordHash), []byte(input.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Incorrect password"})
		return
	}

	// Generate token
	token, err := middleware.GenerateToken(hw.ID, hw.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Token generation failed: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Login successful",
		"token":   token,
		"health_worker": gin.H{
			"id":         hw.ID,
			"first_name": hw.FirstName,
			"last_name":  hw.LastName,
			"email":      hw.Email,
			"employeeID": hw.EmployeeID,
			"role":       hw.Role,
		},
	})
}

// Logout invalidates a JWT token
func (hwh *HealthWorkerHandler) Logout(c *gin.Context) {
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Authorization header is missing"})
		return
	}

	token := strings.TrimPrefix(authHeader, "Bearer ")
	if token == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Token is missing"})
		return
	}

	err := hwh.HealthWorkerController.Logout(token)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Logout failed: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Logout successful"})
}

func (hwh *HealthWorkerHandler) SearchHealthWorkers(c *gin.Context) {
    // Extract query params
    queryParams := map[string]string{
        "name":          c.Query("name"),
        "email":         c.Query("email"),
        "employee_id":   c.Query("employee_id"),
        "role":          c.Query("role"),
        "department_id": c.Query("department_id"),
        "is_active":     c.Query("is_active"),
    }

    workers, err := hwh.HealthWorkerController.SearchHealthWorkers(queryParams)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"message": "Search failed: " + err.Error()})
        return
    }

    c.JSON(http.StatusOK, gin.H{"health_workers": workers})
}
