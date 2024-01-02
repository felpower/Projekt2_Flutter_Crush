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
	if token_field:
		last_token = extract_token(list(token_field.values())[-1])
		if last_token is not None:
			tokens.append(last_token)

tokens = set(tokens)


def send_notification():
	for token in tokens:
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
