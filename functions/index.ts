import * as functions from "firebase-functions/v2";
import * as admin from "firebase-admin";

admin.initializeApp();

export const sendPushNotificationToArtisan = functions.firestore
  .onDocumentUpdated(
    {
      document: "devis/{devisId}",
      region: "europe-west1",
    },
    async (event) => {
      const change = event.data;
      const context = event;

      const after = change?.after.data();
      const before = change?.before.data();

      if (!after || !before) {
        console.warn("⚠️ Données manquantes dans le document");
        return;
      }

      if (!after.isSigned || after.isSigned === before.isSigned) {
        console.log("ℹ️ Aucun changement sur isSigned");
        return;
      }

      // 🔎 Récupération des infos dans after.client
      const nom = after.client?.nom || "Quelqu’un";
      const prenom = after.client?.prenom || "";

      // ✅ On récupère le vrai devisId (pas celui généré par Firestore)
      const devisId = after.devisId || context.params.devisId;

      // 🔥 Token FCM depuis config
      const tokenDoc = await admin.firestore().doc("config/fcmToken").get();
      const token = tokenDoc.data()?.token;

      if (!token) {
        console.warn("⚠️ Aucun token FCM trouvé");
        return;
      }

      const titles = [
        "Bonne nouvelle ✅",
        "Signature reçue ✍️",
        "Un pas de plus vers la mission 💼",
        "Le devis est validé 🎉",
      ];
      const title = titles[Math.floor(Math.random() * titles.length)];

      const message = {
        token,
        notification: {
          title,
          body: `${nom} ${prenom} a signé le ${devisId}`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          type: "notification",
          devisId: devisId,
          screen: "/screens/notificationScreen",
        },
      };

      try {
        await admin.messaging().send(message);
        console.log("✅ Notification envoyée avec succès");
      } catch (error) {
        console.error("❌ Erreur lors de l'envoi :", error);
      }
    }
  );
