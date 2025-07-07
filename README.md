# Depression Diagnosis System (DDS)

A smart clinical tool designed to aid in the mental health screening and diagnosis of depression. Developed as part of a case study at **Butabika National Referral Hospital**, the DDS provides structured digital assessments and session tracking to support psychiatrists and mental health professionals.

## 🧠 Purpose
The system helps streamline mental health diagnosis by providing:
- PHQ-9-based digital screening tools
- Patient and session management interfaces
- Health worker and departmental coordination tools
- Medication history tracking
- Admin and health worker dashboards

## 🛠️ Technologies Used

| Layer         | Technology         |
|---------------|--------------------|
| Frontend      | Flutter            |
| Backend       | Golang (Gin)       |
| Containerization | Docker          |
| Automation    | Makefile           |

## 📦 Project Structure

```plaintext
.
├── backend/                  # Golang Gin API
├── frontend/                 # Flutter app
└── README.md                 # Project overview
```

## 🚀 Getting Started

### Requirements
- Docker & Docker Compose
- Make
- Flutter SDK (3.10+)
- Go 1.20+

### Commands

```bash
# Start services using Docker
make up

# Stop all services
make down

# Run backend manually
cd backend && go run main.go

# Run Flutter frontend (web/desktop/mobile)
cd frontend && flutter run -d chrome # or windows, macos, etc.
```

## 👥 Authors & Acknowledgments

Special thanks to the team at **Butabika National Referral Hospital** for their collaboration and feedback during the system design and evaluation.

## 📄 License

This project is licensed under the MIT License.
