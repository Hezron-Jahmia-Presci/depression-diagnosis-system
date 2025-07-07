package routes

import (
	"depression-diagnosis-system/api/handler"
	"depression-diagnosis-system/api/middleware"

	"github.com/gin-gonic/gin"
)

func Routes(router *gin.Engine) {
	// Initialize handlers
	patientHandler := handler.NewPatientHandler()
	healthWorkerHandler := handler.NewHealthWorkerHandler()
	personnelTypeHandler := handler.NewPersonnelTypeHandler()
	phq9QuestionHandler := handler.NewPhq9QuestionHandler()
	phq9ResponseHandler := handler.NewPhq9ResponseHandler()
	diagnosisHandler := handler.NewDiagnosisHandler()
	sessionHandler := handler.NewSessionHandler()
	summaryHandler := handler.NewSessionSummaryHandler()

	// ------------------- Health Worker Routes -------------------
	healthRoutes := router.Group("/api/v1/health-workers")
	healthRoutes.POST("/login", healthWorkerHandler.Login)
	healthRoutes.Use(middleware.AuthMiddleware())
	{
		healthRoutes.POST("/create", healthWorkerHandler.CreateHealthWorker)
		healthRoutes.GET("/all", healthWorkerHandler.GetAllHealthWorkers)
		healthRoutes.GET("/me", healthWorkerHandler.GetHealthWorkerByID)
		healthRoutes.PUT("/:id", healthWorkerHandler.UpdateHealthWorker)
		healthRoutes.DELETE("/:id", healthWorkerHandler.DeleteHealthWorker)
		healthRoutes.PUT("/:id/active", healthWorkerHandler.SetActiveStatus)
		healthRoutes.POST("/logout", middleware.AuthMiddleware(), healthWorkerHandler.Logout)
		healthRoutes.GET("/search", healthWorkerHandler.SearchHealthWorkers)

	}

	// ------------------- Personnel Type Routes -------------------
	ptRoutes := router.Group("/api/v1/personnel-types")
	ptRoutes.Use(middleware.AuthMiddleware())
	{
		ptRoutes.POST("/create", personnelTypeHandler.CreatePersonnelType)
		ptRoutes.GET("/all", personnelTypeHandler.GetAllPersonnelTypes)
		ptRoutes.GET("/:id", personnelTypeHandler.GetPersonnelTypeByID)
		ptRoutes.DELETE("/:id", personnelTypeHandler.DeletePersonnelType)
		ptRoutes.GET("/searcch", personnelTypeHandler.SearchPersonnelType)
	}

	// ------------------- Patient Routes -------------------
	patientRoutes := router.Group("/api/v1/patients")
	patientRoutes.Use(middleware.AuthMiddleware())
	{
		patientRoutes.POST("/create", patientHandler.CreatePatient)
		patientRoutes.GET("/all", patientHandler.GetAllPatients)
		patientRoutes.GET("/:id", patientHandler.GetPatientByID)
		patientRoutes.PUT("/:id", patientHandler.UpdatePatient)
		patientRoutes.DELETE("/:id", patientHandler.DeletePatient)

		patientRoutes.GET("/by-healthworker/:id", patientHandler.GetPatientsByHealthWorker)                  // GET /patients/by-healthworker/:id
		patientRoutes.GET("/by-healthworker-specific/me", patientHandler.GetPatientByHealthWorker)
		patientRoutes.GET("/by-department/:id", patientHandler.GetPatientsByDepartment)                      // GET /patients/by-department/:id
		patientRoutes.PUT("/:id/active", patientHandler.SetActiveStatus)
    	patientRoutes.GET("/search", patientHandler.SearchPatients)   
	}

	// ------------------- PHQ-9 Question Routes -------------------
	qRoutes := router.Group("/api/v1/phq9/questions")
	qRoutes.Use(middleware.AuthMiddleware())
	{
		qRoutes.POST("/create", phq9QuestionHandler.CreateQuestion)
		qRoutes.GET("/all", phq9QuestionHandler.GetAllQuestions)
		qRoutes.GET("/:id", phq9QuestionHandler.GetQuestionByID)
		qRoutes.DELETE("/:id", phq9QuestionHandler.DeleteQuestion)
	}

	// ------------------- PHQ-9 Response Routes -------------------
	rRoutes := router.Group("/api/v1/phq9/responses")
	rRoutes.Use(middleware.AuthMiddleware())
	{
		rRoutes.POST("/create", phq9ResponseHandler.CreateResponse)
		rRoutes.GET("/:id", phq9ResponseHandler.GetResponseBySessionID)
		rRoutes.PUT("/:id", phq9ResponseHandler.UpdateResponse)
		rRoutes.DELETE("/:id", phq9ResponseHandler.DeleteResponse)
	}

	// ------------------- Diagnosis Routes -------------------
	diagnosisRoutes := router.Group("/api/v1/diagnosis")
	diagnosisRoutes.Use(middleware.AuthMiddleware())
	{
		diagnosisRoutes.POST("/:id", diagnosisHandler.CreateDiagnosis)
		diagnosisRoutes.GET("/:id", diagnosisHandler.GetDiagnosisBySessionID)
	}

	// ------------------- Session Routes -------------------
	sessionRoutes := router.Group("/api/v1/sessions")
	sessionRoutes.Use(middleware.AuthMiddleware())
	{
		sessionRoutes.POST("/create", sessionHandler.CreateSession)
		sessionRoutes.GET("/all", sessionHandler.GetAllSessions)
		sessionRoutes.GET("/:id", sessionHandler.GetSessionByID)
		sessionRoutes.GET("/healthworker/me", sessionHandler.GetSessionsByHealthWorker)
		sessionRoutes.PUT("/:id", sessionHandler.UpdateSession)
		sessionRoutes.DELETE("/:id", sessionHandler.DeleteSession)
		sessionRoutes.GET("/code/:code", sessionHandler.GetSessionByCode)
		sessionRoutes.PUT("/status", sessionHandler.UpdateSessionStatus)
		sessionRoutes.GET("/patient/:id", sessionHandler.GetSessionsByPatient)
		sessionRoutes.GET("/Search", sessionHandler.SearchSessions)
	
	}

	// ------------------- Session Summary Routes -------------------
	summaryRoutes := router.Group("/api/v1/session-summaries")
	summaryRoutes.Use(middleware.AuthMiddleware())
	{
		summaryRoutes.POST("/create", summaryHandler.CreateSummary)
		summaryRoutes.GET("/:id", summaryHandler.GetSummaryBySessionID)
		summaryRoutes.PUT("/:id", summaryHandler.UpdateSummary)
		summaryRoutes.DELETE("/:id", summaryHandler.DeleteSummary)
	}

	// ------------------- Department Routes -------------------
	departmentHandler := handler.NewDepartmentHandler()
	deptRoutes := router.Group("/api/v1/departments")
	deptRoutes.Use(middleware.AuthMiddleware())
	{
		deptRoutes.POST("/create", departmentHandler.CreateDepartment)
		deptRoutes.GET("/all", departmentHandler.GetAllDepartments)
		deptRoutes.GET("/:id", departmentHandler.GetDepartmentByID)
		deptRoutes.PUT("/:id", departmentHandler.UpdateDepartment)
		deptRoutes.DELETE("/:id", departmentHandler.DeleteDepartment)
		deptRoutes.GET("/search", departmentHandler.SearchDepartments)
	}

	// ------------------- Medication History Routes -------------------
	medicationHistoryHandler := handler.NewMedicationHistoryHandler()
	medicationHistoryRoutes := router.Group("/api/v1/medication-history")
	medicationHistoryRoutes.Use(middleware.AuthMiddleware())
	{
		medicationHistoryRoutes.POST("/create", medicationHistoryHandler.CreateMedicationHistory)
		medicationHistoryRoutes.GET("/all", medicationHistoryHandler.GetAllMedicationHistories)
		medicationHistoryRoutes.GET("/:id", medicationHistoryHandler.GetMedicationHistoryByID)
		medicationHistoryRoutes.PUT("/:id", medicationHistoryHandler.UpdateMedicationHistory)
		medicationHistoryRoutes.DELETE("/:id", medicationHistoryHandler.DeleteMedicationHistory)
		medicationHistoryRoutes.GET("/search", medicationHistoryHandler.SearchMedicationHistories)
	}
}
