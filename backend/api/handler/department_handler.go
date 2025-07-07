package handler

import (
	"net/http"

	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database/model"

	"github.com/gin-gonic/gin"
)

type DepartmentHandler struct {
	DepartmentController interfaces.DepartmentInterface
}

func NewDepartmentHandler() *DepartmentHandler {
	return &DepartmentHandler{
		DepartmentController: controller.NewDepartmentController(),
	}
}

// CreateDepartment allows only admins to create departments
func (dh *DepartmentHandler) CreateDepartment(c *gin.Context) {
	role, exists := c.Get("userRole")
	if !exists || role != model.RoleAdmin {
		c.JSON(http.StatusForbidden, gin.H{"message": "Only admins can create departments"})
		return
	}

	var input model.Department
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
		return
	}

	createdDept, err := dh.DepartmentController.CreateDepartment(&input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create department: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":    "Department created successfully",
		"department": createdDept,
	})
}

// GetDepartmentByID returns department by ID
func (dh *DepartmentHandler) GetDepartmentByID(c *gin.Context) {
	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid department ID"})
		return
	}

	dept, err := dh.DepartmentController.GetDepartmentByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Department not found: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"department": dept,
	})
}

// GetAllDepartments returns a list of all departments
func (dh *DepartmentHandler) GetAllDepartments(c *gin.Context) {
	departments, err := dh.DepartmentController.GetAllDepartments()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to retrieve departments: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"departments": departments,
	})
}

// UpdateDepartment allows only admins to update departments
func (dh *DepartmentHandler) UpdateDepartment(c *gin.Context) {
	role, exists := c.Get("userRole")
	if !exists || role != model.RoleAdmin {
		c.JSON(http.StatusForbidden, gin.H{"message": "Only admins can update departments"})
		return
	}

	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid department ID"})
		return
	}

	var input model.Department
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
		return
	}

	updatedDept, err := dh.DepartmentController.UpdateDepartment(id, &input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update department: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "Department updated successfully",
		"department": updatedDept,
	})
}

// DeleteDepartment allows only admins to delete departments
func (dh *DepartmentHandler) DeleteDepartment(c *gin.Context) {
	role, exists := c.Get("userRole")
	if !exists || role != model.RoleAdmin {
		c.JSON(http.StatusForbidden, gin.H{"message": "Only admins can delete departments"})
		return
	}

	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid department ID"})
		return
	}

	if err := dh.DepartmentController.DeleteDepartment(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to delete department: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Department deleted successfully"})
}

// GetDepartmentByName returns department by name
func (dh *DepartmentHandler) GetDepartmentByName(c *gin.Context) {
	name := c.Query("name")
	if name == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Department name is required"})
		return
	}

	dept, err := dh.DepartmentController.GetDepartmentByName(name)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Department not found: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"department": dept,
	})
}

func (dh *DepartmentHandler) SearchDepartments (c *gin.Context) {
	 // Extract query params
	 queryParams := map[string]string{
        "name":          c.Query("name"),
       
    }

    dept, err := dh.DepartmentController.SearchDepartments(queryParams)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to search departments: " + err.Error()})
        return
    }

    c.JSON(http.StatusOK, gin.H{"departments": dept})
}
