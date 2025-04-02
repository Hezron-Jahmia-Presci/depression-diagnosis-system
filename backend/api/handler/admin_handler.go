package handler

import (
	"depression-diagnosis-system/api/controller"
	interfaces "depression-diagnosis-system/api/interface"
	"depression-diagnosis-system/api/util"

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

func (ah *AdminHandler) RegisterAdmin(c *gin.Context) {
	var admin struct {
		FirstName string `json:"firstName" binding:"required"`
		LastName  string `json:"lastName" binding:"required"`
		Email     string `json:"email" binding:"required,email"`
		Password  string `json:"password" binding:"required,min=6"`
	}

	if err := c.ShouldBindJSON(&admin); err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status: http.StatusBadRequest,
			Message: "error:" + err.Error(),
		})
		return
	}

	createdAdmin, err := ah.AdminController.RegisterAdmin(admin.FirstName,admin.LastName,admin.Email, admin.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":    "Admin registered successfully",
		"psychiatrist": gin.H{
			"id":        createdAdmin.ID,
			"firstName": createdAdmin.FirstName,
			"lastName":  createdAdmin.LastName,
			"email":     createdAdmin.Email,
		},
	})
}

func (ah *AdminHandler) LoginAdmin(c *gin.Context){
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

	token, err := ah.AdminController.LoginAdmin(logginRequest.Email, logginRequest.Password) 
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

func (ah *AdminHandler) LogoutAdmin(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing token"})
		return
	}

	err := ah.AdminController.LogoutAdmin(token)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Logged out successfully"})
}

func (ah *AdminHandler) GetAdminDetails(c *gin.Context) {
	adminID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusNotFound, util.ResponseStructure{
			Status:  http.StatusNotFound,
			Message: "error: not found",
		})
		return
	}

	admin, err := ah.AdminController.GetAdminDetails(adminID.(uint))

	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: could not retrieve session",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"admin": admin})
}

func (ah *AdminHandler) UpdateAdmin(c *gin.Context) {
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

	adminID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusNotFound, util.ResponseStructure{
			Status:  http.StatusNotFound,
			Message: "error: not found",
		})
		return
	}

	admin, err := ah.AdminController.UpdateAdmin(adminID.(uint), request.FirstName, request.LastName, request.Email)
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: " + err.Error(),
		})
		return
	}

		c.JSON(http.StatusOK, gin.H{
		"message":    "Admin details updated successfully",
		"psychiatrist": gin.H{
			"id":        admin.ID,
			"firstName": admin.FirstName,
			"lastName":  admin.LastName,
			"email":     admin.Email,
		},
	})

}

