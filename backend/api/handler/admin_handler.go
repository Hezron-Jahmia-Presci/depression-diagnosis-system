package handler

import (
	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database/model"
	"net/http"

	"github.com/gin-gonic/gin"
)

type AdminHandler struct {
	AdminController interfaces.AdminInterface
}

func NewAdminHandler() *AdminHandler {
	return &AdminHandler{
		AdminController: controller.NewAdminController(),
	}
}

func (ah *AdminHandler) CreateAdmin(c *gin.Context) {
	// Temporary struct for binding user input
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

	// Manually create the admin model and hash password
	hashedPassword, err := util.HashPassword(input.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to hash password: " + err.Error(),
		})
		return
	}

	admin := model.Admin{
		FirstName:    input.FirstName,
		LastName:     input.LastName,
		Email:        input.Email,
		PasswordHash: hashedPassword, // keep using this field name
	}

	createdAdmin, err := ah.AdminController.CreateAdmin(&admin)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to create admin: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"status":  http.StatusCreated,
		"message": "Admin created successfully",
		"admin": gin.H{
			"id":        createdAdmin.ID,
			"firstName": createdAdmin.FirstName,
			"lastName":  createdAdmin.LastName,
			"email":     createdAdmin.Email,
		},
	})
}


func (ah *AdminHandler) GetAdminByID(c *gin.Context) {
	adminID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Admin ID not provided",
		})
		return
	}

	admin, err := ah.AdminController.GetAdminByID(adminID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve admin: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": http.StatusOK,
		"admin":  admin,
	})
}

func (ah *AdminHandler) UpdateAdmin(c *gin.Context) {
	var updatedAdmin model.Admin

	if err := c.ShouldBindJSON(&updatedAdmin); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	adminID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Admin ID not provided",
		})
		return
	}

	admin, err := ah.AdminController.UpdateAdmin(adminID.(uint), &updatedAdmin)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to update admin: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"message": "Admin updated successfully",
		"admin": gin.H{
			"id":        admin.ID,
			"firstName": admin.FirstName,
			"lastName":  admin.LastName,
			"email":     admin.Email,
		},
	})
}

func (ah *AdminHandler) DeleteAdmin(c *gin.Context) {
	adminID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Admin ID not provided",
		})
		return
	}

	err := ah.AdminController.DeleteAdmin(adminID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to delete admin: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"message": "Admin deleted successfully",
	})
}

func (ah *AdminHandler) LogInAdmin(c *gin.Context) {
	var loginData struct {
		Email    string `json:"email" binding:"required,email"`
		Password string `json:"password" binding:"required"`
	}

	if err := c.ShouldBindJSON(&loginData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid login data: " + err.Error(),
		})
		return
	}

	token, err := ah.AdminController.LogInAdmin(loginData.Email, loginData.Password)
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

func (ah *AdminHandler) LogOutAdmin(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Authorization token is required",
		})
		return
	}

	if err := ah.AdminController.LogOutAdmin(token); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Logout failed: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"message": "Logout successful",
	})
}
