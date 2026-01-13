# আমল ট্র্যাকার (Amal Tracker)

**Professional Bengali Islamic Amal Tracker App with Cloud Sync & Smart Notifications**

একটি সম্পূর্ণ বাংলা ইসলামিক আমল ট্র্যাকিং অ্যাপ্লিকেশন যা নামাজের সময়, যিকির কাউন্টার, দৈনিক আমল চেকলিস্ট, কুরআন/হাদীস পড়া, গুনাহ ট্র্যাকিং সহ কাফফারা হিসাব, বিস্তারিত পরিসংখ্যান, কাস্টম রিমাইন্ডার এবং ক্লাউড সিঙ্ক্রোনাইজেশন প্রদান করে।

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)
![Notifications](https://img.shields.io/badge/Smart_Notifications-Enabled-green.svg)
![License](https://img.shields.io/badge/License-Proprietary-red.svg)

## 🌟 Highlights

- ✅ **Real-time Prayer Times** with GPS-based accurate calculation (Hanafi madhab)
- 📿 **Dhikr Counter** with 6 pre-configured + custom dhikr, haptic feedback
- ✅ **Daily Amal Checklist** with 30+ pre-configured + custom Islamic tasks
- 📖 **Quran & Hadith Reading Tracker** with session logging and progress visualization
- 🚫 **Sin Tracker with Advanced Kaffara System** (fasting/feeding/mixed calculation)
- 📊 **Advanced Analytics** with weekly/monthly views, interactive calendar and streaks
- 🔔 **Smart Local Notifications** - Prayer time reminders (10-30 min before waqt ends)
- 🔔 **Custom Reminders** - সকাল-সন্ধ্যার যিকির, দৈনিক আমল এবং নিজের মতো রিমাইন্ডার
- ☁️ **Cloud Sync** with Firebase for multi-device support and auto-backup
- 🔐 **Email Authentication** with verification and password reset
- 🌙 **Beautiful Dark Theme** with gold accents and Bengali typography
- 📱 **Offline-First** - সম্পূর্ণ offline কাজ করে, পরে auto-sync হয়

## ✨ Features

### � অথেন্টিকেশন (Authentication)
- Email/Password authentication with Firebase
- Email verification system
- Secure login with password reset
- User profile management
- Display name customization

### ☁️ ক্লাউড সিংক (Cloud Sync)
- **Real-time Auto Sync**: Data automatically syncs to Firebase on changes
- **Offline Support**: Works offline, syncs when internet is available
- **Multi-device**: Access your data from any device
- **Manual Backup/Restore**: Full data backup and restore options
- **Firestore Integration**: Secure cloud storage with offline persistence

### 🕌 নামাজ ট্র্যাকিং (Prayer Tracking)
প্রতিদিনের পাঁচ ওয়াক্ত নামাজের সম্পূর্ণ ট্র্যাকিং সিস্টেম:

▪️ **প্রতিদিনের পাঁচ ওয়াক্ত নামাজ ট্র্যাক** করার সুবিধা  
▪️ **জামাতে / আউয়াল ওয়াক্তে / দেরিতে** — সব আলাদা করে দেখা যাবে  
▪️ **শেষ ৭ ও ৩০ দিনের নামাজ রিপোর্ট** দেখার সুবিধা  
▪️ **কোন নামাজ কাজা হয়েছে** — বিস্তারিত ও আপডেট সুবিধা  
▪️ GPS ভিত্তিক সঠিক নামাজের সময়  
▪️ Islamic Foundation Bangladesh হিসাব পদ্ধতি  
▪️ হানাফী মাযহাব অনুযায়ী আসরের সময়  
▪️ সম্পূর্ণ রাকাত ট্র্যাকিং (ফরজ, সুন্নত, নফল, বিতর)  
▪️ পরবর্তী নামাজের কাউন্টডাউন টাইমার  
▪️ **Cloud sync enabled**

### � যিকির ট্র্যাকিং (Dhikr Tracking)
দৈনিক যিকির ও তাসবিহের সম্পূর্ণ হিসাব রাখার সিস্টেম:

▪️ **৬টি বেসিক তাসবিহ (১০০ করে)**:
  - لا إله إلا الله (লা ইলাহা ইল্লাল্লাহ)
  - ﷺ দুরূদ শরীফ
  - أستغفر الله (আস্তাগফিরুল্লাহ)
  - سبحان الله (সুবহানাল্লাহ)
  - الحمد لله (আলহামদুলিল্লাহ)
  - الله أكبر (আল্লাহু আকবার)  

▪️ **নিজের মতো করে কাস্টম যিকির ও টার্গেট সেট** করার সুবিধা  
▪️ হ্যাপটিক ফিডব্যাক সহ টাচ কাউন্টার  
▪️ ভিজ্যুয়াল প্রোগ্রেস ইন্ডিকেটর  
▪️ দৈনিক পরিসংখ্যান ট্র্যাকিং  
▪️ আরবি টেক্সট সহ প্রদর্শন  
▪️ **Cloud sync enabled**

### 📿 দৈনিক আমল ট্র্যাকিং (Daily Amal Tracking)
প্রতিদিনের আমল সংগঠিত ও সহজ করার পূর্ণাঙ্গ সিস্টেম:

▪️ **ডিফল্ট ১৮টি বেসিক আমল** প্রি-কনফিগার করা:
  - মিসওয়াক (৬ বার)
  - নামাজের পর আযকার (৫ বার)
  - দৈনিক সূরা (ইয়াসিন, ওয়াকিয়া, মুলক)
  - সকাল-সন্ধ্যার দোয়া
  - কুরআন তিলাওয়াত, তাফসীর পড়া
  - হাদীস পড়া, ইসলামী বই পড়া
  - সাদকাহ, পিতা-মাতার সেবা
  - আত্মীয়তার সম্পর্ক রক্ষা
  - অসুস্থ দেখা, জানাযায় অংশগ্রহণ  

▪️ **নিজের প্রয়োজন অনুযায়ী কাস্টম আমল যোগ** করার সুবিধা  
▪️ **একবার যোগ করলেই যথেষ্ট** — প্রতিদিন আবার যোগ করতে হবে না  
▪️ **সকাল–সন্ধ্যার সব দোয়া এক জায়গায়**  
▪️ ক্যাটাগরি অনুযায়ী সাজানো  
▪️ সম্পূর্ণ হওয়ার সময় স্বয়ংক্রিয়ভাবে সংরক্ষিত  
▪️ **Cloud sync enabled**

### 📖 পড়াশোনা ট্র্যাকিং (Reading Tracking)
ইসলামিক পড়াশোনার সম্পূর্ণ রেকর্ড রাখার ব্যবস্থা:

▪️ **কুরআন, হাদীস ও তাফসীর** — তিনটি আলাদা ট্র্যাকিং  
▪️ **প্রতিদিন কত সময় পড়বেন নিজেই নির্ধারণ করুন**  
▪️ সূরা/আয়াত ট্র্যাকিং (কুরআনের জন্য)  
▪️ পৃষ্ঠা/অধ্যায় ট্র্যাকিং (বইয়ের জন্য)  
▪️ সেশন ভিত্তিক লগিং সহ সময়কাল  
▪️ দৈনিক পড়ার লক্ষ্য (মিনিট)  
▪️ প্রোগ্রেস ভিজ্যুয়ালাইজেশন  
▪️ **Cloud sync enabled**

### ⚠️ গুনাহ ট্র্যাকিং (Sin Tracking)
গুনাহ থেকে ফিরে আসা ও কাফফারার হিসাব রাখার সিস্টেম:

▪️ **ডিফল্ট ও কাস্টম গুনাহ যুক্ত করার সুবিধা**  
▪️ প্রি-কনফিগার করা গুনাহের ক্যাটাগরি (কবীরা ও সাগীরা)  
▪️ **কোন গুনাহের কাফফারা বাকি আছে স্পষ্টভাবে দেখা যাবে**  
▪️ **কাফফারা হিসাব ৪ ভাবে**: যিকির, দান, কুরআন ও নামাজ  
▪️ স্বয়ংক্রিয় রোজার দিন হিসাব  
▪️ খাওয়ানোর খরচ হিসাব (৬০ মিসকীন × ৳১০০)  
▪️ মিশ্র ক্ষতিপূরণ (রোজা + খাওয়ানো)  
▪️ সম্পূর্ণ পরিসংখ্যান:
  - মোট গুনাহ ট্র্যাক করা হয়েছে
  - কাফফারা প্রয়োজন এমন গুনাহ
  - মোট রোজার দিন প্রয়োজন
  - মোট খাওয়ানোর খরচ
  - মোট ক্ষতিপূরণ হিসাব  
▪️ তারিখ সহ দৈনিক ট্র্যাকিং  
▪️ **Cloud sync enabled**

### 📊 স্ট্যাটস ও স্ট্রিক সিস্টেম (Stats & Streak System)
বিস্তারিত পরিসংখ্যান ও মোটিভেশনাল ট্র্যাকিং:

▪️ **৬০%+ প্রোগ্রেস হলে স্ট্রিক কাউন্ট** শুরু হয়  
▪️ **সাপ্তাহিক ও মাসিক চার্ট**:
  - ৭ দিনের বার চার্ট
  - ক্যাটাগরি অনুযায়ী প্রোগ্রেস (নামাজ, আমল, যিকির, পড়াশোনা, গুনাহ)
  - সাপ্তাহিক সামারি সহ মোট হিসাব
  - কালার-কোডেড পারফরমেন্স ইন্ডিকেটর  

▪️ **ক্যালেন্ডার ভিউতে প্রতিদিনের বিস্তারিত রিপোর্ট**:
  - ইন্টারেক্টিভ ক্যালেন্ডার
  - রঙিন দিন চিহ্ন
  - যেকোনো তারিখে ক্লিক করে বিস্তারিত দেখা
  - মাসিক প্রোগ্রেস চার্ট
  - মাসিক সামারি স্ট্যাটিস্টিক্স  

▪️ **স্ট্রিক ট্র্যাকিং**:
  - বর্তমান স্ট্রিক কাউন্টার
  - সর্বোচ্চ স্ট্রিক রেকর্ড
  - পারফেক্ট দিন ইন্ডিকেটর (৮০%+ সম্পূর্ণ)
  - মোটিভেশনাল বার্তা

### 🏠 হোম ড্যাশবোর্ড (Home Dashboard)
- Greeting card with Hijri and Gregorian dates in Bengali
- Real-time prayer times display
- Next prayer countdown with automatic updates
- Today's progress section with:
  - Overall completion percentage
  - Animated circular progress bar
  - Dynamic color based on progress (Red < 50% < Orange < 80% < Green)
  - Motivational messages in Bengali
- Quick access cards to all features:
  - নামাজ (Prayer)
  - আমল (Daily Tasks)
  - যিকির (Dhikr)
  - পড়াশোনা (Reading)
  - গুনাহ (Sin Tracker)
  - পরিসংখ্যান (Statistics)

### 👤 প্রোফাইল (Profile)
- User information display
- Display name editing
- Email verification status
- Account creation date
- **Cloud sync controls**:
  - Manual backup button
  - Manual restore button
  - Auto-sync status indicator
- Logout functionality

### ⏰ স্মার্ট লোকাল নোটিফিকেশন (Smart Local Notifications)
সম্পূর্ণ অফলাইন নোটিফিকেশন সিস্টেম - কোনো ইন্টারনেট লাগবে না:

**নামাজের রিমাইন্ডার (Prayer Reminders)**:
▪️ **ওয়াক্ত শেষ হওয়ার আগে স্মার্ট রিমাইন্ডার** (১০/১৫/২০/৩০ মিনিট আগে সেট করুন)  
▪️ প্রতিটি নামাজের জন্য আলাদাভাবে চালু/বন্ধ করার সুবিধা  
▪️ **সঠিক timezone support** - আপনার স্থানীয় সময় অনুযায়ী  
▪️ **exactAllowWhileIdle** mode - নির্ভুল সময়ে notification আসবে  
▪️ ডিভাইস রিস্টার্টের পর auto restore  
▪️ অফলাইনে সম্পূর্ণ কাজ করে

**দৈনিক আমল রিমাইন্ডার**:
▪️ সকালের যিকির রিমাইন্ডার (সময় সেট করুন)  
▪️ সন্ধ্যার যিকির রিমাইন্ডার (সময় সেট করুন)  
▪️ দৈনিক আমল সম্পন্ন করার রিমাইন্ডার  
▪️ প্রতিটি আলাদাভাবে চালু/বন্ধ করা যায়

**কাস্টম রিমাইন্ডার (Custom Reminders)**:
▪️ **নিজের মতো করে সীমাহীন রিমাইন্ডার তৈরি করুন**  
▪️ **সপ্তাহের নির্দিষ্ট দিনে রিমাইন্ডার** (রবিবার-শনিবার যেকোনো দিন)  
▪️ প্রতিটি রিমাইন্ডারের জন্য:
  - Title (শিরোনাম)
  - Description (বিবরণ)
  - সঠিক Time (ঘন্টা:মিনিট)
  - নির্দিষ্ট দিন সিলেক্ট (একাধিক দিন)
  - চালু/বন্ধ toggle  
▪️ এডিট, ডিলিট এবং সহজে ম্যানেজ করুন  
▪️ **Real-time pending notifications দেখুন** - কোনটি কখন আসবে দেখতে পারবেন  
▪️ **স্থায়ী** - একবার সেট করলে প্রতি সপ্তাহে ঐ দিনে আসতে থাকবে  
▪️ Cloud sync enabled - অন্য ডিভাইসেও পাবেন

**নোটিফিকেশন সেটিংস**:
▪️ Android 13+ notification permission support  
▪️ Notification channels for better organization  
▪️ Vibration এবং sound সাপোর্ট  
▪️ High priority notifications - missed হবে না  
▪️ Background delivery with wake lock  
▪️ সেটিংস থেকে সব কিছু customize করুন

**Technical Features**:
▪️ **flutter_local_notifications** দিয়ে তৈরি - সম্পূর্ণ offline  
▪️ **zonedSchedule** - Timezone aware scheduling  
▪️ **matchDateTimeComponents** - সাপ্তাহিক repeat এর জন্য  
▪️ Device timezone auto-detect (Asia/Dhaka)  
▪️ Notification persistence across app restarts  
▪️ Exact alarm scheduling (Android 12+)  
▪️ Background task scheduling

### ⚙️ সেটিংস (Settings)
- Notification preferences per prayer
- Custom reminder management with day-of-week selection
- Prayer time adjustments (+/- minutes)
- Reminder time configuration (10/15/20/30 minutes before waqt end)
- Dhikr and daily amal reminder scheduling
- Pending notifications viewer
- Theme customization

---

## 📱 বিস্তারিত ব্যবহার নির্দেশিকা (Detailed Usage Guide)

### 🚀 প্রথমবার ব্যবহার (First Time Setup)

#### 1. অ্যাকাউন্ট তৈরি করুন
- অ্যাপ খুলুন → **রেজিস্টার** বাটনে ট্যাপ করুন
- আপনার **ইমেইল** এবং **পাসওয়ার্ড** দিন (কমপক্ষে 6 অক্ষর)
- **Display Name** (আপনার নাম) দিন
- **রেজিস্টার** বাটনে ক্লিক করুন
- আপনার ইমেইলে verification link পাঠানো হবে
- ইমেইল খুলে **Verify Email** লিঙ্কে ক্লিক করুন
- ফিরে এসে **লগইন** করুন

#### 2. প্রথম সেটআপ
- লগইন করার পর **Location Permission** চাইবে - **Allow** করুন (নামাজের সঠিক সময়ের জন্য)
- **Notification Permission** চাইবে - **Allow** করুন (রিমাইন্ডারের জন্য)
- যদি Android 12+ হয়, **Exact Alarm Permission** চাইবে - সেটিংসে গিয়ে **Allow** করুন
- আপনার **GPS চালু** রাখুন প্রথমবার (নামাজের সময় ক্যালকুলেট করতে)

### 🏠 হোম ড্যাশবোর্ড ব্যবহার (Using Home Dashboard)

**প্রধান অংশসমূহ:**
1. **Greeting Card** (উপরে):
   - আসসালামু আলাইকুম/শুভ সকাল/বিকাল/সন্ধ্যা/রাত
   - আজকের বাংলা তারিখ ও ইংরেজি তারিখ
   - হিজরি তারিখ

2. **Prayer Times Card**:
   - আজকের সব নামাজের সময়
   - বর্তমান ওয়াক্ত highlight হয়ে থাকে
   - পরবর্তী নামাজ পর্যন্ত কাউন্টডাউন
   - **Next Salah** দেখাবে কখন পরবর্তী নামাজ

3. **Today's Progress Card**:
   - আজকের সামগ্রিক অগ্রগতি (%)
   - Animated circular progress bar
   - রঙিন indicator:
     - 🔴 Red = 0-50% (আরও চেষ্টা করুন)
     - 🟠 Orange = 50-80% (ভালো চলছে)
     - 🟢 Green = 80-100% (চমৎকার!)
   - Motivational message বাংলায়

4. **Quick Access Cards** (6টি):
   - 🕌 নামাজ (Prayer Tracking)
   - ✅ আমল (Daily Tasks)
   - 📿 যিকির (Dhikr Counter)
   - 📖 পড়াশোনা (Reading Tracker)
   - 🚫 গুনাহ (Sin Tracker)
   - 📊 পরিসংখ্যান (Statistics)

### 🕌 নামাজ ট্র্যাকিং বিস্তারিত (Prayer Tracking Details)

#### প্রতিদিনের নামাজ রেকর্ড করা:
1. হোম থেকে **নামাজ** কার্ডে ট্যাপ করুন
2. আজকের পাঁচ ওয়াক্ত দেখতে পাবেন (Fajr, Dhuhr, Asr, Maghrib, Isha)
3. প্রতিটি নামাজের জন্য:
   - **যদি পড়ে থাকেন**: Green checkmark ট্যাপ করুন
   - **অবস্থা সিলেক্ট করুন**:
     - ✅ **জামাতে** (Congregation) - মসজিদে জামাতে পড়েছেন
     - 🕐 **আউয়াল ওয়াক্তে** (On Time) - সময়মতো বাসায় পড়েছেন
     - ⏰ **দেরিতে** (Late) - দেরিতে পড়েছেন
     - ❌ **কাজা** (Missed) - মিস হয়ে গেছে

4. **রাকাত কাউন্ট সেট করুন** (নিচের + - বাটন দিয়ে):
   - ফরজ রাকাত
   - সুন্নত রাকাত
   - নফল রাকাত
   - বিতর (এশার জন্য)
   - **ডিফল্ট ভ্যালু** পূর্ব-নির্ধারিত আছে (Hanafi madhab অনুযায়ী)

5. **Save** বাটনে ক্লিক করুন - সঙ্গে সঙ্গে সেভ হবে এবং cloud এ sync হবে

#### কাজা নামাজ দেখা ও আপডেট:
- **View Missed Prayers** বাটনে ক্লিক করুন
- কোন কোন নামাজ কাজা হয়েছে তারিখ সহ দেখবেন
- যদি পরে পড়ে নেন, সেই তারিখে গিয়ে আপডেট করুন

#### পুরাতন তারিখের নামাজ এডিট করা:
- Statistics → Monthly Calendar View এ যান
- যে তারিখ edit করবেন সেখানে ট্যাপ করুন
- Day Details Sheet খুলবে
- নামাজের সেকশনে **Edit** করুন

### 📿 যিকির কাউন্টার ব্যবহার (Using Dhikr Counter)

#### বেসিক যিকির (6টি pre-configured):
1. হোম থেকে **যিকির** কার্ডে ট্যাপ করুন
2. ৬টি তাসবিহ দেখবেন (প্রতিটিতে ১০০ টার্গেট):
   - لا إله إلا الله (লা ইলাহা ইল্লাল্লাহ)
   - ﷺ দুরূদ শরীফ
   - أستغفر الله (আস্তাগফিরুল্লাহ)
   - سবحان الله (সুবহানাল্লাহ)
   - الحمد لله (আলহামদুলিল্লাহ)
   - الله أكبر (আল্লাহু আকবার)

3. যেকোনো তাসবিহে ট্যাপ করুন - Counter screen খুলবে
4. **বড় বৃত্তে ট্যাপ করুন** - প্রতিবার count বাড়বে
5. **Haptic feedback** পাবেন (ফোন কাঁপবে)
6. **Progress ring** দেখাবে কতটা সম্পন্ন হয়েছে
7. **Current: X / Target: 100** দেখাবে উপরে
8. ১০০ পূর্ণ হলে **Complete!** দেখাবে
9. **Reset** বাটন - আবার শুরু করতে
10. **Save Session** - স্বয়ংক্রিয়ভাবে সেভ হয়

#### কাস্টম যিকির যোগ করা:
1. Dhikr screen এ উপরে ডানে **Add Custom** (+) বাটন
2. ফর্ম পূরণ করুন:
   - **Arabic Text**: আরবি টেক্সট (যেমন: أستغفر الله)
   - **Transliteration**: বাংলায় উচ্চারণ (যেমন: আস্তাগফিরুল্লাহ)
   - **Translation**: বাংলা অর্থ (যেমন: আমি আল্লাহর কাছে ক্ষমা চাই)
   - **Daily Target**: দৈনিক লক্ষ্য সংখ্যা (যেমন: 100, 500, 1000)
3. **Save** করুন - এখন লিস্টে দেখাবে

### ✅ দৈনিক আমল চেকলিস্ট (Daily Amal Checklist)

#### ডিফল্ট আমলসমূহ (18টি):
**সকালের আমল**:
- ফজরের নামাজ আওয়াল ওয়াক্তে
- সকালের আযকার
- সূরা ইয়াসিন তিলাওয়াত
- কুরআন তিলাওয়াত (দৈনিক পেজ)

**দিনের আমল**:
- মিসওয়াক (৬ বার - প্রতি নামাজের আগে + ঘুম থেকে)
- নামাজের পর আযকার (৫ বার)
- তাফসীর পড়া
- হাদীস পড়া

**বিকাল/সন্ধ্যার আমল**:
- সূরা ওয়াকিয়া তিলাওয়াত
- সন্ধ্যার আযকার
- সাদকাহ/দান
- আত্মীয়তার সম্পর্ক

**রাতের আমল**:
- এশার নামাজ জামাতে
- সূরা মুলক তিলাওয়াত
- তাহাজ্জুদ/নফল নামাজ

#### আমল সম্পন্ন করা:
1. **আমল** কার্ডে ট্যাপ করুন
2. যে আমল করেছেন তার পাশের **checkbox** এ ট্যাপ করুন
3. সঙ্গে সঙ্গে সেভ হবে + cloud sync হবে
4. সবুজ checkmark দেখাবে - সম্পন্ন
5. Un-check করতে আবার ট্যাপ করুন

#### কাস্টম আমল যোগ করা:
1. উপরে **Add Custom Task** (+) বাটন
2. ফর্ম পূরণ করুন:
   - **Task Name**: আমলের নাম (যেমন: দুধা নামাজ)
   - **Category**: ক্যাটাগরি সিলেক্ট করুন
   - **Description** (optional): বিবরণ
3. **Save** করুন
4. **একবার যোগ করলেই চিরদিনের জন্য** - প্রতিদিন দেখাবে

#### কাস্টম আমল এডিট/ডিলিট:
- কাস্টম আমলে **long press** করুন
- Edit বা Delete অপশন আসবে
- ডিফল্ট আমল এডিট/ডিলিট করা যায় না

### 📖 পড়াশোনা ট্র্যাকার (Reading Tracker)

#### তিন ধরনের ট্র্যাকিং:
1. **কুরআন তিলাওয়াত** (Quran)
2. **তাফসীর পড়া** (Tafsir)
3. **হাদীস পড়া** (Hadith)

#### সেশন শুরু করা:
1. **পড়াশোনা** কার্ডে ট্যাপ করুন
2. যেটা পড়বেন সেই tab সিলেক্ট করুন (কুরআন/তাফসীর/হাদীস)
3. **Start Session** বাটনে ক্লিক করুন
4. **Timer** শুরু হবে - কত মিনিট পড়ছেন কাউন্ট হবে
5. পড়া শেষ হলে **Stop Session**

#### ডিটেইলস দেওয়া:
কুরআনের জন্য:
- সূরা নাম বা নম্বর
- আয়াত নম্বর (শুরু - শেষ)
- পৃষ্ঠা নম্বর

তাফসীর/হাদীসের জন্য:
- বইয়ের নাম
- অধ্যায়/পৃষ্ঠা নম্বর

#### Daily Goal সেট করা:
- **Set Daily Goal** বাটন
- কত মিনিট পড়বেন প্রতিদিন (যেমন: 30 min)
- Progress bar দেখাবে কতটা হয়েছে

#### History দেখা:
- নিচে scroll করুন
- আজকের এবং আগের সব sessions দেখবেন
- Date, Duration, Details সহ

### 🚫 গুনাহ ট্র্্যাকিং ও কাফফারা (Sin Tracking & Kaffara)

#### গুনাহ যোগ করা:
1. **গুনাহ** কার্ডে ট্যাপ করুন
2. উপরে **Add Sin Entry** (+) বাটন
3. ফর্ম পূরণ করুন:
   - **Sin Type**: ড্রপডাউন থেকে গুনাহ সিলেক্ট করুন
   - **Date**: তারিখ সিলেক্ট করুন (default: আজ)
   - **Notes** (optional): কোনো নোট যোগ করুন
4. **Save** করুন

#### প্রি-কনফিগারড গুনাহের তালিকা:

**কবীরা গুনাহ (Major Sins)** - কাফফারা প্রয়োজন:
- গীবত (Backbiting) - ৬০ দিন রোজা OR ৳৬,০০০
- মিথ্যা শপথ (False Oath) - ৬০ দিন রোজা OR ৳৬,০০০
- অহংকার (Pride) - ৬০ দিন রোজা OR ৳৬,০০০
- হারাম দেখা (Watching Haram) - ৬০ দিন রোজা OR ৳৬,০০০

**সাগীরা গুনাহ (Minor Sins)** - তওবা যথেষ্ট:
- মিথ্যা কথা (Lying)
- হিংসা (Envy)
- সময় নষ্ট (Wasting Time)
- অলসতা (Laziness)

#### কাফফারা হিসাব দেখা:
**Kaffara Calculator** card এ:
- **মোট রোজার দিন**: সব কবীরা গুনাহের জন্য মোট কত দিন রোজা
- **মোট খাওয়ানোর খরচ**: ৬০ মিসকীন × ৳১০০/মিসকীন × গুনাহ সংখ্যা
- **মিশ্র হিসাব**: কিছু রোজা + বাকি টাকা দিয়ে

**Compensations Options**:
1. **Dhikr Based**: ১০০০ বার তওবার দোয়া পড়ুন
2. **Charity Based**: নির্দিষ্ট পরিমাণ দান করুন
3. **Quran Based**: নির্দিষ্ট পরিমাণ কুরআন তিলাওয়াত
4. **Salah Based**: নফল নামাজ পড়ুন

#### কাস্টম গুনাহ যোগ করা:
1. **Manage Sin Types** বাটন
2. **Add New Type** (+)
3. ফর্ম পূরণ করুন:
   - **Name (Bangla)**: বাংলা নাম
   - **Name (English)**: ইংরেজি নাম
   - **Category**: কবীরা/সাগীরা
   - **Requires Kaffara**: Yes/No
   - **Description**: বিবরণ
4. **Save** করুন

#### গুনাহ এডিট/ডিলিট:
- গুনাহ entry তে **tap** করুন
- Edit বা Delete অপশন
- Date, Type, Notes পরিবর্তন করতে পারবেন

### 📊 পরিসংখ্যান দেখা (Viewing Statistics)

#### দুটি ভিউ:
1. **সাপ্তাহিক চার্ট (Weekly View)** - ডিফল্ট
2. **মাসিক ক্যালেন্ডার (Monthly View)** - Calendar icon

#### সাপ্তাহিক ভিউ:
**Streak Card** (উপরে):
- **Current Streak**: বর্তমান ধারাবাহিকতা (X days)
- **Best Streak**: সর্বোচ্চ রেকর্ড
- **Perfect Days**: ৮০%+ দিনসমূহ
- **60%+ প্রোগ্রেস থাকলে স্ট্রিক কাউন্ট হয়**

**Weekly Chart**:
- গত ৭ দিনের bar chart
- প্রতিদিনের % progress
- রঙিন indicator (Red/Orange/Green)

**Category Progress**:
- 🕌 নামাজ (Prayer)
- ✅ আমল (Daily Tasks)
- 📿 যিকির (Dhikr)
- 📖 পড়াশোনা (Reading)
- 🚫 গুনাহ নিয়ন্ত্রণ (Sin Control)
- প্রতিটির জন্য আলাদা progress bar

**Weekly Summary**:
- মোট নামাজ পড়া হয়েছে
- মোট আমল সম্পন্ন
- মোট যিকির গণনা
- মোট পড়ার সময়
- গুনাহ রেকর্ড

#### মাসিক ভিউ (Calendar):
1. উপরে ডানে **Calendar** icon এ ট্যাপ করুন
2. **Interactive Calendar** দেখাবে:
   - 🔴 Red = 0-50% progress
   - 🟠 Orange = 50-80% progress
   - 🟢 Green = 80-100% progress
   - ⚪ White/Grey = কোনো data নেই

3. **যেকোনো তারিখে ট্যাপ করুন** - Day Details Sheet খুলবে:
   - সেদিনের সামগ্রিক progress
   - নামাজের বিস্তারিত (কোনগুলো পড়া, rakat count)
   - আমলের বিস্তারিত (কোনগুলো সম্পন্ন)
   - যিকির সেশনস
   - পড়াশোনা সেশনস
   - গুনাহ entries (যদি থাকে)

4. **Monthly Summary** (নিচে):
   - Average Daily Progress
   - Total Prayers Prayed
   - Total Amals Completed
   - Total Dhikr Count
   - Total Reading Time
   - Streak Information

5. **Month Navigation**:
   - উপরে তীর বাটন - আগের/পরের মাস

### 🔔 নোটিফিকেশন সেটআপ (Notification Setup)

#### প্রথম সেটআপ (Android 13+):
1. **Settings** → **রিমাইন্ডার সেটিংস**
2. যদি Permission না থাকে:
   - **"Allow Notifications"** বাটন দেখাবে
   - ট্যাপ করুন → System settings খুলবে
   - **"Amal Tracker"** app খুঁজুন
   - **Notifications** ON করুন
3. ফিরে আসুন অ্যাপে

#### নামাজের রিমাইন্ডার সেট করা:
1. **Settings** → **রিমাইন্ডার সেটিংস**
2. **নামাজের রিমাইন্ডার** toggle ON করুন
3. **ওয়াক্ত শেষের আগে** সিলেক্ট করুন (10/15/20/30 min)
4. প্রতিটি নামাজ আলাদা ON/OFF করুন:
   - ফজর
   - যোহর
   - আসর
   - মাগরিব
   - এশা

**কীভাবে কাজ করে**:
- Prayer times প্রতিদিন auto-calculate হয়
- আপনার সিলেক্ট করা সময়ের X মিনিট আগে notification আসবে
- উদাহরণ: মাগরিব 5:30 PM, ১৫ min before সেট → 5:15 PM এ notification

#### যিকিরের রিমাইন্ডার:
1. **সকালের যিকির** toggle ON করুন
2. সময় সিলেক্ট করুন (যেমন: 8:00 AM)
3. **সন্ধ্যার যিকির** toggle ON করুন
4. সময় সিলেক্ট করুন (যেমন: 6:00 PM)

#### কাস্টম রিমাইন্ডার তৈরি:
1. **Settings** → **রিমাইন্ডার সেটিংস**
2. **কাস্টম রিমাইন্ডার** সেকশনে **যোগ করুন** বাটন
3. বা সরাসরি **Custom Reminders** screen এ যান
4. **Add Reminder** (+) বাটন
5. ফর্ম পূরণ করুন:
   - **Title**: রিমাইন্ডারের শিরোনাম (যেমন: তাহাজ্জুদ নামাজ)
   - **Description**: বিবরণ (যেমন: তাহাজ্জুদ পড়তে উঠুন)
   - **Time**: সঠিক সময় (যেমন: 3:30 AM)
   - **Days**: দিন সিলেক্ট করুন (একাধিক সিলেক্ট করতে পারবেন):
     - 🌞 Sunday (রবিবার)
     - 🌙 Monday (সোমবার)
     - 🔥 Tuesday (মঙ্গলবার)
     - 💧 Wednesday (বুধবার)
     - 🌲 Thursday (বৃহস্পতিবার)
     - 🕌 Friday (শুক্রবার)
     - 🌟 Saturday (শনিবার)

6. **Save** করুন
7. **Toggle ON/OFF** করে চালু/বন্ধ করুন

**কাস্টম রিমাইন্ডার উদাহরণ**:
- তাহাজ্জুদ নামাজ (প্রতিদিন 3:30 AM)
- কুরআন তিলাওয়াত (শুক্রবার 9:00 AM)
- জুমার নামাজ (শুক্রবার 12:30 PM)
- সাপ্তাহিক রোজা (সোম-বৃহস্পতিবার সকাল 6:00 AM)
- তাফসীর ক্লাস (রবি-মঙ্গল-বৃহস্পতি 8:00 PM)

#### Pending Notifications দেখা:
1. **Custom Reminders** screen এ
2. নিচে **View Pending Notifications** বাটন
3. **সব scheduled notifications** দেখবেন:
   - ID number
   - Title
   - Time & Date
   - কখন fire হবে

#### রিমাইন্ডার এডিট/ডিলিট:
- রিমাইন্ডার card এ **Edit** icon (✏️)
- অথবা **Delete** icon (🗑️)
- Toggle switch দিয়ে সাময়িক বন্ধ করতে পারবেন

#### Notification Troubleshooting:
**যদি notification না আসে**:
1. **App Settings** চেক করুন → Notifications ON আছে কিনা
2. **Battery Optimization** বন্ধ করুন:
   - Settings → Apps → Amal Tracker
   - Battery → Unrestricted
3. **Exact Alarm Permission** (Android 12+):
   - Settings → Apps → Special Access → Alarms & Reminders
   - Amal Tracker → Allow
4. **Do Not Disturb** mode চেক করুন
5. অ্যাপ restart করুন

### ☁️ ক্লাউড সিঙ্ক ব্যবহার (Using Cloud Sync)

#### Auto Sync (স্বয়ংক্রিয়):
- প্রতিটি ডেটা পরিবর্তনে **স্বয়ংক্রিয়ভাবে sync** হয়
- Internet থাকলে সঙ্গে সঙ্গে
- Internet না থাকলে **queue তে রাখে**, পরে sync করে
- কোনো বাটন চাপতে হয় না

#### Manual Backup:
1. **Profile** screen এ যান (উপরে ডানে profile icon)
2. **Backup Data** বাটনে ট্যাপ করুন
3. সব ডেটা Firestore এ upload হবে
4. **Success message** দেখাবে

#### Manual Restore:
1. **Profile** screen এ যান
2. **Restore Data** বাটনে ট্যাপ করুন
3. Firestore থেকে সব ডেটা download হবে
4. **Local Hive** database update হবে
5. **UI refresh** হবে

#### Multi-Device ব্যবহার:
1. একই **email/password** দিয়ে অন্য device এ login করুন
2. স্বয়ংক্রিয়ভাবে সব ডেটা **restore** হবে
3. দুই device এই change করলে **auto-sync** হবে
4. **Last-write-wins** - সর্বশেষ পরিবর্তন টিকে থাকবে

#### Offline Mode:
- **Internet ছাড়াই** সম্পূর্ণ কাজ করে
- সব ডেটা local এ থাকে
- Internet আসলে auto-sync হয়
- **"Syncing..."** indicator দেখাবে যখন sync হচ্ছে

### 👤 প্রোফাইল ম্যানেজমেন্ট (Profile Management)

#### Display Name পরিবর্তন:
1. **Profile** screen
2. **Edit Display Name** বাটন
3. নতুন নাম লিখুন
4. **Save** করুন

#### Email Verification:
- যদি email verify না থাকে:
  - **"Email Not Verified"** দেখাবে
  - **Resend Verification Email** বাটন
  - Email check করুন → link ক্লিক করুন
  - অ্যাপ restart করুন

#### Logout:
- **Logout** বাটন → Confirmation dialog → **Yes**
- সব local data থাকবে, শুধু logout হবে

### ⚙️ সেটিংস কাস্টমাইজ (Settings Customization)

#### Prayer Time Adjustments:
- যদি আপনার এলাকায় সময় একটু আলাদা হয়
- **Adjust Prayer Times** option
- প্রতিটি নামাজের জন্য **+/- minutes** করতে পারবেন

#### Theme Settings:
- Dark mode (default - পরিবর্তন করা যায় না এখন)
- Gold accent color (#D4AF37)

#### Language:
- বাংলা (default - পরিবর্তন করা যায় না এখন)

### 🔄 Data Management Tips

#### Daily Routine:
1. **সকালে**: Prayer times check → Fajr mark → Morning dhikr
2. **দিনে**: আমল সম্পন্ন হলে check করুন → Dhikr করুন
3. **সন্ধ্যায়**: Evening dhikr → Reading session
4. **রাতে**: Statistics check করুন → Progress দেখুন

#### সাপ্তাহিক Check:
- শুক্রবার সন্ধ্যায় **Weekly Statistics** দেখুন
- কোথায় কম হয়েছে সেটা লক্ষ্য করুন
- পরের সপ্তাহের জন্য **target** করুন

#### মাসিক Review:
- মাস শেষে **Monthly Calendar** view দেখুন
- কোন দিনগুলো ভালো হয়েছে (green)
- কোন দিনগুলো দুর্বল (red)
- **Streak** maintain করার চেষ্টা করুন

#### Backup Best Practices:
- মাসে একবার **Manual Backup** নিন
- Internet থাকলে **Auto-sync** চালু রাখুন
- নতুন device এ **Restore** করে নিন
- **Email verification** করে রাখুন (account safety)

### 🎯 Performance Tips

#### Best Practices:
- **GPS** শুধু প্রথমবার চালু রাখুন (prayer times একবার load হলে)
- **Notifications** important গুলো রাখুন
- **Battery optimization** unrestricted রাখুন
- নিয়মিত **Statistics** check করুন (motivation)
- **Streak** maintain করুন (60%+ daily)

#### Storage Management:
- পুরাতন ডেটা auto-clean হয় না (সব থাকে)
- Cloud এ সব backed up থাকে
- প্রয়োজনে app **Clear Data** করে নতুন করে login করুন

#### Notification Management:
- শুধু important reminders ON রাখুন
- Too many notifications overwhelming হতে পারে
- Custom reminders wisely ব্যবহার করুন
- Test করে দেখুন সময়গুলো ঠিক আছে কিনা

---

## 🎨 Design

- **Theme**: Dark mode with Gold (#D4AF37) accent
- **Font**: Hind Siliguri (Bengali)
- **Colors**:
  - Background: #0A0A0A, #1A1A1A
  - Primary: #D4AF37 (Gold)
  - Success: #4CAF50
  - Warning: #FF9800
  - Error: #E57373

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # App-wide constants
│   └── theme/
│       └── app_theme.dart              # Theme configuration
├── data/
│   ├── local/
│   │   └── hive_service.dart           # Local database service
│   ├── models/
│   │   ├── prayer_tracking_model.dart  # Prayer data model
│   │   ├── dhikr_counter_model.dart    # Dhikr data model
│   │   ├── daily_amal_model.dart       # Daily amal model
│   │   ├── reading_tracker_model.dart  # Reading tracker model
│   │   ├── sin_tracker_model.dart      # Sin tracker model
│   │   └── statistics_model.dart       # Statistics model
│   └── services/
│       ├── prayer_time_service.dart    # Prayer time calculations
│       ├── permission_service.dart     # Permission handling
│       ├── notification_service.dart   # Local notifications
│       └── firestore_sync_service.dart # Cloud sync service
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart              # Authentication state
│   │   ├── prayer_times_provider.dart      # Prayer times state
│   │   ├── prayer_tracking_provider.dart   # Prayer tracking state
│   │   ├── daily_amal_provider.dart        # Daily amal state
│   │   ├── dhikr_counter_provider.dart     # Dhikr counter state
│   │   ├── reading_tracker_provider.dart   # Reading tracker state
│   │   ├── sin_tracker_provider.dart       # Sin tracker state
│   │   ├── statistics_provider.dart        # Statistics state
│   │   ├── notification_settings_provider.dart
│   │   └── custom_reminders_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   └── auth_screen.dart            # Login/Register/Forgot Password
│   │   ├── home/
│   │   │   └── home_screen.dart            # Main dashboard
│   │   ├── prayer/
│   │   │   └── prayer_tracker_screen.dart  # Prayer tracking
│   │   ├── dhikr/
│   │   │   └── dhikr_counter_screen.dart   # Dhikr counter
│   │   ├── daily_amal/
│   │   │   └── daily_amal_screen.dart      # Daily checklist
│   │   ├── reading/
│   │   │   └── reading_tracker_screen.dart # Reading tracker
│   │   ├── sin_tracker/
│   │   │   ├── sin_tracker_screen.dart     # Sin tracking
│   │   │   └── widgets/
│   │   │       ├── sin_type_manager.dart   # Manage sin types
│   │   │       ├── add_sin_dialog.dart     # Add sin entry
│   │   │       └── kaffara_calculator.dart # Kaffara calculation
│   │   ├── statistics/
│   │   │   ├── statistics_screen.dart
│   │   │   └── widgets/
│   │   │       ├── streak_card.dart
│   │   │       ├── tab_selector.dart
│   │   │       ├── weekly_progress_chart.dart
│   │   │       ├── monthly_calendar_view.dart
│   │   │       ├── category_progress_section.dart
│   │   │       ├── weekly_summary_section.dart
│   │   │       └── day_details_sheet.dart
│   │   ├── profile/
│   │   │   └── profile_screen.dart         # User profile & cloud sync
│   │   ├── settings/
│   │   │   └── settings_screen.dart        # App settings
│   │   └── notifications/
│   │       └── reminders_screen.dart       # Custom reminders
│   └── widgets/
│       └── [shared widgets]
└── main.dart                               # App entry point
```

## 🛠️ Tech Stack

### Core Framework
- **Flutter 3.0+** - Cross-platform mobile framework (Android + iOS)
- **Dart 3.0+** - Programming language

### State Management & Architecture
- **Riverpod 2.6.1** - Modern reactive state management
- **Clean Architecture** - Separation of concerns (core, data, presentation, services)

### Local Data Storage
- **Hive 2.2+** - Fast, lightweight NoSQL database
  - Prayer data, dhikr sessions, reading history
  - Offline-first architecture
  - Encrypted storage support

### Cloud Backend (Firebase)
- **Firebase Core 3.8+** - Firebase SDK initialization
- **Firebase Authentication 5.3+** - Secure user management with email/password
- **Cloud Firestore 5.6+** - Real-time cloud database with offline persistence
- **Automatic Sync** - Background synchronization when online

### Notification System ⭐
- **flutter_local_notifications 18.0.1** - Advanced local notification scheduling
  - `zonedSchedule` API for precise timing
  - `exactAllowWhileIdle` mode for exact alarms (Android 12+)
  - Multiple notification channels (Prayer, Dhikr, Custom)
  - High-priority notifications with sound & vibration
- **flutter_timezone 3.0.1** - Automatic device timezone detection
- **timezone 0.10.1** - Timezone-aware date/time calculations for accurate scheduling

### Islamic Features
- **adhan_dart 1.2+** - Precise Islamic prayer times calculation
  - Islamic Foundation Bangladesh (IFB) calculation method
  - Hanafi madhab juristic method for Asr
  - GPS-based location detection
  - Daily prayer time auto-calculation
- **Hijri Calendar** - Islamic calendar integration with Bangla localization

### Location Services
- **geolocator 13.0.2** - GPS location for prayer times
- **geocoding 3.0.0** - Reverse geocoding for location names
- **Permission handling** - Runtime location permission requests

### UI/UX Libraries
- **fl_chart 0.70.1** - Beautiful animated charts for statistics
  - Bar charts for weekly progress
  - Line charts for trends
  - Pie charts for category breakdown
- **table_calendar 3.1.2** - Interactive calendar view for monthly statistics
- **Google Fonts 6.2+** - Hind Siliguri font for beautiful Bangla typography
- **intl 0.20+** - Internationalization and date formatting
- **flutter_slidable 3.1.1** - Swipe actions for lists
- **shimmer 3.0.0** - Loading skeleton animations
- **lottie 3.1.3** - Animated illustrations
- **flutter_svg 2.0+** - SVG rendering support

### Storage & Permissions
- **permission_handler 11.3.1** - Runtime permissions
  - Location permission for prayer times
  - Notification permission (Android 13+)
  - Exact alarm permission (Android 12+)
  - Battery optimization handling
- **path_provider 2.1.5** - App directories for file storage
- **shared_preferences 2.3+** - Simple key-value storage

### Utilities
- **uuid 4.5+** - Unique ID generation for entries
- **url_launcher 6.3+** - External URL handling (privacy policy, etc.)
- **easy_localization 3.0+** - Internationalization framework

## 📱 Screenshots

| হোম | নামাজ | যিকির | আমল |
|-----|-------|-------|------|
| Home Dashboard with Progress | Prayer Times & Tracker | Dhikr Counter | Daily Amal Checklist |

| পড়াশোনা | গুনাহ ট্র্যাকার | পরিসংখ্যান (সাপ্তাহিক) | পরিসংখ্যান (মাসিক) |
|----------|----------------|------------------------|-------------------|
| Reading Tracker | Sin Tracker with Kaffara | Weekly Statistics | Monthly Calendar |

| লগইন | প্রোফাইল | সেটিংস |
|------|----------|---------|
| Authentication | Profile & Cloud Sync | Settings & Notifications |

## 🚀 Installation & Setup

### Prerequisites
- **Flutter SDK 3.0.0+**
- **Dart SDK 3.0.0+**
- **Android Studio** or **VS Code** with Flutter extension
- **Android device** (API 21+ / Android 5.0+) or **iOS device** (iOS 12+)
- **Firebase account** (for cloud sync features - free tier sufficient)

### Quick Setup

#### 1. Clone the repository
```bash
git clone https://github.com/ArshadEbrahim/amal-tracker.git
cd amal-tracker
```

#### 2. Install dependencies
```bash
flutter pub get
```

#### 3. Firebase Setup (Required for Authentication & Cloud Sync)

**A. Create Firebase Project:**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"** → Enter project name → Continue
3. Disable Google Analytics (optional) → Create project

**B. Enable Authentication:**
1. In Firebase Console → **Authentication** → **Get Started**
2. Click **"Sign-in method"** tab
3. Enable **"Email/Password"** provider
4. Click **Enable** → Save

**C. Enable Cloud Firestore:**
1. In Firebase Console → **Firestore Database** → **Create database**
2. Select **"Start in production mode"**
3. Choose location (preferably closest region)
4. Click **Enable**

**D. Configure Firestore Security Rules:**
1. Go to **Firestore Database** → **Rules** tab
2. Replace with:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User-specific data - only authenticated user can access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow users to read public data (if needed in future)
    match /public/{document=**} {
      allow read: if request.auth != null;
    }
  }
}
```
3. Click **Publish**

**E. Add Android App to Firebase:**
1. In Firebase Console → **Project Settings** (⚙️)
2. Click **"Add app"** → Select **Android** icon
3. Enter package name: `com.example.amal_tracker` (or your package name from `android/app/build.gradle`)
4. Click **"Register app"**
5. Download **`google-services.json`** file
6. Place it in: `android/app/google-services.json`
7. Click **Next** → **Next** → **Continue to console**

**F. Add iOS App to Firebase (Optional):**
1. In Firebase Console → **Project Settings** (⚙️)
2. Click **"Add app"** → Select **iOS** icon
3. Enter bundle ID: `com.example.amalTracker` (or from `ios/Runner.xcodeproj/project.pbxproj`)
4. Click **"Register app"**
5. Download **`GoogleService-Info.plist`** file
6. Place it in: `ios/Runner/GoogleService-Info.plist`
7. Click **Next** → **Next** → **Continue to console**

#### 4. Run the app
```bash
# Check connected devices
flutter devices

# Run on connected device
flutter run

# Run in release mode (better performance)
flutter run --release
```

#### 5. Build APK (Android)
```bash
# Build ARM64 APK (recommended - smaller size)
flutter build apk --target-platform android-arm64 --split-per-abi

# Or build universal APK (larger but works on all devices)
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### 6. Build iOS (Mac only)
```bash
flutter build ios --release
```

### 🔐 Firebase Configuration Details

**Firestore Data Structure:**
```
users/
  └── {userId}/
      └── data/
          ├── prayer_tracking/
          │   └── days/
          │       └── {date}/            # e.g., "2025-01-20"
          │           ├── prayers: {...}  # Fajr, Dhuhr, Asr, Maghrib, Isha
          │           └── timestamp: ...
          │
          ├── daily_amal/
          │   └── days/
          │       └── {date}/
          │           ├── checklist: [...]
          │           └── timestamp: ...
          │
          ├── dhikr_counter/
          │   └── days/
          │       └── {date}/
          │           ├── sessions: [...]
          │           └── timestamp: ...
          │
          ├── reading_tracker/
          │   └── days/
          │       └── {date}/
          │           ├── sessions: [...]
          │           └── timestamp: ...
          │
          ├── sin_tracker/
          │   └── days/
          │       └── {date}/
          │           ├── entries: [...]
          │           └── timestamp: ...
          │
          ├── sin_types/              # Custom sin types
          │   └── types: [...]
          │
          └── custom_reminders/       # Custom notification reminders
              └── reminders: [...]
```

**Auto-sync Triggers:**
- ✅ Prayer marked/updated → Immediate sync
- ✅ Amal checked/unchecked → Immediate sync
- ✅ Dhikr session completed → Immediate sync
- ✅ Reading session ended → Immediate sync
- ✅ Sin entry added → Immediate sync
- ✅ Custom reminder created/edited → Immediate sync
- 🔄 Background sync on app resume (if offline changes exist)

### 🔧 Configuration

### Prayer Calculation
| Setting | Value |
|---------|-------|
| Method | Islamic Foundation Bangladesh |
| Fajr Angle | 18.5° |
| Isha Angle | 17.5° |
| Madhab | Hanafi |

### Default Prayer Rakats
| Prayer | Rakats |
|--------|--------|
| ফজর | 2 সুন্নত + 2 ফরজ |
| যোহর | 4 সুন্নত + 4 ফরজ + 2 সুন্নত + 2 নফল |
| আসর | 4 সুন্নত + 4 ফরজ |
| মাগরিব | 3 ফরজ + 2 সুন্নত + 2 নফল |
| এশা | 4 সুন্নত + 4 ফরজ + 2 সুন্নত + 2 নফল + 3 বিতর |

### Default Dhikr (100x each)
- لا إله إلا الله (লা ইলাহা ইল্লাল্লাহ)
- ﷺ দুরূদ শরীফ
- أستغفر الله (আস্তাগফিরুল্লাহ)
- سبحان الله (সুবহানাল্লাহ)
- الحمد لله (আলহামদুলিল্লাহ)
- الله أكبر (আল্লাহু আকবার)
- لا حول ولا قوة إلا بالله (লা হাওলা ওয়ালা কুওয়াতা)

### Sin Types & Kaffara
| Sin Category | Type | Kaffara Required | Calculation |
|--------------|------|------------------|-------------|
| গীবত (Backbiting) | Kabira | Yes | 60 days fasting OR ৳6,000 |
| মিথ্যা (Lying) | Saghira | No | - |
| হিংসা (Envy) | Saghira | No | - |
| অহংকার (Pride) | Kabira | Yes | 60 days fasting OR ৳6,000 |
| সময় নষ্ট (Wasting time) | Saghira | No | - |

**Kaffara Calculation Formula:**
- 1 Major Sin = 60 days fasting OR 60 poor people × ৳100/person = ৳6,000
- Mixed option: Some fasting + remaining as feeding cost

## 📋 Data Persistence

### Local Storage (Hive)
All data is stored locally using Hive NoSQL database for offline-first functionality:

| Box Name | Purpose | Cloud Sync |
|----------|---------|------------|
| `prayer_tracking` | Daily prayer records with rakat details | ✅ Auto |
| `dhikr_counter` | Dhikr sessions and counts | ✅ Auto |
| `daily_amal` | Daily checklist completion | ✅ Auto |
| `reading_tracker` | Quran/Hadith reading sessions | ✅ Auto |
| `sin_tracker` | Sin entries with dates | ✅ Auto |
| `sin_types` | Custom sin type configurations | ✅ Auto |
| `statistics` | Aggregated analytics data | ❌ Local only |
| `notification_settings` | Notification preferences | ❌ Local only |
| `custom_reminders` | User-defined reminders | ✅ Auto |
| `auth_cache` | Authentication cache | ❌ Local only |

### Cloud Storage (Firestore)
- **Real-time Sync**: Changes automatically sync to Firestore when online
- **Offline Persistence**: Firestore caches data locally for offline access
- **Automatic Retry**: Failed syncs are retried when connection is restored
- **Conflict Resolution**: Last-write-wins strategy with server timestamps
- **Data Structure**: Organized by user → category → days/entries

### Data Flow
```
User Action → Local Hive Update → Firestore Sync (if online)
                                → Queued for sync (if offline)
                                
Login → Restore from Firestore → Update Local Hive → Refresh UI
```

### Backup & Restore
- **Auto Backup**: Every data change is automatically backed up to cloud
- **Manual Backup**: Full data upload via profile screen
- **Auto Restore**: Data automatically restored on login
- **Manual Restore**: Full data download via profile screen
- **Multi-device**: Same account works across multiple devices

## 🔐 Permissions

### Android (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

**Purpose:**
- `INTERNET` - Firebase cloud sync
- `ACCESS_FINE_LOCATION` - Accurate prayer times based on GPS
- `POST_NOTIFICATIONS` - Prayer time reminders (Android 13+)
- `SCHEDULE_EXACT_ALARM` - Precise notification scheduling
- `RECEIVE_BOOT_COMPLETED` - Restore alarms after device restart
- `VIBRATE` - Notification haptic feedback
- `WAKE_LOCK` - Background notification delivery

### iOS (`Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>সঠিক নামাজের সময় নির্ধারণের জন্য লোকেশন প্রয়োজন</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>নামাজের সময় রিমাইন্ডার পাঠানোর জন্য লোকেশন প্রয়োজন</string>
```

## 🗓️ Development Roadmap

### ✅ Phase 1: Core Features (Completed)
- [x] Project foundation & clean architecture
- [x] Prayer times with GPS & Hanafi madhab
- [x] Prayer tracker with detailed rakat tracking
- [x] Dhikr counter with custom items & haptic feedback
- [x] Daily Amal checklist (30+ pre-configured tasks)
- [x] Reading tracker (Quran/Tafsir/Hadith)
- [x] Sin tracker with Kaffara calculation system
- [x] Statistics with weekly/monthly views
- [x] Interactive calendar with day details
- [x] Streak tracking & motivation system
- [x] Notifications & custom reminders
- [x] Settings screen with preferences
- [x] Data persistence with Hive
- [x] Bengali localization throughout

### ✅ Phase 2: Cloud Sync (Completed)
- [x] Firebase integration
- [x] Email/Password authentication
- [x] Email verification system
- [x] User profile management
- [x] Cloud Firestore data sync
- [x] Offline persistence with auto-sync
- [x] Multi-device support
- [x] Manual backup/restore options
- [x] Auto-restore on login

### 🔮 Phase 3: Enhanced Features (Planned)
- [ ] Home screen widget (Prayer times & today's progress)
- [ ] Ramadan mode:
  - [ ] Suhoor/Iftar timings
  - [ ] Taraweeh tracker
  - [ ] Sadaqah/Charity log
  - [ ] 30-day Quran completion tracker
- [ ] Achievement badges & gamification:
  - [ ] Perfect week badges
  - [ ] Prayer consistency awards
  - [ ] Reading milestone badges
- [ ] Export data (JSON/PDF/CSV)
- [ ] Import data from backup files
- [ ] Qibla compass with GPS
- [ ] Hijri calendar integration
- [ ] 99 Names of Allah with meanings
- [ ] Dua collection in Bengali

### 🌍 Phase 4: Expansion (Future)
- [ ] Multi-language support:
  - [ ] English interface
  - [ ] Arabic transliteration
  - [ ] Urdu interface
- [ ] Social features:
  - [ ] Family group tracking
  - [ ] Motivational quotes sharing
  - [ ] Community challenges
- [ ] Advanced analytics:
  - [ ] Yearly comparison charts
  - [ ] Habit formation insights
  - [ ] Personalized recommendations
- [ ] Platform expansion:
  - [ ] Apple Watch companion app
  - [ ] WearOS support
  - [ ] iPad/tablet optimization
  - [ ] Desktop app (Windows/macOS/Linux)
- [ ] Accessibility:
  - [ ] Voice commands
  - [ ] Screen reader optimization
  - [ ] High contrast mode

## 🏗️ Architecture

### Design Pattern
- **Clean Architecture** with separation of concerns
- **MVVM** (Model-View-ViewModel) pattern
- **Repository Pattern** for data access
- **Provider Pattern** (Riverpod) for state management

### Layers
```
┌─────────────────────────────────────┐
│     Presentation Layer              │
│  (Screens, Widgets, Providers)      │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│       Domain Layer                  │
│    (Business Logic, Models)         │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│        Data Layer                   │
│  (Hive, Firestore, Services)        │
└─────────────────────────────────────┘
```

### State Management
- **Riverpod** for reactive state
- **ConsumerWidget** for UI updates
- **FutureProvider** for async data
- **StateNotifierProvider** for complex state

### Offline-First Strategy
1. User action triggers local Hive update
2. UI updates immediately from local data
3. Background sync to Firestore (if online)
4. Offline changes queued automatically
5. Auto-sync when connection restored

## 🔧 Key Technologies Explained

### Prayer Time Calculation
- **Library**: adhan_dart
- **Method**: Islamic Foundation Bangladesh (IFB)
- **Madhab**: Hanafi (Asr calculation)
- **Accuracy**: GPS-based coordinates with timezone support
- **Adjustments**: Manual +/- minutes for local variations

### Cloud Sync Architecture
- **Strategy**: Optimistic UI updates with background sync
- **Conflict Resolution**: Server timestamp wins
- **Security**: Firebase Auth with Firestore rules
- **Offline**: Full offline support with Firestore cache
- **Sync Trigger**: On data change, login, and manual request

### Notification System
- **Local Notifications**: flutter_local_notifications
- **Scheduling**: Exact alarms with timezone support
- **Channels**: Prayer reminders, custom reminders
- **Android 13+**: Runtime permission handling
- **Persistence**: Reschedule on device boot

## 🤝 Contributing

This is a private project. For contributions:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Standards
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable/function names
- Add comments for complex logic
- Write widget tests for UI components
- Bengali strings in separate localization files

## 🐛 Known Issues & Troubleshooting

### Common Issues

#### 1. Notifications not working
**Symptoms**: Prayer reminders or custom reminders not firing

**Solutions**:
- ✅ **Check notification permission** (Android 13+):
  - Settings → Apps → Amal Tracker → Notifications → Allow
- ✅ **Enable exact alarm permission** (Android 12+):
  - Settings → Apps → Special Access → Alarms & Reminders → Amal Tracker → Allow
- ✅ **Disable battery optimization**:
  - Settings → Apps → Amal Tracker → Battery → Unrestricted
- ✅ **Check Do Not Disturb mode** is not blocking notifications
- ✅ **Restart the app** to reschedule notifications
- ✅ Use **"Test Notifications"** in Settings to verify

#### 2. Prayer times not updating
**Symptoms**: Shows old times or "Loading..."

**Solutions**:
- ✅ **Enable location permission**:
  - Settings → Apps → Amal Tracker → Permissions → Location → Allow
- ✅ **Turn on GPS** on your device
- ✅ **Ensure internet connection** for first-time calculation
- ✅ **Pull down to refresh** on home screen
- ✅ Check if location services are working in other apps

#### 3. Cloud sync not working
**Symptoms**: Data not syncing across devices

**Solutions**:
- ✅ **Check internet connection**
- ✅ **Verify email is verified**:
  - Profile → Check "Email Verified" status
  - If not, click "Resend Verification Email"
- ✅ **Try manual sync**:
  - Profile → Backup Data (force upload)
  - Profile → Restore Data (force download)
- ✅ **Restart the app**
- ✅ **Re-login** if issue persists

#### 4. Statistics not showing
**Symptoms**: Charts empty or no data visible

**Solutions**:
- ✅ **Complete at least one activity** (mark prayer, check amal, etc.)
- ✅ **Wait a few seconds** for data to load
- ✅ **Change date range** (weekly/monthly toggle)
- ✅ **Pull down to refresh**

#### 5. App crashes on startup
**Symptoms**: App closes immediately after opening

**Solutions**:
- ✅ **Clear app cache**:
  - Settings → Apps → Amal Tracker → Storage → Clear Cache
- ✅ **Reinstall the app** (data will be restored from cloud if logged in)
- ✅ **Update to latest version**
- ✅ **Check Android version** (minimum: Android 5.0 / API 21)

### Platform-Specific Limitations

**Android:**
- ❗ **Battery optimization** on some brands (Xiaomi, Huawei, OnePlus) may kill background processes
  - Solution: Add to "Protected Apps" or disable battery optimization
- ❗ **Exact alarms** require explicit permission on Android 12+
  - Solution: App will prompt for permission automatically
- ❗ **Notification channels** cannot be deleted once created
  - Solution: User can disable channels in system settings

**iOS:**
- ❗ **Background notifications** are limited by iOS restrictions
  - Prayer reminders may not fire if app is force-closed
  - Solution: Keep app in background (don't swipe away)
- ❗ **Location "Always"** permission may not be granted
  - Solution: Prayer times will use last known location

### Performance Considerations

- 📊 **Large data sets** (1+ year of daily records) may slow down calendar view
- 🌐 **Poor internet** may cause delayed sync (queued for later)
- 📱 **Older devices** (< 2GB RAM) may experience slight lag in animations
- ⚡ **Multiple simultaneous operations** may briefly freeze UI

### Data Safety

- ✅ **All data encrypted** in Firebase
- ✅ **Local data protected** by Android/iOS security
- ✅ **No data shared** with third parties
- ✅ **Account deletion** removes all cloud data permanently
- ⚠️ **Clearing app data** removes local copy (recoverable from cloud sync)

## 🔄 Updates & Changelog

### Version 1.0.3 (January 13, 2026)
**Update Release - Documentation & Improvements**

#### 📝 Documentation Updates
- ✅ Comprehensive README with detailed usage guide (1,500+ lines)
- ✅ Settings screen manual updated with all features
- ✅ Added troubleshooting section with 25+ solutions
- ✅ Cloud sync documentation
- ✅ Notification system complete guide
- ✅ Installation & Firebase setup instructions

#### 🐛 Bug Fixes
- ✅ Fixed settings page content visibility issue
- ✅ Improved notification permission flow
- ✅ Enhanced error handling

#### 📱 UI/UX Improvements
- ✅ Better empty states in manual screen
- ✅ Improved help text throughout app
- ✅ Enhanced user guidance messages

---

### Version 1.0.2 (January 9, 2026)
**Major Release - Complete Overhaul**

#### ✨ New Features
- 🔔 **Advanced Local Notification System**:
  - Prayer reminders (10-30 minutes before waqt ends)
  - Daily dhikr reminders (morning & evening)
  - Unlimited custom reminders with weekly scheduling
  - Per-prayer toggle (enable/disable individual prayers)
  - Timezone-aware scheduling (Asia/Dhaka)
  - Exact alarm support (Android 12+)
  - Multiple notification channels
  - High-priority with sound & vibration

- 🕌 **Prayer Time Improvements**:
  - Islamic Foundation Bangladesh (IFB) method
  - Hanafi madhab for Asr calculation
  - GPS-based auto-detection
  - Manual time adjustments
  - Automatic daily recalculation
  - Waqt end time calculations for reminders

- 🌐 **Complete Cloud Sync**:
  - Real-time Firebase Firestore sync
  - Offline-first architecture
  - Auto-backup on every change
  - Multi-device support
  - Manual backup/restore options
  - Conflict resolution (last-write-wins)

- 📊 **Enhanced Statistics**:
  - Interactive monthly calendar view
  - Day details sheet with full history
  - Weekly progress bar charts
  - Category-wise progress breakdown
  - Streak tracking with motivational messages
  - Perfect days counter (80%+ progress)

- 🚫 **Complete Sin Tracker**:
  - Kaffara calculator for major sins
  - Pre-configured sin types (Kabira/Saghira)
  - Custom sin type creation
  - Multiple compensation options
  - Date-based filtering
  - Cloud sync for sin data

#### 🐛 Bug Fixes
- ✅ Fixed timezone issues (UTC → Asia/Dhaka)
- ✅ Fixed prayer reminders not scheduling
- ✅ Fixed custom reminders not triggering
- ✅ Fixed FCM issues on OnePlus devices (switched to local notifications)
- ✅ Fixed offline mode data persistence
- ✅ Fixed statistics not loading on first launch
- ✅ Fixed dhikr counter haptic feedback
- ✅ Fixed reading tracker session timer

#### 🔧 Technical Improvements
- ⚡ Upgraded to flutter_local_notifications 18.0.1
- ⚡ Added flutter_timezone 3.0.1 for accurate scheduling
- ⚡ Optimized Hive database queries
- ⚡ Improved Firebase sync performance
- ⚡ Reduced APK size (ARM64: 21.6MB)
- ⚡ Enhanced error handling throughout app
- ⚡ Added comprehensive logging for debugging

#### 📱 UI/UX Improvements
- 🎨 Refined dark theme with gold accents
- 🎨 Improved Bengali typography (Hind Siliguri)
- 🎨 Enhanced loading states with shimmer effects
- 🎨 Better empty states with helpful messages
- 🎨 Smooth animations and transitions
- 🎨 Consistent spacing and padding
- 🎨 Improved form validation messages

## 📄 License

Proprietary - All rights reserved © 2026

**Terms:**
- Personal and educational use permitted
- Commercial use requires explicit permission
- Modification and redistribution prohibited without authorization
- No warranty or liability provided
- Source code viewing allowed, copying prohibited

## 👨‍💻 Developer

**Developed by**: Arshad Ebrahim  
**For**: The Muslim Ummah ☪️  
**With**: ❤️ Love and dedication  
**Purpose**: Making Islamic daily practice easier for everyone

## 📞 Contact & Support

- **GitHub**: [ArshadEbrahim/amal-tracker](https://github.com/ArshadEbrahim/amal-tracker)
- **Email**: arshad.eb@example.com
- **Issues**: [GitHub Issues](https://github.com/ArshadEbrahim/amal-tracker/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ArshadEbrahim/amal-tracker/discussions)
- **Releases**: [Latest Updates](https://github.com/ArshadEbrahim/amal-tracker/releases)

## 🙏 Acknowledgments

- **adhan_dart** by [@iamriajul](https://github.com/iamriajul) - Accurate Islamic prayer time calculations
- **Flutter Team** - Amazing cross-platform framework
- **Firebase** - Reliable cloud infrastructure
- **Islamic Foundation Bangladesh** - Prayer time calculation methods
- **Muslim Community** - Valuable feedback and feature suggestions
- **Open Source Community** - Inspiration and code examples
- **Beta Testers** - Early testing and bug reports

## 💝 Support the Project

If this app has helped you track your daily ibadah and stay consistent, please:
- ⭐ **Star** this repository
- 📢 **Share** with other Muslims
- 🐛 **Report bugs** to help improve
- 💡 **Suggest features** for future updates
- 🤲 **Make dua** for the developer and users

## 🌟 Features Summary

✅ **5 Prayer Times** with GPS-based calculation  
✅ **Prayer Tracking** with detailed rakat counts  
✅ **6 Default Dhikr** counters with custom additions  
✅ **18+ Daily Amal** checklist with custom tasks  
✅ **Reading Tracker** for Quran/Tafsir/Hadith  
✅ **Sin Tracker** with Kaffara calculator  
✅ **Weekly Statistics** with colorful charts  
✅ **Monthly Calendar** with day-by-day details  
✅ **Streak Tracking** for motivation  
✅ **Smart Notifications** for prayers, dhikr, and custom reminders  
✅ **Cloud Sync** across multiple devices  
✅ **Offline Mode** - works without internet  
✅ **Bengali Interface** throughout  
✅ **Dark Theme** with golden accents  
✅ **Free & Open** (view-only source code)

---

**Project Status**: ✅ Production Ready & Actively Maintained  
**Current Version**: 1.0.3  
**Release Date**: January 9, 2026  
**Last Updated**: January 13, 2026  
**Minimum Flutter**: 3.0.0  
**Minimum Dart**: 3.0.0  
**Target Platforms**: Android 5.0+ (API 21+), iOS 12.0+  
**APK Size**: ~22 MB (ARM64)  
**Language**: Bengali (বাংলা)  
**Download Count**: 0+ (newly released)

---

<div align="center">

### جَزَاكَ ٱللَّٰهُ خَيْرًا
**May Allah reward you with goodness**

<br>

### الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ
**All praise is due to Allah, Lord of the worlds**

<br>

### رَبَّنَا تَقَبَّلْ مِنَّا ۖ إِنَّكَ أَنتَ السَّمِيعُ الْعَلِيمُ
**Our Lord, accept this from us. Indeed, You are the Hearing, the Knowing**

<br>

---

Made with 💚 for tracking good deeds and building consistent habits  
**Amal Tracker** - Your Daily Islamic Companion

</div>

