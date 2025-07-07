package handler

import (
	"net/http"
	"strings"

	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database/model"

	"github.com/gin-gonic/gin"
)

type PersonnelTypeHandler struct {
	PersonnelTypeController interfaces.PersonnelTypeInterface
}

func NewPersonnelTypeHandler() *PersonnelTypeHandler {
	return &PersonnelTypeHandler{
		PersonnelTypeController: controller.NewPersonnelTypeController(),
	}
}


// CreatePersonnelType adds a new personnel type (admin only)
func (pth *PersonnelTypeHandler) CreatePersonnelType(c *gin.Context) {
	role, exists := c.Get("userRole")
	if !exists || role != model.RoleAdmin {
		c.JSON(http.StatusForbidden, gin.H{"message": "Only admins can create personnel types"})
		return
	}

	var input model.PersonnelType
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
		return
	}

	// Normalize name to lower trimmed inside controller but good to trim here too
	input.Name = strings.TrimSpace(strings.ToLower(input.Name))

	createdPT, err := pth.PersonnelTypeController.CreatePersonnelType(&input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create personnel type: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":         "Personnel type created successfully",
		"personnel_type": createdPT,
	})
}

// GetAllPersonnelTypes returns all personnel types (no RBAC restriction)
func (pth *PersonnelTypeHandler) GetAllPersonnelTypes(c *gin.Context) {
	types, err := pth.PersonnelTypeController.GetAllPersonnelTypes()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to retrieve personnel types: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"personnel_types": types,
	})
}

// GetPersonnelTypeByID fetches a personnel type by ID (no RBAC)
func (pth *PersonnelTypeHandler) GetPersonnelTypeByID(c *gin.Context) {
	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	pt, err := pth.PersonnelTypeController.GetPersonnelTypeByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Personnel type not found: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"personnel_type": pt,
	})
}

// DeletePersonnelType deletes a personnel type by ID (admin only)
func (pth *PersonnelTypeHandler) DeletePersonnelType(c *gin.Context) {
	role, exists := c.Get("userRole")
	if !exists || role != model.RoleAdmin {
		c.JSON(http.StatusForbidden, gin.H{"message": "Only admins can delete personnel types"})
		return
	}

	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	if err := pth.PersonnelTypeController.DeletePersonnelType(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to delete personnel type: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Personnel type deleted successfully",
	})
}

//Search PersonnelType

func (pth *PersonnelTypeHandler) SearchPersonnelType(c *gin.Context) {
	 // Extract query params
	 queryParams := map[string]string{
        "name":          c.Query("name"),
    }

    pt, err := pth.PersonnelTypeController.SearchPersonnelType(queryParams)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to search patients: " + err.Error()})
        return
    }

    c.JSON(http.StatusOK, gin.H{"personnel_types": pt})
}
