💻 DreamStay - Admin Dashboard

The DreamStay Admin Dashboard is a responsive web application designed for platform administrators to oversee and manage the residential booking ecosystem. Built with Flutter Web, it provides a modern interface for user moderation, statistical analysis, and system monitoring.

🚀 Key Features

Statistical Overview: Real-time dashboard for users, properties, and bookings.

User Management: Approve, reject, block, or delete user accounts.

Secure Login: Admin-specific authentication gate.

Responsive Layout: Optimized for desktop with a persistent sidebar.

🏗️ Architecture

Uses Clean Architecture (Data, Domain, Presentation) to ensure separation of concerns.

⚙️ Prerequisites

Flutter SDK: 3.x.x (Stable).

Web Browser: Chrome, Edge, or Safari.

Backend: The Laravel API must be running.

🚀 Installation & Setup

Clone the Repository

git clone [https://github.com/yamenhawari/residential_booking_app_admin_dashboard.git](https://github.com/yamenhawari/residential_booking_app_admin_dashboard.git)
cd residential_booking_app_admin

Install Dependencies

flutter pub get

⚠️ API Configuration
Update lib/core/constants/api_constants.dart:

static const String baseUrl = "[http://127.0.0.1:8000/api](http://127.0.0.1:8000/api)";

⚠️ Critical: CORS Configuration (Laravel)
Ensure your Laravel config/cors.php allows the Flutter Web origin:

'paths' => ['api/*', 'sanctum/csrf-cookie'],
'allowed_origins' => ['*'],

Run the App

flutter run -d chrome

🛠 Tech Stack

Framework: Flutter Web

State Management: flutter_bloc

Local Storage: shared_preferences / hive

Styling: google_fonts, flutter_screenutil
