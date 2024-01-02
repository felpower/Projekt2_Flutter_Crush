import firebase_admin
from firebase_admin import messaging, credentials

cred = credentials.Certificate('credentials.json')
firebase_admin.initialize_app(cred)


def send_notification():
	# Your message content
	message = messaging.Message(
		condition="'all' in topics",
		data={
			"title": "JellyFun",
			"body": "Hallo! Hast du heute schon gespielt?",
			"site": "https://felpower.github.io/",
			"click_action": "FLUTTER_NOTIFICATION_CLICK",
			"id": "1",
			"status": "done"
		}
	)

	# Send a message to the devices subscribed to the provided topic.
	response = messaging.send(message)
	print('Successfully sent message:', response)


send_notification()
