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

users_data = database['users']
user_tokens = []
for user_id, user_info in users_data.items():
	token_field = user_info.get('pushToken', None)
	init_app_start_time = user_info.get('initAppStartTime', None)
	days_since_start = 0
	if init_app_start_time:
		days_since_start = extract_days_since_start(init_app_start_time)
	played_till_end = user_info.get('playedtilend', None)
	survey_filled = True if played_till_end else False
	dark_patterns = int(user_info.get('darkPatterns', 0)) if user_info.get('darkPatterns') is not None else 0
	if token_field:
		last_token = extract_token(list(token_field.values())[-1])
		if last_token is not None:
			user_tokens.append({'user_id': user_id, 'token': last_token, 'dark_patterns': dark_patterns,
								'days_since_start': days_since_start, 'survey_filled': survey_filled})

flutter_data = database['flutter']
flutter_tokens = []
for user_id, user_info in flutter_data.items():
	token_field = user_info.get('pushToken', None)
	init_app_start_time = user_info.get('initAppStartTime', None)
	days_since_start = 0
	if init_app_start_time:
		days_since_start = extract_days_since_start(init_app_start_time)
	played_till_end = user_info.get('playedtilend', None)
	survey_filled = True if played_till_end else False
	dark_patterns = int(user_info.get('darkPatterns', 0)) if user_info.get('darkPatterns') is not None else 0
	if token_field:
		last_token = extract_token(list(token_field.values())[-1])
		if last_token is not None:
			flutter_tokens.append({'user_id': user_id, 'token': last_token, 'dark_patterns': dark_patterns,
								   'days_since_start': days_since_start, 'survey_filled': survey_filled})


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


def send_notification():
	for token_info in user_tokens:
		try:
			if token_info['dark_patterns'] > 0 and not token_info.get('survey_filled', False):
				send_message(token_info['token'])
				update_database(token_info)
		except Exception as e:
			print('Failed to send message:', e)


def send_flutter_notification():
	for token_info in flutter_tokens:
		try:
			if token_info['dark_patterns'] > 0 and not token_info.get('survey_filled', False):
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
		# print("Sent End Survey Reminder to user: " + token_info['user_id'] + ", who has played for " + str(
		# 	token_info['days_since_start']) + " days")
		except Exception as e:
			print('Failed to send message:', e)


send_notification()
send_flutter_notification()
send_end_survey_reminder()
# send_single_notification(
# 	"eVC8w1RUNGtGS5qTfEjAb2:APA91bGa661Vyk_sKc0CDs07iA8uaRWN7iXxd7H0_ydJnquO1x8JkuwvBOdyI-6DPeJRfA9WwVRIXsHuhZFwT5ttKxawUePTHM6zHnGv-LBQ3bS6fGabrOGG26PD0I5lMFgEo3v7D5Ex"
# )
# send_single_notification()
