package database

import (
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database/model"
	"fmt"
	"log"
	"time"
)

func RunAllSeeders() {
	SeedDepartments()
	SeedPersonnelTypes()
	SeedPHQ9Questions()
	SeedAdminUser()
	SeedHealthWorkers()
	SeedDummyPatients()
	SeedMessages()
}

func SeedDepartments() {
	departments := []struct {
		Name        string
		Description string
	}{
		{
			Name:        "Psychiatry",
			Description: "Responsible for diagnosing and treating mental illnesses through medical interventions including medication and hospitalization.",
		},
		{
			Name:        "Psychology & Counseling",
			Description: "Focuses on therapeutic approaches for emotional, behavioral, and psychological well-being through talk therapy and counseling.",
		},
		{
			Name:        "Addiction Services",
			Description: "Provides treatment and support for individuals dealing with substance abuse and behavioral addictions.",
		},
		{
			Name:        "Child & Adolescent Mental Health",
			Description: "Specializes in the mental health needs of children and teenagers, including developmental and emotional disorders.",
		},
		{
			Name:        "Forensic Psychiatry",
			Description: "Combines psychiatry and legal assessment, dealing with patients involved in the criminal justice system.",
		},
		{
			Name:        "General Medicine",
			Description: "Covers non-psychiatric physical health concerns and provides general medical care for inpatients and outpatients.",
		},
	}

	for _, dept := range departments {
		record := model.Department{Name: dept.Name}
		DB.FirstOrCreate(&record, model.Department{Name: dept.Name})
		DB.Model(&record).Update("description", dept.Description)
		log.Printf("🏥 Department seeded: %s", dept.Name)
	}
}


func SeedPersonnelTypes() {
	personnelTypes := []struct {
		Name        string
	}{
		{
			Name:        "Psychiatrist",
		},
		{
			Name:        "Psychologist",
		},
		{
			Name:        "Clinical Officer",
		},
		{
			Name:        "Nurse",
		},
		{
			Name:        "Midwife",
		},
		{
			Name:        "Admin",
		},
	}

	for _, p := range personnelTypes {
		record := model.PersonnelType{Name: p.Name}
		DB.FirstOrCreate(&record, model.PersonnelType{Name: p.Name})
		log.Printf("👨‍⚕️ PersonnelType seeded: %s", p.Name)
	}
}


func SeedPHQ9Questions() {
	questions := []string{
		"Little interest or pleasure in doing things?",
		"Feeling down, depressed, or hopeless?",
		"Trouble falling or staying asleep, or sleeping too much?",
		"Feeling tired or having little energy?",
		"Poor appetite or overeating?",
		"Feeling bad about yourself — or that you are a failure or have let yourself or your family down?",
		"Trouble concentrating on things, such as reading the newspaper or watching television?",
		"Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual?",
		"Thoughts that you would be better off dead, or of hurting yourself in some way?",
	}
	for _, text := range questions {
		var existing model.Phq9Question
		if err := DB.Where("question = ?", text).First(&existing).Error; err != nil {
			DB.Create(&model.Phq9Question{Question: text})
		}
	}
}

func SeedAdminUser() {
	type AdminSeedData struct {
		FirstName, LastName, Email, JobTitle, Dept, PersonnelType string
	}

	data := AdminSeedData{
		FirstName:     "Super",
		LastName:      "Admin",
		Email:         "admin@example.com",
		JobTitle:      "System Administrator",
		Dept:          "General Medicine",
		PersonnelType: "Admin",
	}

	var dept model.Department
	var ptype model.PersonnelType
	DB.Where("name = ?", data.Dept).First(&dept)
	DB.Where("name = ?", data.PersonnelType).First(&ptype)

	var existing model.HealthWorker
	DB.Where("role = ?", model.RoleAdmin).First(&existing)
	if existing.ID != 0 {
		log.Println("⚠️ Admin already exists")
		return
	}

	hashed, _ := util.HashPassword("StrongPassword123!")
	admin := model.HealthWorker{
		FirstName:       data.FirstName,
		LastName:        data.LastName,
		Email:           data.Email,
		PasswordHash:    hashed,
		Role:            model.RoleAdmin,
		EmployeeID:      util.GenerateEmployeeID(dept.Name),
		DepartmentID:    dept.ID,
		PersonnelTypeID: ptype.ID,
		JobTitle:        data.JobTitle,
		Address:         "Admin HQ",
		Contact:         "+256000000000",
		Qualification:   "MSc Health Systems",
		EducationLevel:  "Master's",
		YearsOfPractice: 10,
		Bio:             "System-level admin user for managing all access.",
		ImageURL:        "",
	}

	if err := DB.Create(&admin).Error; err != nil {
		log.Fatalf("❌ Failed to create admin: %v", err)
	}
	log.Println("✅ Admin user seeded")
}


