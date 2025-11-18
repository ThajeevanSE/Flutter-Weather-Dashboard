📱 Personalized Weather Dashboard – Flutter
IN3510 – Wireless Communication & Mobile Networks
University of Moratuwa, Faculty of IT
📌 Overview

This Flutter application is the Final Individual Assignment for IN3510 – Wireless Communication & Mobile Networks.
The app acts as a personalized weather dashboard that generates latitude and longitude from the student index, fetches real-time weather data using the Open-Meteo API, and displays the results in a simple mobile UI.

The app works completely offline after the first successful fetch by using Shared Preferences caching.

 Features (Functional Requirements)
1. Student Index Input

Text field for student index (e.g., 194174B)

Index may be pre-filled

Validates format before using it

2. Automatic Coordinate Generation

Derived using assignment formula:

firstTwo = int(index[0..1])
nextTwo = int(index[2..3])
lat = 5 + (firstTwo / 10.0)
lon = 79 + (nextTwo / 10.0)


Latitude displayed with 2 decimals

Longitude displayed with 2 decimals

🌦 3. Weather Fetching (Open-Meteo API)

API request:

https://api.open-meteo.com/v1/forecast?latitude=LAT&longitude=LON&current_weather=true


App displays:

Temperature (°C)

Wind speed

Weather code

Last updated time (from device clock)

Exact request URL (small text, visible for verification)

Includes:

Loading indicator

Friendly error messages

📡 4. Offline Cache (Shared Preferences)

Stores last successful weather response + timestamp

Works offline when network is unavailable

Shows a (cached) label when rendering offline results

Shows a friendly error if no cache exists




🗂 Project Structure
lib/
├── main.dart
├── screens/
│   └── weather_screen.dart
├── services/
│   ├── weather_api.dart
│   └── cache_service.dart
└── models/
    └── weather_model.dart

⚙️ Technologies Used

Flutter (Dart)

HTTP package (API calls)

Shared Preferences (local caching)

Open-Meteo API (no API key)

🔧 How to Run
flutter pub get
flutter run


Platform: Android
No backend required.

📌 Example Generated Coordinates

For index: 194174B

firstTwo = 19 → lat = 5 + 1.9  = 6.9
nextTwo  = 41 → lon = 79 + 4.1 = 83.1

🤝 Author

V.Thajeevan – 224252C
B.Sc. (Hons) Information Technology & Management
Faculty of Information Technology
University of Moratuwa