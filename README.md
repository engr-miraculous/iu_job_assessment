# com.iconic.university

# 📍 Location-Based Reporting App (Flutter)

This is a take-home technical assessment for the Flutter Developer position at **Iconic University**. The app allows users to log in and submit reports with a category, location (map or address input), and media (image or video). Previous reports are viewable in a list.

---

## ✨ Features Implemented

- 🔐 Login screen (mock authentication)
- 📝 Submit reports with:
  - Category selection
  - Images/videos from camera or gallery
  - Location input via map or address search
  - Overlay of coordinates onto media (at the lower left corner of the image)
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
- Riverpod (a modern upgrade of Provider) for state management
- drift DB (A reactive SQLite library for state report persistence)

---

## ⚠️ Platform Support & Permissions

- **Tested on Android only:** The project was only tested on Android, but it should work on iOS with minimal configuration since no platform-specific code or library was used.
- **Location Permissions:** The app will prompt for location permission the first time it is needed. If location services are turned off on the device, location and coordinates-related features may not work as expected, so in addition to granting permission, you will need to enable location services on the device.
- **Google Maps API Key Required:** The project requires a Google Maps API key. The current key in the repository may be revoked at any time. Please obtain your own API key and update it in both the manifest file and the location service as shown below:
  - In `android/app/src/main/AndroidManifest.xml`:
    ```xml
    <meta-data android:name="com.google.android.geo.API_KEY" android:value="<KEY>"/>
    ```
  - In [location_service.dart](lib/services/location_service.dart):
    ```dart
    const LocationService._internal();
    static const String _googlePlacesApiKey = '<KEY>';
    static const String _placesBaseUrl = 'https://maps.googleapis.com/maps/api/place';
    ```
- **Drift/Database Analyzer Errors:** If you see errors in your IDE from [database_service.dart](lib/services/database_service.dart), you can ignore them, the app will still compile and run correctly if you ignore the IDE warning. Drift generates some code automatically, which may not be immediately available or detected by the Flutter analyzer, causing these errors.
- **Mock Reports:** The app generates mock reports by default to pre-populate the report list. If you only want to see the reports you enter, set the value of `_totalMockReports` in [report_service.dart](lib/services/report_service.dart) to `0` and no pre-generated reports will appear.

---

## 🚀 Getting Started

To run this project please ensure you are on verssion 3.27.7 of Flutter and run the following commands:

```bash
git clone https://github.com/engr-miraculous/iu_job_assessment
cd iu_job_assessment
flutter pub get
flutter run