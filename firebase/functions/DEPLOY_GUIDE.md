# Firebase Cloud Functions Deployment Guide
# আমল ট্র্যাকার রিমাইন্ডার সার্ভিস

## রিমাইন্ডার কাজ করার জন্য Cloud Functions ডিপ্লয় করতে হবে

### ধাপ ১: Firebase CLI ইন্সটল করুন
```bash
npm install -g firebase-tools
```

### ধাপ ২: Firebase লগইন করুন
```bash
firebase login
```

### ধাপ ৩: Functions ফোল্ডারে যান
```bash
cd firebase/functions
```

### ধাপ ৪: Dependencies ইন্সটল করুন
```bash
npm install
```

### ধাপ ৫: Functions ডিপ্লয় করুন
```bash
firebase deploy --only functions
```

## ⚠️ গুরুত্বপূর্ণ তথ্য

1. **Firebase Blaze Plan প্রয়োজন**: Scheduled functions চালাতে হলে Firebase Blaze (Pay as you go) plan এ upgrade করতে হবে।

2. **Pricing**: 
   - প্রতি মাসে প্রথম 2 মিলিয়ন function invocations ফ্রি
   - Cloud Scheduler প্রতি মাসে 3টি job ফ্রি

3. **কিভাবে কাজ করে**:
   - প্রতি মিনিটে Cloud Function চলে
   - Firestore থেকে users এর reminder settings পড়ে
   - নির্ধারিত সময়ে FCM notification পাঠায়

## টেস্ট করার জন্য

Functions deploy হওয়ার পর:
1. অ্যাপে লগইন করুন
2. রিমাইন্ডার settings এ যান
3. যেকোনো রিমাইন্ডার enable করুন এবং সময় সেট করুন
4. সেই সময়ে notification আসবে (ইন্টারনেট অন থাকতে হবে)

## Logs দেখার জন্য
```bash
firebase functions:log
```