func SeedHealthWorkers() {
	var admin model.HealthWorker
	DB.Where("role = ?", model.RoleAdmin).First(&admin)

	workers := []struct {
		FirstName, LastName, Email, Personnel, JobTitle, Dept string
	}{
		{"John", "Psych", "john.psych@example.com", "Psychiatrist", "Senior Psychiatrist", "Psychiatry"},
		{"Jane", "Doe", "jane.doe@example.com", "Psychologist", "Clinical Psychologist", "Psychology & Counseling"},
		{"Clara", "Nurse", "clara.nurse@example.com", "Nurse", "Mental Health Nurse", "Addiction Services"},
		{"Derek", "Mid", "derek.mid@example.com", "Midwife", "Maternal Health Officer", "Child & Adolescent Mental Health"},
		{"Tim", "Forensic", "tim.forensic@example.com", "Clinical Officer", "Forensic Specialist", "Forensic Psychiatry"},
		{"Rita", "Child", "rita.child@example.com", "Psychologist", "Child Therapist", "Child & Adolescent Mental Health"},
		{"Evan", "Counsel", "evan.counsel@example.com", "Psychologist", "Counseling Psychologist", "Psychology & Counseling"},
		{"Liam", "Support", "liam.support@example.com", "Nurse", "Support Nurse", "Addiction Services"},
	}

	for _, w := range workers {
		var existing model.HealthWorker
		if err := DB.Where("email = ?", w.Email).First(&existing).Error; err == nil {
			continue
		}

		var dept model.Department
		var ptype model.PersonnelType
		DB.Where("name = ?", w.Dept).First(&dept)
		DB.Where("name = ?", w.Personnel).First(&ptype)

		hashed, _ := util.HashPassword("StrongPassword123!")
		hw := model.HealthWorker{
			FirstName:       w.FirstName,
			LastName:        w.LastName,
			Email:           w.Email,
			PasswordHash:    hashed,
			Role:            model.RoleHealthWorker,
			EmployeeID:      util.GenerateEmployeeID(dept.Name),
			DepartmentID:    dept.ID,
			PersonnelTypeID: ptype.ID,
			SupervisorID:    &admin.ID,
			JobTitle:        w.JobTitle,
			Address:         "Hospital Block B",
			Contact:         "+256776000000",
			Qualification:   "MBChB",
			EducationLevel:  "Bachelor's",
			YearsOfPractice: 3 + time.Now().Second()%7,
			Bio:             fmt.Sprintf("%s in %s department", w.JobTitle, dept.Name),
			ImageURL:        "",
		}

		if err := DB.Create(&hw).Error; err != nil {
			log.Printf("❌ Failed to seed %s %s: %v", w.FirstName, w.LastName, err)
		} else {
			log.Printf("✅ Health worker seeded: %s %s (%s)", w.FirstName, w.LastName, w.JobTitle)
		}
	}
}

