# sGym

sGym is a mobile application for managing a fitness club. It makes it easy for clients to browse the schedule and sign up for classes, while supporting trainers and administrators in their day-to-day workflow.

## Features

- User registration, login, and profile editing.
- Browsing the schedule, filtering classes, and signing up for or canceling bookings.
- Viewing upcoming classes and workout history.
- Trainer view displaying assigned classes and participant lists.
- Admin panel featuring a user list and role management.
- Membership pass in the form of a QR code that refreshes every 30 seconds. The app blocks screenshots while the pass is displayed.

## Screenshots
<img width="358" height="777" alt="flutter_01" src="https://github.com/user-attachments/assets/1649b2c8-13b7-403a-8b6a-2612c60bc50e" />
<img width="358" height="777" alt="flutter_05" src="https://github.com/user-attachments/assets/7bcd2112-d3f7-4ad3-9e5d-56db2d2b21e1" />
<img width="358" height="777" alt="flutter_04" src="https://github.com/user-attachments/assets/153a371c-1588-4fe7-99e5-a962ef4ad004" />
<img width="358" height="777" alt="flutter_03" src="https://github.com/user-attachments/assets/8165122e-cadb-4c5b-9018-c4505512723a" />
<img width="358" height="777" alt="flutter_02" src="https://github.com/user-attachments/assets/72a43fc6-9118-48b0-ae70-244be692bb62" />

## Technologies and Libraries

- **Flutter and Dart** — UI application; requires Dart SDK: `^3.9.0`.
- **Firebase Authentication** and **Cloud Firestore** — authentication and data storage.
- **flutter_bloc** and **equatable** — state management and value equality for states.
- **go_router** — navigation between screens.
- **get_it** — dependency injection.
- **qr_flutter** and **no_screenshot** — displaying the membership QR code and protecting the pass screen from screenshots.
- **filter_list** — filtering classes.
- **intl** and **flutter_localizations** — date formatting and localization.
- **Freezed**, **freezed_annotation**, and **build_runner** — model and boilerplate code generation.
- **flutter_lints** and **flutter_test** — development and testing tools.

`firebase_storage` and `image_picker` are declared in the project dependencies, but are not currently used in the application code.

## Architecture

The codebase is divided into feature modules (`auth`, `schedule`, `user`, `admin`, `home`, `pass`). The core modules follow an approach inspired by Clean Architecture:

- **Presentation** — screens and state management using Cubits and states.
- **Domain** — entities, repository interfaces, and use cases independent of Firebase.
- **Data** — data sources, models, and repository implementations that communicate with Firebase.

Dependencies are configured in `lib/core/config/injection_container.dart`, and application routes in `lib/core/config/app_router.dart`.
