# Bano Qabil Student App

A role-based learning management application developed with **Flutter and Firebase** to digitize and streamline the student learning journey — from course enrollment and classroom participation to assignments, academic progress, and career readiness.

---

## Overview

The **Bano Qabil Student App** provides a centralized platform for managing interactions between students, instructors, and coordinators.

The application is designed around three role-based experiences:

* **Student** — access courses, batches, schedules, attendance, assignments, academic progress, and career readiness.
* **Instructor** — manage students, attendance, assignments, submissions, marks, and feedback.
* **Coordinator** — manage applications, courses, campuses, batches, instructors, and notices.

The application uses **Firebase Authentication** for secure authentication, **Cloud Firestore** for structured application data, and **Firebase Storage** for file and profile-image management.

---

## Core Features

### Student

* Secure authentication and profile management
* Course and batch information
* Assigned instructor information
* Class timetable
* Attendance tracking
* Assignment management
* Assignment submission
* Submission status
* Marks and instructor feedback
* Course and module progress
* Career readiness tracking
* Notices and notifications

### Instructor

* Instructor dashboard
* Assigned batch management
* Student management
* Attendance management
* Assignment creation and management
* Submission review
* Marks and feedback
* Student progress monitoring

### Coordinator

* Student application management
* Application status tracking
* Course management
* Campus management
* Batch creation and management
* Batch capacity and enrollment management
* Instructor assignment
* Notice management

---

## Technology Stack

| Category                | Technology              |
| ----------------------- | ----------------------- |
| Framework               | Flutter                 |
| Language                | Dart                    |
| Authentication          | Firebase Authentication |
| Database                | Cloud Firestore         |
| File Storage            | Firebase Storage        |
| Version Control         | Git & GitHub            |
| Development Environment | Android Studio          |

---

## Architecture & Development

The application follows a structured Flutter architecture with separate layers for application configuration, core utilities, models, services, and feature-specific modules.

Key development practices include:

* Role-based navigation
* Reusable UI components
* Service-based Firebase integration
* Model-based Firestore data handling
* Firebase security rules
* Responsive layouts
* Loading, empty, and error states
* Form validation
* Structured state management
* Git-based version control

---

## Firebase Data Structure

The application uses Cloud Firestore collections for the major application modules:

```text
users
courses
campuses
batches
applications
attendance
assignments
submissions
notices
notifications
course_modules
career_progress
module_progress
```

Firebase Storage is used for profile images and application-related files.

---

## Application Screenshots

### Authentication

| Login                                  | Registration                                 |
| -------------------------------------- | -------------------------------------------- |
| ![Login](assets/screenshots/login.png) | ![Register](assets/screenshots/register.png) |

### Student

| Dashboard                                                 | Courses                                    |
| --------------------------------------------------------- | ------------------------------------------ |
| ![Student Dashboard](assets/screenshots/student_home.png) | ![Courses](assets/screenshots/courses.png) |

| Timetable                                      | Attendance                                       |
| ---------------------------------------------- | ------------------------------------------------ |
| ![Timetable](assets/screenshots/timetable.png) | ![Attendance](assets/screenshots/attendance.png) |

| Assignments                                        | Progress                                     |
| -------------------------------------------------- | -------------------------------------------- |
| ![Assignments](assets/screenshots/assignments.png) | ![Progress](assets/screenshots/progress.png) |

| Career Progress                                            | Profile                                    |
| ---------------------------------------------------------- | ------------------------------------------ |
| ![Career Progress](assets/screenshots/career_progress.png) | ![Profile](assets/screenshots/profile.png) |

### Instructor

| Dashboard                                                       | Students                                                |
| --------------------------------------------------------------- | ------------------------------------------------------- |
| ![Instructor Dashboard](assets/screenshots/instructor_home.png) | ![Students](assets/screenshots/instructor_students.png) |

| Attendance                                                  | Assignments                                                   |
| ----------------------------------------------------------- | ------------------------------------------------------------- |
| ![Attendance](assets/screenshots/instructor_attendance.png) | ![Assignments](assets/screenshots/instructor_assignments.png) |

| Marks                                  |
| -------------------------------------- |
| ![Marks](assets/screenshots/marks.png) |

### Coordinator

