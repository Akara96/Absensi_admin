# Absensi Admin System 🏢

An Employee Attendance Administration System based on **Django (Python)** and **Flutter**. Absensi_admin is a Geofencing-based Attendance System designed to monitor employee attendance, both for checking in and checking out.

## 🌟 Key Features

The project is divided into two main parts:

### 💻 Backend & Admin Dashboard (Django + MySQL)
- Built using Python with the Django framework and Django REST Framework (DRF).
- Provides a Web Admin Dashboard (using Django Templates, Bootstrap, etc.) that allows HR or Admins to monitor attendance records, approve employee leave/absences, manage employee data, and configure geofence zones (office coordinates and allowed radius).
- Features JWT (JSON Web Tokens) based authentication for secure communication with the mobile application.

### 📱 Mobile Application (Flutter)
- Built using Flutter (located within the `absensi/` folder).
- This application is intended for use by employees (clients).
- The main feature allows employees to Check-in (Tama), take a Break (Deskansa), and Check-out (Sai) using the GPS sensor. The system validates whether the employee is within the office geofence radius.
- Employees are also required to take a selfie as proof of attendance, and they can request leave, sick days, or time off directly through the application.

---

## 🛠️ Technologies Used

- **Backend:** Python 3, Django 4.2.11, Django REST Framework (DRF)
- **Database:** MySQL / SQLite
- **API Authentication:** SimpleJWT (JSON Web Token)
- **API Documentation:** drf-spectacular (Swagger UI)
- **Frontend Dashboard:** HTML, CSS, JavaScript (Django Templates)

---

## 📂 Main URL Structure

- `/dashboard/` : Main page for the Admin Dashboard.
- `/admin/` : Default Django Admin page.
- `/api/` : Base URL for all REST API endpoints (Mobile).
- `/api/docs/` : Interactive API documentation page (Swagger UI).