func SeedDummyPatients() {
	var healthWorkers []model.HealthWorker
	DB.Where("role = ?", model.RoleHealthWorker).Find(&healthWorkers)

	if len(healthWorkers) == 0 {
		log.Println("⚠️ Cannot seed patients — no health workers found")
		return
	}

	patients := []model.Patient{
		{
			FirstName: "Sarah", LastName: "Nantongo", Email: "sarah.n@example.com", Gender: "Female",
			DateOfBirth: time.Date(1994, 1, 15, 0, 0, 0, 0, time.UTC), NationalID: "CF940115123456",
			Description: "Presented with depressive symptoms and suicidal ideation",
			AdmissionDate: time.Now(), PatientCode: "Dd-201", PreviousDiagnosis: "Major Depressive Disorder",
		},
		{
			FirstName: "James", LastName: "Okello", Email: "james.o@example.com", Gender: "Male",
			DateOfBirth: time.Date(1985, 6, 22, 0, 0, 0, 0, time.UTC), NationalID: "CM850622987654",
			Description: "Mood swings, insomnia, and low concentration",
			AdmissionDate: time.Now(), PatientCode: "Dd-202", PreviousDiagnosis: "Bipolar Disorder",
		},
		{
			FirstName: "Annet", LastName: "Kirabo", Email: "annet.k@example.com", Gender: "Female",
			DateOfBirth: time.Date(1990, 4, 3, 0, 0, 0, 0, time.UTC), NationalID: "CF900403456789",
			Description: "Postnatal depression after second child",
			AdmissionDate: time.Now(), PatientCode: "Dd-203", PreviousDiagnosis: "Postpartum Depression",
		},
		{
			FirstName: "Daniel", LastName: "Mugisha", Email: "daniel.m@example.com", Gender: "Male",
			DateOfBirth: time.Date(2000, 10, 5, 0, 0, 0, 0, time.UTC), NationalID: "CM001005654321",
			Description: "Referred from university clinic with severe anxiety",
			AdmissionDate: time.Now(), PatientCode: "Dd-204", PreviousDiagnosis: "Generalized Anxiety Disorder",
		},
		{
			FirstName: "Agnes", LastName: "Nakato", Email: "agnes.n@example.com", Gender: "Female",
			DateOfBirth: time.Date(1995, 3, 21, 0, 0, 0, 0, time.UTC), NationalID: "UG950321789012",
			Description: "Persistent mood swings and sleep disturbance", 
			AdmissionDate: time.Now(), PatientCode: "Dd-205", PreviousDiagnosis: "Bipolar II Disorder",
		},
		{
			FirstName: "Brian", LastName: "Okello", Email: "brian.o@example.com", Gender: "Male",
			DateOfBirth: time.Date(1987, 8, 14, 0, 0, 0, 0, time.UTC), NationalID: "UG870814123456",
			Description: "History of alcohol use disorder and aggression", 
			AdmissionDate: time.Now(), PatientCode: "Dd-206", PreviousDiagnosis: "Alcohol Dependence",
		},
		{
			FirstName: "Sarah", LastName: "Kintu", Email: "sarah.k@example.com", Gender: "Female",
			DateOfBirth: time.Date(2002, 12, 30, 0, 0, 0, 0, time.UTC), NationalID: "UG021230987654",
			Description: "Reported suicidal ideation after breakup", 
			AdmissionDate: time.Now(), PatientCode: "Dd-207", PreviousDiagnosis: "Major Depressive Disorder",
		},
		{
			FirstName: "Paul", LastName: "Nsubuga", Email: "paul.n@example.com", Gender: "Male",
			DateOfBirth: time.Date(1975, 6, 18, 0, 0, 0, 0, time.UTC), NationalID: "UG750618246810",
			Description: "Referred from prison facility for assessment", 
			AdmissionDate: time.Now(), PatientCode: "Dd-208", PreviousDiagnosis: "Antisocial Personality Disorder",
		},
		{
			FirstName: "Grace", LastName: "Namubiru", Email: "grace.n@example.com", Gender: "Female",
			DateOfBirth: time.Date(1999, 1, 9, 0, 0, 0, 0, time.UTC), NationalID: "UG990109345678",
			Description: "Multiple panic attacks in last two weeks", 
			AdmissionDate: time.Now(), PatientCode: "Dd-209", PreviousDiagnosis: "Panic Disorder",
		},
		{
			FirstName: "Samuel", LastName: "Kaggwa", Email: "samuel.k@example.com", Gender: "Male",
			DateOfBirth: time.Date(1984, 11, 2, 0, 0, 0, 0, time.UTC), NationalID: "UG841102654321",
			Description: "Hallucinations and delusions reported", 
			AdmissionDate: time.Now(), PatientCode: "Dd-210", PreviousDiagnosis: "Paranoid Schizophrenia",
		},
		{
			FirstName: "Martha", LastName: "Lugoloobi", Email: "martha.l@example.com", Gender: "Female",
			DateOfBirth: time.Date(2005, 7, 17, 0, 0, 0, 0, time.UTC), NationalID: "UG050717112233",
			Description: "Referral from school counselor after trauma disclosure", 
			AdmissionDate: time.Now(), PatientCode: "Dd-211", PreviousDiagnosis: "PTSD",
		},
		{
			FirstName: "Joseph", LastName: "Tumwesigye", Email: "joseph.t@example.com", Gender: "Male",
			DateOfBirth: time.Date(1992, 4, 3, 0, 0, 0, 0, time.UTC), NationalID: "UG920403556677",
			Description: "Recurrent depressive episodes with social withdrawal", 
			AdmissionDate: time.Now(), PatientCode: "Dd-212", PreviousDiagnosis: "Recurrent Depressive Disorder",
		},
		{
			FirstName: "Beatrice", LastName: "Mbabazi", Email: "beatrice.m@example.com", Gender: "Female",
			DateOfBirth: time.Date(1968, 2, 25, 0, 0, 0, 0, time.UTC), NationalID: "UG680225443322",
			Description: "Disorientation and memory loss symptoms", 
			AdmissionDate: time.Now(), PatientCode: "Dd-213", PreviousDiagnosis: "Dementia (Early Onset)",
		},
	}

	for i := range patients {
		hw := healthWorkers[i%len(healthWorkers)]
		patients[i].AdmittedByID = hw.ID
		patients[i].DepartmentID = hw.DepartmentID
	}

	for _, p := range patients {
		var existing model.Patient
		if err := DB.Where("national_id = ?", p.NationalID).First(&existing).Error; err == nil {
			continue // Skip if patient already exists
		}

		if err := DB.Create(&p).Error; err == nil {
			log.Printf("✅ Patient %s %s seeded", p.FirstName, p.LastName)

			medications := []model.MedicationHistory{
				{
					PatientID:           p.ID,
					Prescription:        "Fluoxetine 20mg once daily",
					PrescribingDoctorID: &p.AdmittedByID,
					HealthCenter:        "Butabika Psychiatry Ward",
				},
			}

			if p.FirstName == "Daniel" || p.FirstName == "Sarah" {
				medications = append(medications, model.MedicationHistory{
					PatientID:             p.ID,
					Prescription:          "Haloperidol 5mg daily",
					HealthCenter:          "Mulago Clinic",
					ExternalDoctorName:    "Dr. Kibuuka",
					ExternalDoctorContact: "+256772000888",
				})
			}

			for _, m := range medications {
				if err := DB.Create(&m).Error; err == nil {
					log.Printf("🩺 Medication for %s: %s", p.FirstName, m.Prescription)
				}
			}
		}
	}
}

