# ShopLux

A full-featured e-commerce Flutter application built with clean architecture principles.

## Features

- **Authentication** — Sign up / sign in with Supabase Auth
- **Product Browsing** — Browse products by category with skeleton loading
- **Shopping Cart & Checkout** — Full cart management and order flow
- **Payment Methods** — Add and manage Visa/Mastercard cards (AES-256 encrypted)
- **Order Tracking** — View order history and live status
- **Location** — Delivery address selection via interactive map (Flutter Map + Geolocator)
- **AI Support Chat** — Live chat powered by Groq AI
- **Profile Management** — Edit profile, manage addresses and payment methods

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3 |
| State Management | flutter_bloc (Cubit) |
| Backend | Supabase (Auth + Postgres + Storage) |
| AI Chat | Groq API |
| Maps | Flutter Map + Geolocator + Geocoding |
| Local Storage | SharedPreferences |
| Encryption | AES-256 (encrypt package) |
| Models | Freezed + json_serializable |

## Getting Started

### Prerequisites

- Flutter SDK `^3.11.5`
- A [Supabase](https://supabase.com) project
- A [Groq](https://console.groq.com) API key

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/AbdelrahmanElsharka/ShopLux.git
   cd ShopLux
   ```

2. Copy the environment file and fill in your credentials:
   ```bash
   cp .env.example .env
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run code generation:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. Run the app:
   ```bash
   flutter run
   ```

### Supabase Setup

Run the migration file `supabase_payment_methods_migration.sql` in your Supabase SQL editor to create the required tables.

## Project Structure

```
lib/
├── Auth/           # Authentication pages and logic
├── MainPages/      # Bottom navigation and main shell
├── SplashPage/     # Splash screen
├── components/     # Shared UI components
├── constants/      # App-wide constants and theme
├── core/           # Core utilities, services, and base classes
├── features/       # Feature modules (products, cart, orders, profile, chat...)
└── main.dart
```

## License

MIT
