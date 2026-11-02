 Geofencing App

OfficeCheck is an Android-based employee attendance application built using **Flutter and Dart**. It uses location-based geofencing to detect when an employee enters or exits a predefined office area and supports automatic attendance checkout when the employee leaves the office boundary.

The application is designed to simplify employee attendance tracking by combining GPS location services, background geofencing, local notifications, and attendance history management.

The initial implementation focuses on a single office location with mock attendance data. Backend integration can be introduced in a future phase.

## 🚀 Project Objectives

- Automate employee attendance tracking using GPS-based geofencing.
- Detect office entry and exit events.
- Allow employees to check in only when they are within the office geofence.
- Automatically trigger checkout when an employee leaves the office area.
- Display notifications for automatic checkout events.
- Maintain daily attendance records and multiple check-in/check-out sessions.
- Support background location monitoring.
- Provide a simple and user-friendly attendance interface.

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform UI framework |
| Dart | Application programming language |
| Riverpod | State management and dependency management foundation |
| Geolocator | Device location access and location updates |
| flutter_background_geofencing | Background geofence monitoring |
| Permission Handler | Runtime permission management |
| SharedPreferences | Local attendance data persistence |
| Flutter Local Notifications | Local attendance notifications |
| Android Native APIs | Location permissions and background execution |
| Material Design | Application UI components |

## ✨ Features Implemented

### 1. Application Initialization
- Custom splash screen.
- Application initialization and permission setup.
- Saved language preference loading.
- Notification service initialization.

### 2. Location Permission Management
- Foreground location permission handling.
- Background location permission handling.
- Device location availability checks.
- Guidance for granting the required location permissions.
- Background location access configuration.

### 3. Notification Management
- Local notification initialization.
- Android notification permission handling.
- Attendance notification channel configuration.
- Automatic checkout notification implementation.
- Foreground service notification for active geofence monitoring.

### 4. Geofencing Implementation
- Single office geofence configuration.
- Initial geofence radius of 100 metres.
- Office entry detection.
- Office exit detection.
- Background geofencing service initialization.
- Geofence event stream subscription.
- Duplicate exit event protection.
- Automatic checkout callback integration.

### 5. Attendance Management
- Manual employee check-in.
- Manual employee check-out.
- Location-based check-in validation.
- Automatic checkout through geofence exit events.
- Multiple attendance sessions per day.
- Daily attendance history.
- Check-in and checkout timestamps.
- Attendance session status management.
- Local persistence using SharedPreferences.

### 6. Location Tracking
- Current device location retrieval.
- Live location updates.
- Distance calculation from the office.
- Fresh location validation before manual attendance actions.
- Mock-location detection, temporarily disabled for testing.

### 7. Attendance History
- Daily attendance records.
- Multiple sessions in a single day.
- Total working duration calculation.
- Manual and automatic checkout type tracking.

### 8. Application Settings
- Language preference persistence.
- English and Japanese localization foundation.
- Application settings and attendance history screens.

## 📍 Geofencing Workflow

The application uses a predefined office latitude, longitude, and radius to monitor employee movement.

**Attendance workflow:**

1. Employee grants the required location permissions.
2. Application registers the office geofence.
3. Background geofencing service starts.
4. When the employee enters the office area, an ENTER event is detected.
5. Employee can manually check in.
6. When the employee exits the geofence, an EXIT event is detected.
7. The attendance service identifies the active attendance session.
8. Automatic checkout time is saved.
9. A local notification is displayed.

### Geofence Configuration

| Configuration | Value |
|---|---|
| Office latitude | 12.9328497 |
| Office longitude | 77.5400525 |
| Geofence radius | 100 metres |
| Geofence region ID | office |
| Attendance storage | Local device |
| Initial office count | One |

## 🏗️ Project Architecture

The project follows a feature-oriented structure with separation between presentation, data, and service responsibilities.

```text
lib/
├── core/
│   ├── constants/
│   ├── localization/
│   ├── geofence_debug.dart
│   └── ...
│
├── features/
│   ├── splash/
│   │   └── presentation/
│   │
│   ├── location/
│   │   └── data/
│   │       └── services/
│   │           ├── geofencing_service.dart
│   │           └── notification_service.dart
│   │
│   ├── home/
│   │   └── presentation/
│   │
│   ├── attendance/
│   │   └── data/
│   │       └── services/
│   │           └── attendance_service.dart
│   │
│   ├── history/
│   │   └── presentation/
│   │
│   └── settings/
│       └── presentation/
│
└── main.dart
```

*Note: This is a high-level representation; the actual project structure may contain additional files and folders.*

## 🔔 Background Execution

The application uses the `flutter_background_geofencing` package to maintain geofence monitoring through an Android foreground service.

The foreground service displays a persistent notification indicating that OfficeCheck is actively monitoring the office geofence.

Background execution is an important part of the application because attendance events must be detected even when the employee is not actively using the application.

**Current development focus:**
- Reliable geofence event delivery after the app is removed from Recents.
- Repeated ENTER and EXIT event handling.
- Background automatic checkout execution.
- Reliable local notification delivery from background execution.
- Android device-specific background execution behaviour.

## 🧪 Testing

Testing currently includes manual functional testing using:

- Android Emulator location controls.
- Fake GPS / mock location applications.
- Inside-geofence and outside-geofence scenarios.
- Repeated entry and exit scenarios.
- Manual check-in and check-out.
- Attendance history persistence.
- Background service behaviour.

Mock-location validation has been temporarily disabled for controlled geofencing tests and should be restored before production.

Unit testing with Flutter's `flutter_test` and Mocktail is a planned next step.

## 📌 Current Development Status

**Implemented:**
- Initial application UI and navigation.
- Splash and location permission screens.
- Notification permission setup.
- Background geofencing service integration.
- Office geofence registration.
- Manual check-in and check-out.
- Automatic checkout callback.
- Multiple attendance sessions.
- Local attendance persistence.
- Attendance history.
- English and Japanese localization foundation.
- Fake GPS testing setup.

**In progress:**
- Reliable automatic checkout when the app is removed from Recents.
- Background geofence event processing.
- Background notification delivery.
- Repeated geofence transition reliability.
- Unit and integration testing.

## 🔮 Future Enhancements

- Backend API integration.
- Employee authentication.
- Server-side attendance synchronization.
- Multiple office locations.
- Configurable geofence radius.
- Attendance reports and analytics.
- Admin dashboard.
- Improved mock-location and location-spoofing protection.
- Automated unit, widget, and integration tests.
- Production-ready Android background execution and battery optimization handling.

## 🎯 Project Goal

To build a reliable, location-aware employee attendance application that reduces manual attendance operations through GPS-based geofencing, automatic checkout, background monitoring, and real-time attendance notifications.

---

**Project:** OfficeCheck  
**Platform:** Android  
**Framework:** Flutter  
**Language:** Dart  
**Development Stage:** Active Development  
**Data Storage:** Local (SharedPreferences)  
