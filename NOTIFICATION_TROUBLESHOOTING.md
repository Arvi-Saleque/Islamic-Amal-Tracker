# Notification Troubleshooting Guide

##  Problem: Default Reminder Notifications Not Appearing

### Symptoms
- Default reminders (e.g., Dhuhr at 1:16 PM) are scheduled but don't fire
- App shows `[DefaultRolling] Skipping: 30 days remaining, has pending alarms` in logs
- The reminders are technically scheduled but never appear

### Root Causes

#### 1. **Android Battery Optimization** (Most Common)
Android aggressively kills background alarms to save battery. Even with `exactAllowWhileIdle`, some OEMs (Xiaomi, Oppo, Vivo, Realme) may still suppress notifications.

**Solution:**
1. Go to: Settings → Apps → Amal Tracker → Battery
2. Select: **"Unrestricted"** or **"No restrictions"**
3. Disable **"Adaptive Battery"** for the app

#### 2. **Schedule Exact Alarm Permission Not Granted**
Android 12+ requires explicit permission for exact alarms.

**Solution:**
1. Go to: Settings → Apps → Amal Tracker → Advanced → Alarms & reminders
2. Enable: **"Allow setting alarms and reminders"**
3. Or in-app: Go to Reminders → Settings (gear icon) → Request permissions

#### 3. **Doze Mode**
Android's Doze mode can delay or suppress notifications when the screen is off.

**Solution:**
1. Go to: Settings → Battery → Battery Optimization
2. Find: Amal Tracker
3. Select: **"Don't optimize"**

#### 4. **Notification Channels Disabled**
The specific notification channel might be disabled.

**Solution:**
1. Go to: Settings → Apps → Amal Tracker → Notifications
2. Ensure all channels are enabled:
   - Default Prayer Reminders
   - Default Dhikr Reminders
   - Default Daily Amal
   -Custom Reminder Channel

#### 5. **App Data Cleared or Notification Permissions Revoked**
If app data is cleared, scheduled notifications are lost.

**Solution:**
- Use the in-app **"Refresh Default Reminders"** button (see below)

---

## 🔧 New Debugging Tools

### 1. **Pending Notifications Screen** (NEW!)
- Access: Reminders → Debug icon (bug icon)
- Shows: All scheduled notifications with IDs and types
- Counts: Default, User, and Custom reminders separately
- Diagnostics: Expected vs actual notification counts

### 2. **Force Refresh Button** (NEW!)
- Located in: Pending Notifications Screen → Summary Card → Refresh button
- Action: Clears and re-schedules all default reminders (30 days ahead)
- Use when: Notifications aren't firing or count seems wrong

---

## 📊 How to Verify Default Reminders are Working

### Step 1: Open Pending Notifications Screen
1. Go to: **Reminders** screen
2. Tap: **Debug icon** (bug icon) in top-right
3. Check the **Summary** section

### Step 2: Verify Counts
Expected counts for 30 days ahead:
- **Default Prayers**: 150 (5 prayers × 30 days)
- **Default Dhikr**: 60 (2 dhikr × 30 days)
- **Default Nafl**: 30 (1 nafl × 30 days)
- **Total Default**: 240 notifications

If counts are lower:
- Tap **"Refresh"** button
- Wait 2-3 seconds
- Check counts again

### Step 3: Check Specific Reminder Exists
1. Scroll through the list
2. Look for default reminders like:
   - `Default Dhuhr (Day +0)` - ID 9201
   - `Default Morning Dhikr (Day +0)` - ID 210000
3. Verify time is correct for today

---

## 🚨 Brand-Specific Issues

### Xiaomi (MIUI)
1. **Settings → Battery & Performance → App battery saver**
   - Find app → **"No restrictions"**
2. **Security → Permissions → Autostart**
   - Enable for Amal Tracker
3. **Settings → Apps → Permissions → Other Permissions**
   - Enable "Display pop-up windows while running in the background"

### Oppo/Realme (ColorOS)
1. **Settings → Battery → App Battery Management**
   - Find app → Uncheck "Optimize battery use"
2. **Settings → Privacy → Permission Manager → Autostart**
   - Enable for Amal Tracker

### Vivo (Funtouch OS)
1. **Settings → Battery → Background power consumption management**
   - Select app → High background power consumption
2. **Settings → More Settings → Permission**
   - Enable "Auto-start"

### Samsung (One UI)
1. **Settings → Apps → Amal Tracker → Battery**
   - **"Optimize battery usage"** → OFF
2. **Settings → Apps → Amal Tracker → Notifications**
   - Ensure all channels are ON

---

## 🔍 Understanding Notification IDs

### Default Reminders (Always Active - ID Range: 9000+)
- **9001**: Default Daily Amal (10 PM daily)
- **9200-9249**: Default Prayer reminders (Day 0-29, Prayer 0-4)
  - 9200 = Fajr (Day 0)
  - 9201 = Dhuhr (Day 0)
  - 9202 = Asr (Day 0)
  - 9203 = Maghrib (Day 0)
  - 9204 = Isha (Day 0)
- **210000-210299**: Default Dhikr reminders
- **220000-220029**: Default Nafl reminders

### User Reminders (ID Range: 1001-2005)
- **1001**: Personal Daily Reminder
- **1002**: Personal Morning Dhikr
- **1003**: Personal Evening Dhikr
- **2001-2005**: Personal Prayer reminders

### Custom Reminders (ID Range: 3000-3999)
- Variable IDs based on reminder ID

---

## ⚡ Quick Fix Checklist

1. ✅ **Check Battery Optimization**: Set to "Unrestricted"
2. ✅ **Grant Exact Alarm Permission**: Settings → Alarms & reminders
3. ✅ **Disable Doze for App**: Battery optimization → Don't optimize
4. ✅ **Enable All Notification Channels**: App notifications settings
5. ✅ **Force Refresh Reminders**: Use in-app refresh button
6. ✅ **Restart Device**: Sometimes helps after permission changes
7. ✅ **Verify with Debug Screen**: Check notification counts

---

## 🆘 Still Not Working?

### Test Notification
1. Go to: **Reminders → Settings (gear icon)**
2. Tap: **"Send Test Notification"**
3. If test works but default reminders don't:
   - Issue is likely with alarm scheduling permissions
   - Check SCHEDULE_EXACT_ALARM permission specifically

### Logs to Check
When the notification should fire, check Android logs:
```
I/flutter: [DefaultRolling] Scheduled X notifications for 30 days
```

If you see:
```
I/flutter: [DefaultRolling] WARNING: 0 notifications scheduled!
```
This means API failed to fetch prayer times.

---

## 💡 Prevention Tips

1. **Don't Clear App Data** - This removes all scheduled notifications
2. **Keep Auto-Start Enabled** - Allows app to reschedule after reboot
3. **Check After OS Updates** - Permissions may reset
4. **Use Refresh Button Monthly** - Keep rolling window up to date

---

## Technical Notes (For Developers)

### Why Default Reminders Use High ID Range (9200+)
- Avoids conflicts with user reminders (1001-2005)
- Allows cancellation of only user reminders without affecting defaults
- Rolling window uses sequential IDs for easy batch operations

### Why Rolling Window (30 days ahead)
- Android can kill daily recurring alarms
- Scheduling 30 days ahead ensures notifications even if app is killed
- Automatically refreshes when days remaining < 2

### Notification Scheduling Mode
```dart
androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
```
- `exact`: Fires at exact time (not delayed)
- `AllowWhileIdle`: Works even in Doze mode
- Requires `SCHEDULE_EXACT_ALARM` permission on Android 12+

---

*Last Updated: February 10, 2026*
