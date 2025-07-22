# com.iconic.university

# 📍 Location-Based Reporting App (Flutter)

This is a take-home technical assessment for the Flutter Developer position at **Iconic University**. The app allows users to log in and submit reports with a category, location (map or address input), and media (image or video). Previous reports are viewable in a list.

---

## ✨ Features Implemented

- 🔐 Login screen (mock authentication/local storage)
- 📝 Submit reports with:
  - Category selection
  - Image/video capture or gallery
  - Location input via map or address search
  - Overlay of coordinates onto media
- 📍 Google Maps integration
- 📋 View previous submissions in a list
- 🧼 Clean UI following Figma design guidelines
- 🧱 Flutter best practices (folder structure, state management, etc.)

---

## 🛠️ Tech Stack

- Flutter >= 3.27.7
- Dart
- Google Maps / Geolocator
- Image Picker / Camera
- Riverpod(a modern upgrade of Provider) for state management
- Shared Preferences and local DB (for state and mock data presitence)

---

## 🚀 Getting Started

To run this project:

```bash
git clone https://github.com/engr-miraculous/iu_job_assessment
cd iu_job_assessment
flutter pub get
flutter run