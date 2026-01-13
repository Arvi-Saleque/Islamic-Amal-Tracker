// Firebase Cloud Functions for Amal Tracker Reminders
// Deploy this to Firebase Cloud Functions

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// Prayer names in Bengali
const prayerNames = {
  fajr: 'ফজর',
  dhuhr: 'যোহর',
  asr: 'আসর',
  maghrib: 'মাগরিব',
  isha: 'এশা'
};

/**
 * Scheduled function that runs every minute to check and send reminders
 * This checks all users' reminder settings and sends FCM notifications at the right time
 */
exports.sendScheduledReminders = functions.pubsub
  .schedule('every 1 minutes')
  .timeZone('Asia/Dhaka')
  .onRun(async (context) => {
    const now = new Date();
    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();
    const currentTimeStr = `${currentHour.toString().padStart(2, '0')}:${currentMinute.toString().padStart(2, '0')}`;
    
    console.log(`Checking reminders at ${currentTimeStr}`);
    
    try {
      // Get all users with reminder settings
      const usersSnapshot = await db.collection('users').get();
      
      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;
        const userData = userDoc.data();
        const fcmToken = userData.fcmToken;
        
        if (!fcmToken) continue;
        
        // Get reminder settings
        const settingsDoc = await db.collection('users').doc(userId)
          .collection('settings').doc('reminders').get();
        
        if (!settingsDoc.exists) continue;
        
        const settings = settingsDoc.data();
        
        // Check Morning Dhikr
        if (settings.morningDhikrEnabled && settings.morningDhikrTime === currentTimeStr) {
          await sendNotification(fcmToken, {
            title: 'সকালের যিকির 🌅',
            body: 'সকালের যিকির পড়ার সময় হয়েছে। আল্লাহর যিকির করুন।',
            type: 'dhikr_morning'
          });
        }
        
        // Check Evening Dhikr
        if (settings.eveningDhikrEnabled && settings.eveningDhikrTime === currentTimeStr) {
          await sendNotification(fcmToken, {
            title: 'সন্ধ্যার যিকির 🌆',
            body: 'সন্ধ্যার যিকির পড়ার সময় হয়েছে। আল্লাহর যিকির করুন।',
            type: 'dhikr_evening'
          });
        }
        
        // Check Daily Amal Reminder
        if (settings.dailyAmalReminderEnabled && settings.dailyAmalReminderTime === currentTimeStr) {
          await sendNotification(fcmToken, {
            title: 'দৈনিক আমল রিমাইন্ডার ✨',
            body: 'আজকের আমলগুলো সম্পন্ন করুন। প্রতিদিনের ছোট ছোট আমল বড় সওয়াব এনে দেয়।',
            type: 'amal_daily'
          });
        }
        
        // Check Custom Reminders
        const customRemindersDoc = await db.collection('users').doc(userId)
          .collection('settings').doc('custom_reminders').get();
        
        if (customRemindersDoc.exists) {
          const customData = customRemindersDoc.data();
          const reminders = customData.reminders || [];
          const today = now.getDay(); // 0 = Sunday, 1 = Monday, etc.
          
          for (const reminder of reminders) {
            if (reminder.isEnabled && 
                reminder.time === currentTimeStr && 
                reminder.daysOfWeek.includes(today)) {
              await sendNotification(fcmToken, {
                title: reminder.title,
                body: reminder.description,
                type: 'custom_reminder'
              });
            }
          }
        }
      }
      
      console.log('Reminder check completed');
      return null;
    } catch (error) {
      console.error('Error sending reminders:', error);
      return null;
    }
  });

/**
 * Send FCM notification to a device
 */
async function sendNotification(token, data) {
  const message = {
    token: token,
    notification: {
      title: data.title,
      body: data.body,
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'amal_reminders',
        priority: 'high',
        defaultSound: true,
        defaultVibrateTimings: true,
      },
    },
    apns: {
      payload: {
        aps: {
          alert: {
            title: data.title,
            body: data.body,
          },
          sound: 'default',
          badge: 1,
        },
      },
    },
    data: {
      type: data.type,
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
  };
  
  try {
    await messaging.send(message);
    console.log(`Notification sent: ${data.title}`);
  } catch (error) {
    console.error(`Error sending notification to ${token}:`, error);
    // If token is invalid, remove it from the database
    if (error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered') {
      console.log('Invalid token, should be removed from database');
    }
  }
}

/**
 * Trigger when user's reminder settings are updated
 * This can be used for immediate notifications or logging
 */
exports.onReminderSettingsUpdate = functions.firestore
  .document('users/{userId}/settings/reminders')
  .onWrite(async (change, context) => {
    const userId = context.params.userId;
    const newData = change.after.exists ? change.after.data() : null;
    
    if (newData) {
      console.log(`Reminder settings updated for user ${userId}`);
      // You can add additional logic here, like sending a confirmation notification
    }
    
    return null;
  });
