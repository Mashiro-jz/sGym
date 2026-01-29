# sGym
sGym/
├── assets/                     # Zasoby statyczne
│   ├── images/                 # Logo, banery
│   └── icons/                  # Ikony niestandardowe
├── lib/                        # GŁÓWNY KOD ŹRÓDŁOWY
│   ├── main.dart               # Punkt startowy (uruchamia app.dart)
│   ├── app.dart                # Konfiguracja MaterialApp (motywy, routing)
│   │
│   ├── core/                   # Rdzeń aplikacji (wspólne dla całego projektu)
│   │   ├── constants/          # Stałe (np. adresy API, klucze)
│   │   ├── theme/              # Style, kolory, czcionki
│   │   ├── utils/              # Funkcje pomocnicze (np. formatowanie daty)
│   │   └── widgets/            # Wspólne przyciski, pola tekstowe (używane wszędzie)
│   │
│   ├── data/                   # Warstwa Danych (Data Layer)
│   │   ├── datasources/        # Połączenia z Firebase/API
│   │   ├── models/             # Modele (DTO) - tłumaczą JSON na kod Darta
│   │   └── repositories/       # Logika pobierania danych (łączy API z aplikacją)
│   │
│   ├── domain/                 # Warstwa Biznesowa (Business Logic)
│   │   └── entities/           # ENCJE (Czyste obiekty biznesowe)
│   │       ├── user_entity.dart      # Definicja Usera (id, rola, imię)
│   │       ├── gym_pass_entity.dart  # Definicja Karnetu (typ, cena, ważność)
│   │       ├── lesson_entity.dart    # Definicja Zajęć (trener, godzina, sala)
│   │       └── qr_code_entity.dart   # Dane potrzebne do wygenerowania QR
│   │
│   └── features/               # Ekrany i logika widoku (podział na funkcje)
│       ├── auth/               # Moduł Autoryzacji
│       │   ├── login_page.dart
│       │   └── register_page.dart
│       │
│       ├── user_zone/          # STREFA KLIENTA
│       │   ├── home/           # Dashboard klienta
│       │   ├── passes/         # Kupowanie/Przeglądanie karnetów
│       │   │   └── widgets/    # Np. KartaKarnetu (PassCard)
│       │   ├── classes/        # Grafik zajęć
│       │   └── qr_access/      # Ekran z kodem QR do wejścia
│       │
│       └── admin_zone/         # STREFA PRACOWNIKA (Kasjer/Manager)
│           ├── admin_home/     # Panel główny statystyk
│           ├── member_mgmt/    # Zarządzanie użytkownikami (edycja, blokada)
│           └── access_control/ # Skaner QR (sprawdzanie ważności karnetu)
│
└── pubspec.yaml