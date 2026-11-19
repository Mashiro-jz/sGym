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

<img width="358" height="777" alt="flutter_01" src="https://github.com/user-attachments/assets/08784e47-f57c-4110-bb03-b1cdba53b1c7" />
<img width="358" height="777" alt="flutter_02" src="https://github.com/user-attachments/assets/40931929-cedd-4457-aa97-fe9d3811b621" />
<img width="358" height="777" alt="flutter_03" src="https://github.com/user-attachments/assets/bb938805-fdd9-4fa2-b638-3031d0ea96b7" />
<img width="358" height="777" alt="flutter_04" src="https://github.com/user-attachments/assets/17b888c3-1c9f-42c4-b7ba-cfc082623606" />
<img width="358" height="777" alt="flutter_05" src="https://github.com/user-attachments/assets/b8d7d583-8316-4198-a5a3-e39192272d72" />

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
