from datetime import datetime

import firebase_admin
from firebase_admin import messaging, credentials, db

cred = credentials.Certificate('credentials/credentials.json')


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


def extract_days_since_start(s):
	start_date = parse_date(next(iter(s.values())))
	das_since_start = (datetime.now() - start_date).days
	return das_since_start


def parse_date(date_string):
	for fmt in ('%Y-%m-%d %H:%M:%S.%f', '%Y-%m-%d %H:%M:%S'):
		try:
			return datetime.strptime(date_string, fmt)
		except ValueError:
			pass
	raise ValueError(f'No valid date format found for {date_string}')


database = load_database()


def extract_tokens(data_users):
	tokens = []
	for user_id, user_info in data_users.items():
		token_field = user_info.get('pushToken', None)
		init_app_start_time = user_info.get('initAppStartTime', None)
		days_since_start = 0
		if init_app_start_time:
			days_since_start = extract_days_since_start(init_app_start_time)
		played_till_end = user_info.get('endSurvey', None)
		survey_filled = True if played_till_end else False
		dark_patterns = int(user_info.get('darkPatterns', 0)) if user_info.get('darkPatterns') is not None else 1
		if token_field:
			last_token = extract_token(list(token_field.values())[-1])
			if last_token is not None:
				tokens.append({'user_id': user_id, 'token': last_token, 'dark_patterns': dark_patterns,
							   'days_since_start': days_since_start, 'survey_filled': survey_filled})
	return tokens


users_data = database['users']
user_tokens = extract_tokens(users_data)

flutter_data = database['flutter']
flutter_tokens = extract_tokens(flutter_data)



def send_message(key, message_body="Hallo! Hast du heute schon gespielt?"):
	message = messaging.Message(
		token=key,
		notification=messaging.Notification(
			title="JellyFun",
			body=message_body
		)
	)
	response = messaging.send(message)
	print(key)
	print('Successfully sent message:', response)


def send_notification(tokens):
	for token_info in tokens:
		try:
			if token_info['dark_patterns'] == 1 and not token_info.get('survey_filled', False):
				send_message(token_info['token'])
				update_database(token_info)
		except Exception as e:
			print('Failed to send message:', e)


def update_database(token_info):
	# Update the user's data in the database
	now = datetime.now()
	# Update the user's data in the database
	user_id_flutter = token_info['user_id']
	if user_id_flutter.startswith("flutter"):
		user_ref = db.reference('/flutter/' + user_id_flutter)
	else:
		user_ref = db.reference('/users/' + user_id_flutter)
	user_ref.child('notification_sent').push().set(str(now))


def send_single_notification(token=None):
	if token is None:
		token = "cs2QAWmYyfXc2kI0OJhhg6:APA91bHoDMlytVEyjnqjATnZMc89ElzqGPkJ5PDkbRfPJm3lFp8nsHrru2rH87kOykOAKqy2pl-pTNY2mZjFr-vqfbIIUOv68vYwUB1m_oPAvP8Q1Lsx9Ps8msYCbshHKQ-E6YwJ4qz0"
	try:
		send_message(token)
	except Exception as e:
		print('Failed to send message:', e)


def send_end_survey_reminder():
	for token_info in user_tokens + flutter_tokens:
		try:
			if token_info['days_since_start'] > 30 and not token_info.get('survey_filled', False):
				send_message(token_info['token'],
							 "Vielen Dank fürs Spielen, wir würden uns freuen, wenn du an unserer Umfrage teilnimmst!")
				update_database(token_info)
		except Exception as e:
			print('Failed to send message:', e)


send_notification(user_tokens)
# send_notification(flutter_tokens)
# send_end_survey_reminder()
# send_single_notification(
# 	"ej8Oq0LnM9UJRgjvKYtxm5:APA91bGH_hzQPOBn3psuHZ_BmQP61G-VSYH3Fvy5S6QhiARnNP_AIRg911nBSw9i3PRhI5IGpUNgGuYqI4HrX4gQef8QH0SfV3qgBC7KQdDUo-hzQMsrMIQ"
# )
# send_single_notification()