func SeedMessages() {
	var healthWorkers []model.HealthWorker
	// Get all health workers excluding admins, to seed messages between them
	if err := DB.Where("role = ?", model.RoleHealthWorker).Find(&healthWorkers).Error; err != nil {
		log.Printf("❌ Failed to load health workers for seeding messages: %v", err)
		return
	}

	if len(healthWorkers) < 2 {
		log.Println("⚠️ Not enough health workers to seed messages")
		return
	}

	messages := []string{
		"Hello, how are you today?",
		"Can you update me on the patient in room 5?",
		"Please review the latest lab results when you have time.",
		"Do you have availability for a case discussion tomorrow?",
		"Thanks for your support during the last session.",
		"Could you share the treatment plan document?",
		"Let's coordinate on the follow-up appointments.",
		"Have you seen the new hospital guidelines?",
		"I'm forwarding the patient files for your review.",
		"Please let me know if you need any assistance.",
	}

	now := time.Now()

	// We'll create messages between pairs in a simple pattern
	for i := 0; i < len(healthWorkers)-1; i++ {
		sender := healthWorkers[i]
		receiver := healthWorkers[i+1]

		for j, text := range messages {
			msg := model.Message{
				SenderID:   sender.ID,
				ReceiverID: receiver.ID,
				Message:    text,
				Timestamp:  now.Add(time.Duration(j) * time.Minute),
			}
			if err := DB.Create(&msg).Error; err != nil {
				log.Printf("❌ Failed to create message from %s to %s: %v", sender.Email, receiver.Email, err)
			} else {
				log.Printf("✉️ Message seeded from %s to %s: %s", sender.Email, receiver.Email, text)
			}
		}
	}
}

