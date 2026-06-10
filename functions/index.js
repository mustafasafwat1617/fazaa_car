const { setGlobalOptions } = require("firebase-functions");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

setGlobalOptions({ maxInstances: 10 });

exports.sendRequestStatusNotification = onDocumentUpdated(
  "requests/{requestId}",
  async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    const beforeStatus = beforeData.status;
    const afterStatus = afterData.status;

    if (beforeStatus === afterStatus) {
      return null;
    }

    if (afterStatus !== "في الطريق") {
      return null;
    }

    const userId = afterData.userId;

    if (!userId) {
      console.log("No userId found in request");
      return null;
    }

    const userDoc = await admin.firestore().collection("users").doc(userId).get();

    if (!userDoc.exists) {
      console.log("User document not found");
      return null;
    }

    const userData = userDoc.data();
    const token = userData.fcmToken;

    if (!token) {
      console.log("No FCM token found");
      return null;
    }

    const message = {
      token: token,
      notification: {
        title: "فزعة كار",
        body: "🚗 الميكانيكي في الطريق إليك",
      },
      data: {
        requestId: event.params.requestId,
        status: afterStatus,
      },
    };

    await admin.messaging().send(message);

    console.log("Notification sent successfully");
    return null;
  }
);