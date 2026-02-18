AGym - Fitness Management System
AGym is a comprehensive mobile application developed using the Flutter framework, designed to facilitate the management of fitness centers, scheduling, and trainer-client interactions.

The project is engineered with a focus on scalability, testability, and maintainability, adhering to the principles of Clean Architecture and SOLID design patterns. It leverages Firebase for backend services to ensure real-time data synchronization and secure authentication.

Project Overview
AGym serves as a dual-interface platform catering to both fitness trainers and clients. It provides a robust solution for class scheduling, attendance tracking, and user profile management. The application minimizes administrative overhead for trainers while providing a seamless booking experience for gym members.

Key Features
Trainer Module
Schedule Management: A card-based interface for viewing upcoming classes with time, date, and location details.

Real-time Attendance: Dynamic participant lists updated in real-time.

Participant Details: Access to detailed client profiles, including contact information (phone, email), membership status, and biometric data.

Direct Communication: Integrated system dialing for immediate client contact.

Client Module
Class Booking: Mechanism for reserving spots in group fitness classes.

Activity History: A log of past workouts and attendance.

Profile Management: User data administration and photo upload capabilities.

Security & Core
Authentication: Secure login and registration powered by Firebase Authentication.

Role-Based Access Control (RBAC): Distinct permission sets for Administrators, Trainers, and Clients.

System Architecture
The application is built upon Clean Architecture, enforcing a strict separation of concerns into three distinct layers:

Domain Layer (Core):

Contains Business Logic, Entities, and Use Case definitions.

Completely independent of external frameworks or data sources.

Data Layer:

Implements the interfaces defined in the Domain layer.

Handles data retrieval from Firebase Firestore and maps JSON data to domain entities.

Presentation Layer:

Manages the UI and state using the BLoC (Business Logic Component) pattern.

Reactive UI updates based on state changes (Loading, Loaded, Error).

Technology Stack
Framework: Flutter (Dart 3.x)

State Management: BLoC / Cubit (flutter_bloc)

Backend as a Service: Firebase (Firestore, Authentication, Storage)

Dependency Injection: GetIt (get_it)

Value Equality: Equatable (equatable)

Date Formatting: Intl (intl)

License & Usage Rights
© [Current Year] [Your Name/Company Name]. All Rights Reserved.

NOTICE TO USER:
The source code, design, and intellectual property contained in this repository are the sole property of the author.

Strictly Prohibited Acts:

Commercial Use: You are strictly prohibited from using this code, in whole or in part, for any commercial purpose, including but not limited to selling, licensing, renting, or monetization within other software products.

Redistribution: You may not redistribute, sub-license, or sell copies of the software.

Permitted Uses:

This code is provided for educational and evaluation purposes only. You may view and study the code to understand its architecture and implementation.

For any commercial inquiries or licensing requests, please contact the author directly.
