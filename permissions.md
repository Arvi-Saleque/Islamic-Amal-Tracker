# Notification Permissions Guide - Brand Specific

## Common Settings (সব Android ফোনের জন্য - আগে এগুলো চেক করুন)

### A) App Notifications
**Path:** `Settings → Apps → আমল ট্র্যাকার → Notifications`
- Allow notifications = ON
- Lock screen / Pop-up / Banner / Sound = ON

### B) Battery Optimization বন্ধ
**Path:** `Settings → Apps → আমল ট্র্যাকার → Battery`
- Unrestricted / Don't optimize সিলেক্ট করুন

### C) Background Data
**Path:** `Settings → Apps → আমল ট্র্যাকার → Mobile data & Wi-Fi`
- Background data = ON
- Unrestricted data usage = ON

### D) Unused app বন্ধ
**Path:** `App info → আমল ট্র্যাকার`
- Pause app activity if unused = OFF
- Remove permissions if unused = OFF

### E) Exact Alarm (Android 12+)
**Path:** `Settings → Special app access → Alarms & reminders`
- Allow

---

## 1️⃣ Xiaomi / Redmi / Poco (MIUI / HyperOS)

### ⭐ Auto-start (সবচেয়ে গুরুত্বপূর্ণ)
**Path:** `Settings → Apps → Permissions → Autostart / Background autostart`
- আমল ট্র্যাকার = ON

### Battery Settings
**Path:** `Settings → Apps → Manage apps → আমল ট্র্যাকার → Battery`
- No restrictions / Unrestricted
- Allow background activity = ON

### Recents Lock
**Action:** Recent apps খুলুন → আমল ট্র্যাকার লং প্রেস → Lock

### Security App
**Path:** `Security app → Battery → App battery saver`
- No restrictions

---

## 2️⃣ Samsung (One UI)

### ⭐ Sleeping Apps বন্ধ
**Path:** `Settings → Battery → Background usage limits`
- Put unused apps to sleep = OFF
- Sleeping apps / Deep sleeping apps থেকে আমল ট্র্যাকার Remove করুন

### Battery
**Path:** `Settings → Apps → আমল ট্র্যাকার → Battery`
- Unrestricted

### Notifications
**Path:** `Settings → Notifications → App notifications`
- আমল ট্র্যাকার = ON
- Notification categories সব ON

---

## 3️⃣ OnePlus (OxygenOS)

### ⭐ Auto-launch Enable
**Path:** `Settings → Apps → Special app access → Auto-launch`
- আমল ট্র্যাকার = Enable

### ⭐ Deep Optimization বন্ধ
**Path:** `Settings → Battery → Deep optimization`
- OFF করুন অথবা আমল ট্র্যাকার exclude করুন

### Battery Optimization
**Path:** `Settings → Battery → Battery optimization`
- আমল ট্র্যাকার → Don't optimize

---

## 4️⃣ Oppo / Realme (ColorOS / Realme UI)

### ⭐ Auto-launch / Startup Manager
**Path:** `Settings → Apps → Special app access → Auto-launch / Startup manager`
- আমল ট্র্যাকার = Enable
- Secondary launch / Background launch = Allow

### Battery Optimization
**Path:** `Settings → Battery → Battery optimization`
- আমল ট্র্যাকার → Don't optimize

---

## 5️⃣ Vivo / iQOO (Funtouch OS)

### ⭐ Auto-start
**Path:** `Settings → Battery → Background power consumption management / Autostart`
- আমল ট্র্যাকার = Allow

### High Background Power
**Path:** `Settings → Battery → High background power consumption`
- আমল ট্র্যাকার = Allow / Don't restrict

### Battery Optimization
**Path:** `Apps → আমল ট্র্যাকার → Battery`
- No restrictions

---

## 6️⃣ Huawei / Honor (EMUI / MagicOS)

### ⭐ App Launch (Manual)
**Path:** `Settings → Apps → App launch → আমল ট্র্যাকার`
- Manage manually = ON
- Auto-launch = ON
- Secondary launch = ON
- Run in background = ON

### Battery Optimization
**Path:** `Battery optimization`
- Don't allow optimize / Unrestricted

