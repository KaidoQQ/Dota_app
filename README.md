# Dota 2 Companion - Flutter Application

A modern, high-performance mobile application built with Flutter that serves as a comprehensive encyclopedia for Dota 2 heroes and items. This project integrates real-time data from the OpenDota API and high-quality assets from the official Valve/Steam CDN.

## 🚀 Key Features

- **Hero Encyclopedia**: Detailed stats for all 120+ heroes, including dynamic calculations for Max HP, Max Mana, Armor, and Stamina.
- **Item Database**: A complete list of game items with detailed descriptions, costs, and unique abilities (Active/Passive).
- **Instant Search**: Real-time filtering for both heroes and items using `SearchDelegate`.
- **Advanced UX**:
  - Smooth navigation with `BottomNavigationBar`.
  - Detailed view using `DraggableScrollableSheet`.
  - Alphabetical and cost-based sorting.
  - Pull-to-refresh functionality.

## 🛠 Technical Highlights

- **Multithreading (Isolates)**: Utilizes Flutter's `compute()` function to parse large JSON datasets in the background, ensuring a stutter-free 60 FPS UI experience.
- **API Integration**: Fetches real-time data from the **OpenDota API**.
- **Dynamic Asset Loading**: Dynamically generates image URLs to fetch high-definition icons directly from the **Official Valve Steam CDN**.
- **Clean Architecture**: Decoupled data models (`DotaHero`, `DotaItem`) and UI components for better maintainability.
- **Data Sanitization**: Implements complex Regular Expressions to clean and format raw HTML strings provided by the API.

## 📦 Project Structure

- `lib/main.dart`: UI layer, navigation logic, and state management.
- `lib/hero_model.dart`: Data model and game logic (HP/Mana formulas) for heroes.
- `lib/item_model.dart`: Data model and description aggregator for game items.
- `PROJECT_DESCRIPTION.txt`: Technical breakdown for educational presentation (Polish).
- `PREZENTACJA_WIDEO.txt`: Video presentation script (Polish).

## ⚙️ Setup & Installation

1. **Prerequisites**: Ensure you have [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
2. **Clone the repository**:
   ```bash
   git clone <repository-url>
   ```
3. **Fetch dependencies**:
   ```bash
   flutter pub get
   ```
4. **Run the application**:
   ```bash
   flutter run
   ```

## 📄 License
This project was developed for educational purposes using the OpenDota API. Dota 2 assets are property of Valve Corporation.
