package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/middleware"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"
	"fmt"
	"strings"
)

type HealthWorkerController struct{}

func NewHealthWorkerController() interfaces.HealthWorkerInterface {
	return &HealthWorkerController{}
}

// CreateHealthWorker registers a new health worker (admin or not)
func (c *HealthWorkerController) CreateHealthWorker(hw *model.HealthWorker) (*model.HealthWorker, error) {
	if !util.IsValidEmail(hw.Email) {
		return nil, errors.New("invalid email format")
	}

	var exists model.HealthWorker
	if err := database.DB.Where("email = ?", hw.Email).First(&exists).Error; err == nil {
		return nil, errors.New("a health worker with this email already exists")
	}

	// Generate unique employee ID based on department
	var department model.Department
	if err := database.DB.First(&department, hw.DepartmentID).Error; err != nil {
		return nil, errors.New("invalid department ID")
	}
	hw.EmployeeID = util.GenerateEmployeeID(department.Name)

	// Assign default role if not explicitly set
	if hw.Role == "" {
		hw.Role = model.RoleHealthWorker
	}

	if err := database.DB.Create(hw).Error; err != nil {
		return nil, err
	}
	return hw, nil
}

// GetHealthWorkerByID retrieves a single health worker by ID
func (c *HealthWorkerController) GetHealthWorkerByID(id uint) (*model.HealthWorker, error) {
	var hw model.HealthWorker
	if err := database.DB.Preload("Department").Preload("PersonnelType").Preload("Supervisor").
		First(&hw, id).Error; err != nil {
		return nil, err
	}
	return &hw, nil
}

// GetAllHealthWorkers fetches all registered health workers
func (c *HealthWorkerController) GetAllHealthWorkers() ([]model.HealthWorker, error) {
	var workers []model.HealthWorker
	if err := database.DB.Preload("Department").Preload("PersonnelType").Preload("Supervisor").
		Find(&workers).Error; err != nil {
		return nil, err
	}
	return workers, nil
}

// UpdateHealthWorker updates the profile of a health worker
func (c *HealthWorkerController) UpdateHealthWorker(id uint, updated *model.HealthWorker) (*model.HealthWorker, error) {
	var hw model.HealthWorker
	if err := database.DB.First(&hw, id).Error; err != nil {
		return nil, err
	}

	if updated.Email != "" && !util.IsValidEmail(updated.Email) {
		return nil, errors.New("invalid email format")
	}

	hw.FirstName = updated.FirstName
	hw.LastName = updated.LastName
	hw.Email = updated.Email
	hw.Address = updated.Address
	hw.Contact = updated.Contact
	hw.JobTitle = updated.JobTitle
	hw.Bio = updated.Bio
	hw.Qualification = updated.Qualification
	hw.EducationLevel = updated.EducationLevel
	hw.YearsOfPractice = updated.YearsOfPractice
	hw.DepartmentID = updated.DepartmentID
	hw.PersonnelTypeID = updated.PersonnelTypeID
	hw.SupervisorID = updated.SupervisorID

	if updated.Role != "" {
		hw.Role = strings.ToLower(updated.Role)
	}

	if err := database.DB.Save(&hw).Error; err != nil {
		return nil, err
	}
	return &hw, nil
}

// DeleteHealthWorker deletes a health worker record
func (c *HealthWorkerController) DeleteHealthWorker(id uint) error {
	var hw model.HealthWorker
	if err := database.DB.First(&hw, id).Error; err != nil {
		return err
	}
	return database.DB.Delete(&hw).Error
}

// GetHealthWorkersByDepartment retrieves all workers in a specific department
func (c *HealthWorkerController) GetHealthWorkersByDepartment(departmentID uint) ([]model.HealthWorker, error) {
	var workers []model.HealthWorker
	if err := database.DB.
		Preload("Department").Preload("PersonnelType").
		Where("department_id = ?", departmentID).Find(&workers).Error; err != nil {
		return nil, err
	}
	return workers, nil
}

// GetHealthWorkerByEmail retrieves a health worker by email
func (c *HealthWorkerController) GetHealthWorkerByEmail(email string) (*model.HealthWorker, error) {
	var hw model.HealthWorker
	if err := database.DB.Where("email = ?", email).First(&hw).Error; err != nil {
		return nil, err
	}
	return &hw, nil
}

func (c *HealthWorkerController) SetActiveStatus(id uint, active bool) (*model.HealthWorker, error) {
    var hw model.HealthWorker
    if err := database.DB.First(&hw, id).Error; err != nil {
        return nil, err
    }

    hw.IsActive = active

    if err := database.DB.Save(&hw).Error; err != nil {
        return nil, err
    }

    return &hw, nil
}


// Login authenticates a health worker using email or employee ID and returns a token
func (c *HealthWorkerController) Login(identifier string, password string) (*model.HealthWorker, error) {
	var hw model.HealthWorker

	query := database.DB.Where("email = ?", identifier)
	if strings.Contains(identifier, "-EMP-") {
		query = database.DB.Where("employee_id = ?", identifier)
	}
	if err := query.First(&hw).Error; err != nil {
		return nil, errors.New("invalid email or employee ID")
	}

	if err := query.First(&hw).Error; err != nil {
		return nil, errors.New("invalid email or employee ID")
	}
	
	if !hw.IsActive {
		return nil, errors.New("account is deactivated")
	}

	return &hw, nil
}

// Logout blacklists the token, preventing further use
func (c *HealthWorkerController) Logout(token string) error {
	if err := middleware.InvalidateToken(token); err != nil {
		return fmt.Errorf("failed to log out: %v", err)
	}
	return nil
}

func (c *HealthWorkerController) SearchHealthWorkers(
    queryParams map[string]string,
) ([]model.HealthWorker, error) {
    var workers []model.HealthWorker
    dbQuery := database.DB.Preload("Department").Preload("PersonnelType").Preload("Supervisor")

    if name, ok := queryParams["name"]; ok && name != "" {
        likePattern := "%" + name + "%"
        dbQuery = dbQuery.Where("first_name ILIKE ? OR last_name ILIKE ?", likePattern, likePattern)
    }

    if email, ok := queryParams["email"]; ok && email != "" {
        dbQuery = dbQuery.Where("email = ?", email)
    }

    if employeeID, ok := queryParams["employee_id"]; ok && employeeID != "" {
        dbQuery = dbQuery.Where("employee_id = ?", employeeID)
    }

    if role, ok := queryParams["role"]; ok && role != "" {
        dbQuery = dbQuery.Where("role = ?", role)
    }

    if deptID, ok := queryParams["department_id"]; ok && deptID != "" {
        dbQuery = dbQuery.Where("department_id = ?", deptID)
    }

    if activeStr, ok := queryParams["is_active"]; ok && activeStr != "" {
        // assuming is_active is a boolean field in model
        switch activeStr {
		case "true":
            dbQuery = dbQuery.Where("is_active = ?", true)
        case "false":
            dbQuery = dbQuery.Where("is_active = ?", false)
        }
    }

    err := dbQuery.Find(&workers).Error
    if err != nil {
        return nil, err
    }

    return workers, nil
}
