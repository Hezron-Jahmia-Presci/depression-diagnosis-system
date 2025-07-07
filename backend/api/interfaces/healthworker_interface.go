package interfaces

import "depression-diagnosis-system/database/model"

type HealthWorkerInterface interface {
	CreateHealthWorker(hw *model.HealthWorker) (*model.HealthWorker, error)
	GetHealthWorkerByID(id uint) (*model.HealthWorker, error)
	GetAllHealthWorkers() ([]model.HealthWorker, error)
	UpdateHealthWorker(id uint, updated *model.HealthWorker) (*model.HealthWorker, error)
	DeleteHealthWorker(id uint) error

	// Optional helpers
	GetHealthWorkersByDepartment(departmentID uint) ([]model.HealthWorker, error)
	GetHealthWorkerByEmail(email string) (*model.HealthWorker, error)
	SetActiveStatus(id uint, active bool) (*model.HealthWorker, error)
	Login(identifier string, password string) (*model.HealthWorker, error)
	Logout(token string) error

	SearchHealthWorkers(queryParams map[string]string) ([]model.HealthWorker, error)
}