---

## 7️⃣ Motorola (MyUX / Stock-like)

### Battery
**Path:** `Settings → Apps → আমল ট্র্যাকার → Battery`
- Unrestricted

### Battery Optimization
**Path:** `Settings → Battery → Battery optimization`
- আমল ট্র্যাকার → Not optimized

### Data
**Path:** `Mobile data`
- Background data = ON

---

## 8️⃣ Google Pixel / Stock Android

### Battery Optimization
**Path:** `Settings → Apps → আমল ট্র্যাকার → Battery`
- Unrestricted

### Battery Saver
**Path:** `Settings → Battery → Battery Saver`
- OFF থাকলে ভালো (ON থাকলে delay হতে পারে)

### Exact Alarm
**Path:** `Settings → Apps → Special app access → Alarms & reminders`
- আমল ট্র্যাকার = Allow

---

## 9️⃣ Tecno / Infinix / Itel (HiOS / XOS)

### ⭐ Auto-start
**Path:** `Settings → Apps → Autostart manager`
- আমল ট্র্যাকার = Enable

### Battery / Power Manager
**Path:** `Battery lab / Power manager`
- Don't restrict

### Background Activity
**Action:** Allow background activity = ON

### Recents Lock
**Action:** Lock in recent apps (যদি থাকে)

---

## Android Manifest Permissions (Code Level)

### ✅ Active Permissions (বর্তমানে ব্যবহৃত):

**Notification Related:**
1. **POST_NOTIFICATIONS** - Android 13+ notification দেখানোর জন্য
2. **SCHEDULE_EXACT_ALARM** - Android 12+ সঠিক সময়ে alarm (Android 14+ এ user settings থেকে allow করতে হবে)
3. **RECEIVE_BOOT_COMPLETED** - ফোন restart এর পর reminder reschedule
4. **VIBRATE** - Notification vibration

**Prayer Times Related:**
5. **INTERNET** - Prayer times API / Firebase sync
6. **ACCESS_FINE_LOCATION** - সঠিক location থেকে prayer times
7. **ACCESS_COARSE_LOCATION** - Approximate location থেকে prayer times

### ❌ Removed Permissions (সরিয়ে দেওয়া হয়েছে):
- ~~USE_EXACT_ALARM~~ - Play Store restricted, SCHEDULE_EXACT_ALARM দিয়েই কাজ হয়
- ~~WAKE_LOCK~~ - flutter_local_notifications এর জন্য দরকার নেই
- ~~REQUEST_IGNORE_BATTERY_OPTIMIZATIONS~~ - User guide দিয়ে manually করাই ভালো
- ~~FOREGROUND_SERVICE~~ - Reminder scheduling এর জন্য দরকার নেই
- ~~FOREGROUND_SERVICE_SPECIAL_USE~~ - Play Store এ highly scrutinized

---

## Summary by Brand Priority:

### ⭐⭐⭐ সবার আগে চেক করুন (Most Critical):

| Brand | সবচেয়ে গুরুত্বপূর্ণ Setting |
|-------|----------------------------|
| **Xiaomi/Redmi/Poco** | Auto-start / Background autostart = ON |
| **Samsung** | Sleeping Apps থেকে Remove করুন |
| **OnePlus** | Auto-launch + Deep Optimization বন্ধ |
| **Oppo/Realme** | Auto-launch / Startup Manager = Enable |
| **Vivo/iQOO** | Auto-start = Allow |
| **Huawei/Honor** | App Launch → Manual mode |
| **Tecno/Infinix/Itel** | Auto-start = Enable |

### ⭐⭐ এরপর চেক করুন (Common for All):
1. **Battery Optimization** = Unrestricted / Don't optimize
2. **Notifications** = Allow (সব category ON)
3. **Exact Alarm** = Allow (Android 12+)
4. **Background Data** = ON

### ⭐ Optional (যদি এখনও কাজ না করে):
- Recents Lock (Recent apps এ লং প্রেস করে Lock)
- Do Not Disturb এ exception যোগ করুন
- Data Saver এ Unrestricted data usage = ON
