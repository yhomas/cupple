

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

exports.sendCardNotification = onDocumentCreated(
  "notifications/{notificationId}",
  async (event) => {
    const data = event.data.data();
    const {fcmToken, title, body, data: payload} = data;

    if (!fcmToken) {
      console.log("No FCM token, skipping");
      return;
    }

    const message = {
      token: fcmToken,
      notification: {
        title: title || "Cupple",
        body: body || "新しい投稿があります",
      },
      data: payload || {},
      webpush: {
        fcmOptions: {
          link: "https://cupple-app-a9194.web.app",
        },
      },
    };

    try {
      const response = await getMessaging().send(message);
      console.log("Notification sent:", response);
      // Mark as sent
      await event.data.ref.update({sent: true, sentAt: new Date()});
    } catch (error) {
      console.error("Error sending notification:", error);
      await event.data.ref.update({sent: false, error: error.message});
    }
  }
);