| Dashboard                                                              | Applications                                         |
| ---------------------------------------------------------------------- | ---------------------------------------------------- |
| ![Coordinator Dashboard](assets/screenshots/coordinator_dashboard.png) | ![Applications](assets/screenshots/applications.png) |

| Batches                                    | Assign Instructor                                              |
| ------------------------------------------ | -------------------------------------------------------------- |
| ![Batches](assets/screenshots/batches.png) | ![Assign Instructor](assets/screenshots/assign_instructor.png) |

| Notices                                    |
| ------------------------------------------ |
| ![Notices](assets/screenshots/notices.png) |

---

## Project Structure

```text
bano_qabil_student/
│
├── android/
├── assets/
│   ├── images/
│   └── screenshots/
│
├── lib/
│   ├── app/
│   ├── core/
│   ├── models/
│   ├── services/
│   └── features/
│       ├── auth/
│       ├── student/
│       ├── instructor/
│       └── coordinator/
│
├── test/
├── firebase_options.dart
├── pubspec.yaml
└── README.md
```

---

## Getting Started

### Prerequisites

Make sure the following are installed:

* Flutter SDK
* Dart SDK
* Android Studio
* Android SDK
* Git
* A configured Firebase project

### Installation

Clone the repository:

```bash
git clone https://github.com/AALIYA-stack/bano_qabil_student.git
```

Navigate to the project:

```bash
cd bano_qabil_student
```

Install dependencies:

```bash
flutter pub get
```

Configure Firebase for the project and verify that Firebase Authentication, Cloud Firestore, and Firebase Storage are enabled.

Run the application:

```bash
flutter run
```

---

## Demo Roles

The application includes separate accounts for demonstrating the three role-based experiences.

| Role        | Demo Account               |
| ----------- | -------------------------- |
| Student     | `student@banoqabil.org`    |
| Instructor  | `instructor@banoqabil.org` |
| Coordinator | `admin@banoqabil.org`      |

> Authentication credentials are not published in the repository for security reasons.

---

## Sample Application Data

The project supports demonstration data for:

* Multiple IT courses
* Multiple campuses
* Student applications
* Course batches
* Enrolled students
* Attendance records
* Assignments and submissions
* Marks and feedback
* Module progress
* Career progress
* Instructor assignments
* Notices

This data enables the major application workflows to be demonstrated during testing and presentation.

---

## Supported Courses

The application currently supports IT-focused courses including:

* Flutter App Development
* Web Development
* Cybersecurity
* Digital Marketing
* Graphic Design
* Python

---

## Security

Firebase Security Rules are used to enforce role-based access to application data.

Access is controlled according to the authenticated user's role:

```text
Student
Instructor
Coordinator
```

The application also validates authenticated users before performing protected Firestore and Storage operations.

---

## Build APK

To generate a release APK:

```bash
flutter build apk --release
```

The generated APK will be available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## Development Commands

Run the application:

```bash
flutter run
```

Analyze the project:

```bash
flutter analyze
```

Check connected devices:

```bash
flutter devices
```

Install dependencies:

```bash
flutter pub get
```

Build release APK:

```bash
flutter build apk --release
```

---

## Version Control

The project is maintained using Git and GitHub.

Common workflow:

```bash
git status
git add .
git commit -m "Update application"
git push origin main
```

To retrieve the latest changes:

```bash
git pull origin main
```

---

## Project Objectives

The application aims to provide a structured digital solution for:

* Managing student applications
* Organizing courses and batches
* Tracking attendance
* Managing assignments and submissions
* Recording academic performance
* Monitoring learning progress
* Connecting students with instructors
* Managing campus-level operations
* Supporting career readiness

---

## Future Enhancements

Potential future improvements include:

* Push notifications
* Online quizzes
* Digital certificates
* Advanced student analytics
* Automated attendance reports
* Job opportunity integration
* In-app communication
* Enhanced career tracking
* Performance dashboards

---

## Developer

**Aaliya Younas**

Flutter Developer

**Technical Skills**

* Flutter & Dart
* Firebase
* Cloud Firestore
* Firebase Authentication
* Firebase Storage
* Git & GitHub
* Mobile Application Development
* Responsive UI Development

---

## Acknowledgements

This project was developed as part of the **Bano Qabil Bootcamp** and represents a practical implementation of Flutter and Firebase-based application development.

---

## License

This project is developed for **educational and portfolio purposes** as part of the Bano Qabil Bootcamp.
