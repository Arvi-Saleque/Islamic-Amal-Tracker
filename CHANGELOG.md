# Changelog

## v1.0.5 (Build 7) - January 22, 2026

### 🎯 Major Improvements
- **Device-Specific Notification Guide**: Auto-detect phone brand (Xiaomi, Samsung, OnePlus, etc.) and show customized troubleshooting steps
- **Tab System**: Browse notification settings for all major phone brands
- **Notification Permission Popup**: Added popup after location permission to guide users to reminder settings

### 🔧 Bug Fixes & Optimizations
- Removed unnecessary permissions for Play Store compliance:
  - Removed `USE_EXACT_ALARM` (using `SCHEDULE_EXACT_ALARM` instead)
  - Removed `WAKE_LOCK` (not needed for flutter_local_notifications)
  - Removed `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` (user guide instead)
  - Removed `FOREGROUND_SERVICE` and `FOREGROUND_SERVICE_SPECIAL_USE`
- Removed Battery Optimization permission from UI (handled through user guide)
- Removed redundant "Notification Permission Settings" button
- Fixed permission icon visibility (black color on gold/red backgrounds)

### 📱 Brand-Specific Guides Added
- Xiaomi/Redmi/Poco (MIUI/HyperOS)
- Samsung (One UI)
- OnePlus (OxygenOS)
- Oppo/Realme (ColorOS)
- Vivo/iQOO (Funtouch OS)
- Huawei/Honor (EMUI/MagicOS)
- Motorola (Stock-like)
- Google Pixel
- Tecno/Infinix/Itel (HiOS/XOS)

### 🎨 UI/UX Improvements
- AM/PM dual button selector with gold theme
- Edit icon added to custom reminder cards
- Simplified custom reminder creation (title, time, repeat days only)
- Prayer times directly editable on reminders page
- All reminders always active (no toggle switches)

### 🔐 Permissions (Optimized for Play Store)
**Active Permissions:**
- POST_NOTIFICATIONS (Android 13+)
- SCHEDULE_EXACT_ALARM (Android 12+)
- RECEIVE_BOOT_COMPLETED
- VIBRATE
- INTERNET
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION

---

## v1.0.4 (Build 6) - Previous Release
- Initial reminder system implementation
- Prayer times integration
- Custom reminders support
