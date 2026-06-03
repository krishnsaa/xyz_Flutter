# 🚀 XYZ Quiz App (Flutter)

A high-performance, animated quiz application built with Flutter. This app features a dynamic dashboard, JWT-based authentication, persistent sessions, and real-time synchronization with a Node.js backend.

Users can test their knowledge across various programming domains, earn XP, track their accuracy, and unlock achievement badges based on their performance.

---

# ✨ Features

## 🔐 Secure Authentication
- User registration and login using JWT (JSON Web Tokens)
- Secure API communication with protected routes

## 💾 Persistent Login
- Keeps users logged in across app restarts
- Uses shared_preferences for local credential storage

## 📊 Dynamic Dashboard
Real-time user statistics including:
- Total XP
- Accuracy Percentage
- Average Reaction Time
- Achievement Badges

## 🧠 Domain Selection
Choose quizzes from multiple programming and tech domains:
- C
- C++
- Java
- DSA
- AI
- Python
- React
- MERN Stack
- Flutter

## ⚡ Interactive Quiz Engine
- 20-second countdown timer per question
- Reaction time tracking in milliseconds
- Smooth progress bar animations
- 60fps UI transitions

## 🧩 State Management
Clean architecture using the provider package:
- UI separated from business logic
- Reactive state updates
- Scalable structure

---

# 🛠️ Tech Stack

| Technology | Usage |
|------------|-------|
| Flutter & Dart | Frontend Development |
| Provider | State Management |
| HTTP | API Communication |
| shared_preferences | Local Storage |
| Node.js / Express | Backend Server |
| MongoDB | Database |
| Render | Backend Hosting |

---

# 📂 Project Structure

plaintext lib/ │ ├── main.dart             # App entry point, route definitions, and auth wrapper ├── authProvider.dart     # Global state for User ID, JWT Token, and persistent login ├── login.dart            # User login screen ├── register.dart         # User registration screen ├── dashBoard.dart        # Main hub for stats, badges, and domain selection └── quiz.dart             # Quiz UI, timer logic, and answer submission 

---

# 🚀 Getting Started

## ✅ Prerequisites

Make sure you have the following installed:
- Flutter SDK
- Dart SDK
- Android Studio / VS Code
- Emulator or physical device

---

# 📦 Installation

## 1️⃣ Clone the Repository

bash git clone https://github.com/yourusername/xyz-quiz-app.git cd xyz-quiz-app 

## 2️⃣ Install Dependencies

bash flutter pub get 

## 3️⃣ Verify Backend Connection

By default, the app connects to the production backend:

plaintext https://xyz-backend-ow16.onrender.com 

If testing locally, update the baseUrl variables inside:
- dashBoard.dart
- quiz.dart

Example:

dart const String baseUrl = "http://localhost:3000"; 

---

# ▶️ Run the App

bash flutter run 

---

# 🧠 Core Logic Highlights

## ⚔️ Race Condition Fix
The dashboard intelligently waits for quiz results to finish saving before fetching updated statistics using:
- Future.delayed
- .then() navigation handlers

## 🛡️ Robust API Parsing
Safely handles inconsistent backend response types:
- Converts mixed integers/strings into doubles
- Prevents runtime parsing crashes

## 🎨 Modern Animations
Uses Flutter animation widgets such as:
- AnimatedContainer
- AnimatedSwitcher

to recreate smooth, modern web-style transitions.

---

# 🔐 Authentication Flow

1. User logs in
2. Backend returns:
   - userId
   - JWT token
3. AuthProvider stores credentials:
   - In memory
   - In shared_preferences
4. All future API requests automatically attach:

http Authorization: Bearer <token> 

Endpoints include:
- /dashboard/summary
- /session/answer

---

# ❤️ Built With Flutter

Designed and developed with ❤️ usi