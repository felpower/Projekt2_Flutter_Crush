# The Cloud Functions for Firebase SDK to set up triggers and logging.
from firebase_functions import scheduler_fn

# The Firebase Admin SDK to delete users.
import firebase_admin
from firebase_admin import auth, messaging, credentials

cred = credentials.Certificate('credentials.json')
firebase_admin.initialize_app(cred)


def send_notification():
	# Your message content
	message = messaging.Message(
		token="cs2QAWmYyfXc2kI0OJhhg6:APA91bHoDMlytVEyjnqjATnZMc89ElzqGPkJ5PDkbRfPJm3lFp8nsHrru2rH87kOykOAKqy2pl-pTNY2mZjFr-vqfbIIUOv68vYwUB1m_oPAvP8Q1Lsx9Ps8msYCbshHKQ-E6YwJ4qz0",
		data={
			"title": "Test",
			"body": "Test",
			"site": "https://flutter-crush-4ece9.web.app/",
			"click_action": "FLUTTER_NOTIFICATION_CLICK",
			"id": "1",
			"status": "done"

		}
	)

	# Send a message to the devices subscribed to the provided topic.
	response = messaging.send(message)
	print('Successfully sent message:', response)


send_notification()
