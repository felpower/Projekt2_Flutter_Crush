import firebase_admin
from firebase_admin import messaging, credentials, db

cred = credentials.Certificate('credentials.json')


def load_database():
	cred = credentials.Certificate('credentials.json')
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
			tokens.append({last_token: dark_patterns})


def send_notification():
	for token in tokens:
		try:
			key, value = list(token.items())[0]
			if value > 0:
				message = messaging.Message(
					token=key,
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
				print(token)

				print('Successfully sent message:', response)
		except Exception as e:
			print('Failed to send message:', e)


def send_single_notification():
	token = "cs2QAWmYyfXc2kI0OJhhg6:APA91bHoDMlytVEyjnqjATnZMc89ElzqGPkJ5PDkbRfPJm3lFp8nsHrru2rH87kOykOAKqy2pl-pTNY2mZjFr-vqfbIIUOv68vYwUB1m_oPAvP8Q1Lsx9Ps8msYCbshHKQ-E6YwJ4qz0"
	try:
		message = messaging.Message(
			token=token,
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
		print(token)
		print('Successfully sent message:', response)
	except Exception as e:
		print('Failed to send message:', e)


send_notification()
# send_single_notification()
# standard token = cs2QAWmYyfXc2kI0OJhhg6:APA91bHoDMlytVEyjnqjATnZMc89ElzqGPkJ5PDkbRfPJm3lFp8nsHrru2rH87kOykOAKqy2pl-pTNY2mZjFr-vqfbIIUOv68vYwUB1m_oPAvP8Q1Lsx9Ps8msYCbshHKQ-E6YwJ4qz0
