from datetime import datetime

import firebase_admin
from firebase_admin import messaging, credentials, db

cred = credentials.Certificate('credentials.json')


def load_database():
	firebase_admin.initialize_app(cred, {
		'databaseURL': 'https://darkpatterns-ac762-default-rtdb.europe-west1.firebasedatabase.app'
	})
	ref = db.reference('/')
	data = ref.get()
	return data


def extract_token(s):
	extracted_token = None
	if s.startswith("Token: "):
		start = s.find("Token: ") + len("Token: ")
		end = s.find(", Time:")
		extracted_token = s[start:end]
	return extracted_token


users_data = load_database()['users']
tokens = []
for user_id, user_info in users_data.items():
	token_field = user_info.get('pushToken', None)
	dark_patterns = int(user_info.get('darkPatterns', 0)) if user_info.get('darkPatterns') is not None else 0
	if token_field:
		last_token = extract_token(list(token_field.values())[-1])
		if last_token is not None:
			tokens.append({'user_id': user_id, 'token': last_token, 'dark_patterns': dark_patterns})


def send_message(key):
	message = messaging.Message(
		token=key,
		notification=messaging.Notification(
			title="JellyFun",
			body="Das ist eine TestNotification, in den nächsten Tagen kann es vermehrt zu Test Notifications kommen."
		)
	)
	response = messaging.send(message)
	print(key)
	print('Successfully sent message:', response)


def send_notification():
	for token_info in tokens:
		try:
			if token_info['dark_patterns'] > 0:
				send_message(token_info['token'])
				update_database(token_info)
		except Exception as e:
			print('Failed to send message:', e)


def update_database(token_info):
	# Update the user's data in the database
	now = datetime.now()
	# Update the user's data in the database
	user_ref = db.reference('/users/' + token_info['user_id'])
	user_ref.child('notification_sent').push().set(str(now))


def send_single_notification(token=None):
	if token is None:
		token = "cs2QAWmYyfXc2kI0OJhhg6:APA91bHoDMlytVEyjnqjATnZMc89ElzqGPkJ5PDkbRfPJm3lFp8nsHrru2rH87kOykOAKqy2pl-pTNY2mZjFr-vqfbIIUOv68vYwUB1m_oPAvP8Q1Lsx9Ps8msYCbshHKQ-E6YwJ4qz0"
	try:
		send_message(token)
	except Exception as e:
		print('Failed to send message:', e)


send_notification()
# send_single_notification(
# 	"fdo8TDj8H-5_lMvSSYU-cN:APA91bHwSwsrYUxwN-39rqvh3E3IvW0UKNdT3v9vDK765DQtOZqy0apvxMntKHRSGKx3t6oP2KIvilhdHu41QIYBm-RSf1nyGX-vWbBIWm05J8TCkeClSa5JjqDErSIwZZPSd1W7yKP9"
# )
# send_single_notification()
