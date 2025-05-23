import json
import re
import traceback
from datetime import date, datetime, timedelta

import firebase_admin
import pandas as pd
from firebase_admin import credentials
from firebase_admin import db


def extract_date_time(timestamp_str):
	try:
		if timestamp_str.startswith("Time: "):
			timestamp_str = timestamp_str.split("Time: ")[-1].replace(" ", "-")
		timestamp = datetime.fromisoformat(timestamp_str)
		return timestamp.date(), timestamp.time()
	except ValueError:
		return None, None


PUSH_CHARS = "-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz"


def decode_push_id(push_id):
	push_id = push_id[:8]
	timestamp = 0
	for i in range(len(push_id)):
		c = push_id[i]
		timestamp = timestamp * 64 + PUSH_CHARS.index(c)
	return timestamp


def load_database(reference):
    cred = credentials.Certificate('credentials/credentials.json')
    firebase_admin.initialize_app(cred, {
        'databaseURL': 'https://darkpatterns-ac762-default-rtdb.europe-west1.firebasedatabase.app'
    })
    all_users = db.reference('/' + reference).get()
    v20_users = {user_id: user_info for user_id, user_info in all_users.items() if user_id.startswith("V20")}
    return v20_users


processed_data = []


def load_json_file(json_file_name):
	# Load the JSON file into a Python dictionary with the correct encoding
	with open(json_file_name + ".json", 'r') as json_file:  # or use 'latin-1', 'iso-8859-1', or 'cp1252'
		json_data = json.load(json_file)
		return json_data


use_database = True
# Access the 'users' data
use_flutter = False
user_data = {}


def save_users_data_as_file(file_name, data_from_users):
	with open(file_name + '.json', 'w') as save_file:
		json.dump(data_from_users, save_file)


if use_flutter:
	if use_database:
		users_data = load_database("flutter")
		save_users_data_as_file("flutter_file", users_data)
	else:
		users_data = load_json_file("flutter_file")
else:
	if use_database:
		users_data = load_database('users')
	else:
		users_data = load_json_file("ak_file")
	save_users_data_as_file("ak_file", users_data)
userCounter = 1
# Total number of users
total_users = len(users_data)
# Counter for inactive users starts from the total number of users
inactive_user_counter = total_users
inactive_users = set()
total_counter = 0
play_dates_by_type = {0: {}, 1: {}, 2: {}, 3: {}}
latest_endsurveydate = None
level_finished_after_push = 0

print("Starting to process User data for ", end="")
if use_flutter:
	print("Flutter stats")
else:
	print("AK stats")

for user_id, user_info in users_data.items():
	try:
		if user_id == 'V10-24-03-19–11:02-1JXsC7So1tiNEhp' or user_id == 'V10-24-04-08–19:51-c2dR2Ca7llLRvhe':
			continue
		if not use_flutter and not user_id.startswith("V20-"):
			continue
		dark_patterns_type = int(user_info.get('darkPatterns', 0)) if user_info.get('darkPatterns') is not None else ''
		row = {
			'userNumber': userCounter,
			'userId': user_id,
			'dropout': "",
			'daysSinceStart': "",
			'daysPlayed': "",
			'initAppStartTime': "",
			'initAppStartDate': "",
			'appStartTime': "",
			'appStartDate': "",
			'levelStart': "",
			'startOfLevelTime': "",
			'startOfLevelDate': "",
			'levelFinish': "",
			'finishOfLevelTime': "",
			'finishOfLevelDate': "",
			'levelWon': "",
			'timeNeededInSeconds': "",
			'levelBought': "",
			'levelBoughtTime': "",
			'levelBoughtDate': "",
			'itemBought': "",
			'itemBoughtTime': "",
			'itemBoughtDate': "",
			'collectDailyRewardsTime': "",
			'collectDailyRewardsDate': "",
			'checkHighscoreTime': "",
			'checkHighscoreDate': "",
			'pushClickTime': "",
			'pushClickDate': "",
			'notification_sent_time': "",
			'notification_sent_date': "",
			'appCloseTime': "",
			'appCloseDate': "",
			'session': "",
			'sessionCounter': "",
			'darkPatterns': dark_patterns_type,
			'age': "",
			'gender': "",
			'education': "",
			'occupation': "",
			'frequencyPlaying': "",
			'hoursPlaying': "",
			'moneySpent': "",
			'endSurvey': "",
			"endsurveydate": "",
			"endsurveytime": "",
			"playedtilend": "",
			"reasoncancel": "",
			"influenced": "",
			"influencedtime": "",
			"influencedfrequency": "",
			"patterninfluence": "",
			"pushreceived": "",
			"pushfrequency": "",
			"pushtimes": "",
			"pushbettertimes": "",
			"comments": "",
		}
		user_start_dates = set()

		# Processing 'startOfLevel'
		start_of_level = user_info.get('startOfLevel', None)
		start_times = {}
		if start_of_level:
			for levels in start_of_level.values():
				level, level_time = levels.split(', ')
				# If the level is already in the dictionary, append the new start time
				extracted_start_time = extract_date_time(level_time)
				user_start_dates.add(extracted_start_time[0])
				if level in start_times:
					start_times[level].append(extracted_start_time)
				# If the level is not in the dictionary, create a new list with the start time
				else:
					start_times[level] = [extracted_start_time]
		# if len(user_start_dates) >= 2:
		# 	row['dropout'] = 0
		# else:
		# 	row['dropout'] = 1
		# 	inactive_users.add(user_id)
		# 	inactive_user_counter -= 1
		# 	total_counter += 1
		# 	continue
		row['dropout'] = 0 #ToDo: remove if want to go back to normal
		processed_data.append(row.copy())
		row['dropout'] = ""

		# Extracting date and time from 'bootAppStartTime' if it exists
		init_start_time = user_info.get('initAppStartTime', None)
		days_since_start = 1
		if init_start_time:
			for date_time in init_start_time.values():
				start_date, start_time = extract_date_time(date_time)
				row['initAppStartDate'] = str(start_date)
				row['initAppStartTime'] = str(start_time)
				days_since_start = (date.today() - start_date).days
				processed_data.append(row.copy())

		row['initAppStartDate'] = ""
		row['initAppStartTime'] = ""
		session = 1
		actions = []

		# # Extracting date and time from 'appStartTime' if it exists
		app_start_date = user_info.get('appStartDate', None)
		if app_start_date:
			unique_dates = set(datetime.fromisoformat(date_time).date() for date_time in app_start_date.values())
			row['daysPlayed'] = len(unique_dates)
			row['daysSinceStart'] = days_since_start + 1
			processed_data.append(row.copy())
			row['daysPlayed'] = ""
			row['daysSinceStart'] = ""
			for date_time in app_start_date.values():
				start_date, start_time = extract_date_time(date_time)
				row['appStartDate'] = str(start_date)
				row['appStartTime'] = str(start_time)
				row['session'] = session
				session += 1
				actions.append({'action': 'appStart', 'date': str(start_date), 'time': str(start_time)})
				processed_data.append(row.copy())

		row['appStartDate'] = ""
		row['appStartTime'] = ""
		row['session'] = ""

		# Extracting date and time from 'bootAppStartTime' if it exists
		app_close_date = user_info.get('appCloseTime', None)
		if app_close_date:
			for date_time in app_close_date.values():
				start_date, start_time = extract_date_time(date_time)
				row['appCloseDate'] = str(start_date)
				row['appCloseTime'] = str(start_time)
				processed_data.append(row.copy())

		row['appCloseDate'] = ""
		row['appCloseTime'] = ""

		# Processing 'finishOfLevel'
		finish_of_level = user_info.get('finishOfLevel', None)
		if finish_of_level:
			for levels in finish_of_level.values():
				if levels.count(',') < 2:
					comma_index = levels.find(' Time:')
					levels = levels[:comma_index] + "," + levels[comma_index:]
				level, won, level_time = levels.split(', ')
				if level in start_times and start_times[level]:  # Check if start_times[level] is not empty
					# Convert 'finish_time' to datetime object
					finish_time = extract_date_time(level_time)[1]
					dummy_date = date.today()
					finish_datetime = datetime.combine(dummy_date, finish_time)

					# Find the closest start time
					closest_start_time = min(start_times[level],
											 key=lambda x: abs(datetime.combine(dummy_date, x[1]) - finish_datetime))
					# Calculate the time difference
					start_datetime = datetime.combine(dummy_date, closest_start_time[1])

					# If startOfLevelTime is not before finishOfLevelTime, skip to the next finishOfLevelTime
					if start_datetime > finish_datetime:
						continue

					time_difference = finish_datetime - start_datetime
					row['levelStart'] = int(''.join(filter(str.isdigit, level)))
					row['startOfLevelTime'] = str(closest_start_time[1])
					row['startOfLevelDate'] = str(closest_start_time[0])
					row['levelFinish'] = int(''.join(filter(str.isdigit, level)))
					row['levelWon'] = 1 if won.split(': ')[1].lower() == 'true' else 0

					row['finishOfLevelTime'] = str(finish_time)
					finish_date = extract_date_time(level_time)[0]
					if dark_patterns_type not in play_dates_by_type:
						play_dates_by_type[dark_patterns_type] = {}

					if user_id not in play_dates_by_type[dark_patterns_type]:
						play_dates_by_type[dark_patterns_type][user_id] = []
					play_dates_by_type[dark_patterns_type][user_id].append(finish_date)
					row['finishOfLevelDate'] = str(finish_date)
					# Assign the time difference to the 'timeNeededInSec' field in the row dictionary
					row['timeNeededInSeconds'] = time_difference.total_seconds()
					start_times[level].remove(closest_start_time)
					actions.append({'action': 'levelFinished', 'date': str(finish_date), 'time': str(finish_time)})
					processed_data.append(row.copy())
				else:
					# If there is no matching startOfLevel for a finishOfLevel, skip this iteration
					continue

		row['finishOfLevelTime'] = ""
		row['finishOfLevelDate'] = ""
		row['timeNeededInSec'] = ""
		row['levelWon'] = 0
		row['levelFinish'] = ""
		row['timeNeededInSeconds'] = ""
		# After processing 'finishOfLevel'

		for level, start_times in start_times.items():
			for start_time in start_times:
				if start_time is not None and len(start_time) >= 2:
					row['levelStart'] = int(''.join(filter(str.isdigit, level)))
					row['startOfLevelTime'] = str(start_time[1])
					row['startOfLevelDate'] = str(start_time[0])
					processed_data.append(row.copy())

		row['levelStart'] = ""
		row['startOfLevelTime'] = ""
		row['startOfLevelDate'] = ""
		row['levelWon'] = ""

		level_bought = user_info.get('levelBought', None)
		if level_bought:
			for levels_bought in level_bought.values():
				level, level_time = levels_bought.split(', ')
				extracted_date_time = extract_date_time(level_time)
				row['levelBought'] = int(''.join(filter(str.isdigit, level)))
				row['levelBoughtTime'] = str(extracted_date_time[1])
				row['levelBoughtDate'] = str(extracted_date_time[0])
				actions.append(
					{'action': 'levelBought', 'date': str(extracted_date_time[0]), 'time': str(extracted_date_time[1])})
				processed_data.append(row.copy())

		row['levelBought'] = ""
		row['levelBoughtTime'] = ""
		row['levelBoughtDate'] = ""

		item_bought = user_info.get('itemBought', None)
		if item_bought:
			for items_bought in item_bought.values():
				item, level_time = items_bought.split(', ')
				extracted_date_time = extract_date_time(level_time)
				row['itemBought'] = item
				row['itemBoughtTime'] = str(extracted_date_time[1])
				row['itemBoughtDate'] = str(extracted_date_time[0])
				actions.append(
					{'action': 'itemBought', 'date': str(extracted_date_time[0]), 'time': str(extracted_date_time[1])})
				processed_data.append(row.copy())

		row['itemBought'] = ""
		row['itemBoughtTime'] = ""
		row['itemBoughtDate'] = ""

		# Processing 'collectDailyReward'
		daily_rewards = user_info.get('collectDailyRewardsTime', None)
		if daily_rewards:
			for rewards_time in daily_rewards.values():
				extracted_date_time = extract_date_time(rewards_time)
				row['collectDailyRewardsTime'] = str(extracted_date_time[1])
				row['collectDailyRewardsDate'] = str(extracted_date_time[0])
				actions.append(
					{'action': 'dailyRewards', 'date': str(extracted_date_time[0]),
					 'time': str(extracted_date_time[1])})
				processed_data.append(row.copy())

		row['collectDailyRewardsTime'] = ""
		row['collectDailyRewardsDate'] = ""

		check_high_score = user_info.get('checkHighScoreTime', None)
		if check_high_score:
			for high_score_time in check_high_score.values():
				extracted_date_time = extract_date_time(high_score_time)
				row['checkHighscoreTime'] = str(extracted_date_time[1])
				row['checkHighscoreDate'] = str(extracted_date_time[0])
				actions.append(
					{'action': 'checkHighScore', 'date': str(extracted_date_time[0]),
					 'time': str(extracted_date_time[1])})
				processed_data.append(row.copy())

		row['checkHighscoreTime'] = ""
		row['checkHighscoreDate'] = ""

		push_click = user_info.get('pushClick', None)
		if push_click:
			for push_sent_time in push_click.values():
				extracted_date_time = extract_date_time(push_sent_time)
				row['pushClickTime'] = str(extracted_date_time[1])
				row['pushClickDate'] = str(extracted_date_time[0])
				actions.append({'action': 'pushClickTime', 'date': str(extracted_date_time[0]),
								'time': str(extracted_date_time[1])})
				processed_data.append(row.copy())

		row['pushClickTime'] = ""
		row['pushClickDate'] = ""

		push_time = user_info.get('notification_sent', None)
		if push_time:
			for push_sent_time in push_time.values():
				extracted_date_time = extract_date_time(push_sent_time)
				row['notification_sent_time'] = str(extracted_date_time[1])
				row['notification_sent_date'] = str(extracted_date_time[0])
				processed_data.append(row.copy())

		row['notification_sent_time'] = ""
		row['notification_sent_date'] = ""

		start_survey = user_info.get('startSurvey', None)
		if start_survey:
			for start_survey_result in start_survey.values():
				for question in start_survey_result.split('[')[1].split(']')[0].split(', '):
					try:
						x, answer = question.split('-')
						identifier = int(re.findall(r'\b\d{1,2}\b', x)[0])
						if identifier == 1:
							row['age'] = answer
						elif identifier == 2:
							row['gender'] = answer
						elif identifier == 3:
							row['education'] = answer
						elif identifier == 4:
							row['occupation'] = answer
						elif identifier == 6:
							row['frequencyPlaying'] = answer
						elif identifier == 7:
							row['hoursPlaying'] = answer
						elif identifier == 8:
							row['moneySpent'] = answer

					except ValueError:
						continue
				processed_data.append(row.copy())

		row['age'] = ""
		row['gender'] = ""
		row['education'] = ""
		row['occupation'] = ""
		row['frequencyPlaying'] = ""
		row['hoursPlaying'] = ""
		row['moneySpent'] = ""

		end_survey = user_info.get('endSurvey', None)
		if end_survey:
			end_survey_date = decode_push_id(list(end_survey.keys())[0])
			timestamp_datetime = datetime.fromtimestamp(end_survey_date / 1000)
			endsurveydate = str(timestamp_datetime.date())
			row['endsurveydate'] = endsurveydate
			row['endsurveytime'] = str(timestamp_datetime.time())
			if not latest_endsurveydate or endsurveydate > latest_endsurveydate:
				latest_endsurveydate = endsurveydate
			for end_survey_result in end_survey.values():
				for question in end_survey_result.split('[')[1].split(']')[0].split(', '):
					try:
						x, answer = question.split('-')
						identifier = int(re.findall(r'\b\d{1,2}\b', x)[0])
						if identifier == 1:
							row['playedtilend'] = answer
						elif identifier == 2:
							row['reasoncancel'] = answer
						elif identifier == 3:
							row['influenced'] = answer
						elif identifier == 5:
							row['influencedtime'] = answer
						elif identifier == 6:
							row['influencedfrequency'] = answer
						elif identifier == 7:
							row['patterninfluence'] = answer
						elif identifier == 8:
							row['pushreceived'] = answer
						elif identifier == 9:
							row['pushfrequency'] = answer
						elif identifier == 10:
							row['pushtimes'] = answer
						elif identifier == 11:
							row['pushbettertimes'] = answer
						elif identifier == 12:
							row['comments'] = answer
					except ValueError:
						continue
				processed_data.append(row.copy())

		row['playedtilend'] = ""
		row['reasoncancel'] = ""
		row['influenced'] = ""
		row['influencedtime'] = ""
		row['influencedfrequency'] = ""
		row['patterninfluence'] = ""
		row['pushreceived'] = ""
		row['pushfrequency'] = ""
		row['pushtimes'] = ""
		row['pushbettertimes'] = ""
		row['comments'] = ""
		row['endsurveydate'] = ""
		row['endsurveytime'] = ""

		# Check if the user has any activity other than just opening the app
		has_activity = any(
			key in user_info for key in
			['initAppStartTime', 'initAppStartDate', 'appStartDate''initAppStartTime', 'initAppStartDate',
			 'appStartTime',
			 'appStartDate', 'levelStart', 'startOfLevelTime', 'startOfLevelDate', 'levelFinish', 'finishOfLevelTime',
			 'finishOfLevelDate', 'levelWon', 'collectDailyRewardsTime', 'collectDailyRewardsDate',
			 'checkHighscoreTime',
			 'checkHighscoreDate', 'pushClickTime', 'pushClickDate', 'notification_sent_time', 'notification_sent_date',
			 'appCloseTime', 'appCloseDate', ])

		# Convert date and time strings to datetime objects and sort

		from datetime import datetime


		def parse_date(date_string):
			for fmt in ('%Y-%m-%d %H:%M:%S.%f', '%Y-%m-%d %H:%M:%S'):
				try:
					return datetime.strptime(date_string, fmt)
				except ValueError:
					pass
			raise ValueError(f'No valid date format found for {date_string}')


		sorted_actions = sorted(actions, key=lambda x: parse_date(x['date'] + ' ' + x['time']))

		session = 0
		session_counter = 0
		session_initiated = False
		push_session = -1
		session_already_counted = -1
		for action in sorted_actions:
			if action['action'] == 'pushClickTime':
				session_counter = 0
				session += 1
				push_session = session
				session_initiated = True
				# Update session and sessionCounter for pushClickTime related actions
				for dictionary in processed_data:
					if (dictionary.get('pushClickDate') == action['date'] and
							dictionary.get('pushClickTime') == action['time']):
						dictionary['session'] = session
						dictionary['sessionCounter'] = session_counter
						break
			if action['action'] == 'appStart':
				if not session_initiated:  # Check if session was not initiated by pushClickTime
					session_counter = 0
					session += 1
				else:
					session_counter += 1
				for dictionary in processed_data:
					if (dictionary.get('appStartDate') == action['date'] and
							dictionary.get('appStartTime') == action['time']):
						dictionary['session'] = session
						dictionary['sessionCounter'] = session_counter
						break
				session_initiated = False  # Reset for the next iteration
			if action['action'] == 'levelFinished':
				session_counter += 1
				if session == push_session and session != session_already_counted:
					session_already_counted = session
					level_finished_after_push += 1
				for dictionary in processed_data:
					if (dictionary.get('finishOfLevelDate') == action['date'] and
							dictionary.get('finishOfLevelTime') == action['time']):
						dictionary['session'] = session
						dictionary['sessionCounter'] = session_counter
						break
			if action['action'] == 'levelBought':
				session_counter += 1
				for dictionary in processed_data:
					if (dictionary.get('levelBoughtDate') == action['date'] and
							dictionary.get('levelBoughtTime') == action['time']):
						dictionary['session'] = session
						dictionary['sessionCounter'] = session_counter
						break
			if action['action'] == 'itemBought':
				session_counter += 1
				for dictionary in processed_data:
					if (dictionary.get('itemBoughtDate') == action['date'] and
							dictionary.get('itemBoughtTime') == action['time']):
						dictionary['session'] = session
						dictionary['sessionCounter'] = session_counter
						break
			if action['action'] == 'dailyRewards':
				session_counter += 1
				for dictionary in processed_data:
					if (dictionary.get('collectDailyRewardsDate') == action['date'] and
							dictionary.get('collectDailyRewardsTime') == action['time']):
						dictionary['session'] = session
						dictionary['sessionCounter'] = session_counter
						break
			if action['action'] == 'checkHighScore':
				session_counter += 1
				for dictionary in processed_data:
					if (dictionary.get('checkHighscoreDate') == action['date'] and
							dictionary.get('checkHighscoreTime') == action['time']):
						dictionary['session'] = session
						dictionary['sessionCounter'] = session_counter
						break
		# If the user has no other activity, add their data to the separate list and continue to the next user
		# if not has_activity:
			# inactive_users.add(user_id)
			# inactive_user_counter -= 1 ToDo: Remove this to work again
		# else:
		userCounter += 1
		processed_data.append({})
		total_counter += 1
		print(f"\rNumber of users processed: {total_counter}/{total_users}", end="")
	except Exception as e:
		print(f"Skipping user {user_id} due to error: {e}\nTraceback: {traceback.format_exc()}")
		continue

print("\nActive Users: ", userCounter)
dropout_counter = 0
dropout_age = 0
dropout_levels = 0
total_days_since_start = 0
total_days_played = 0
daily_players = 0
users_played_last_three_days = 0
users_played_any_of_last_three_days = 0
installed_yesterday = 0
total_app_starts = 0
total_time_needed = 0
level_counter = 0
started_levels = 0
finished_levels = 0
levels_won = 0
max_level = 0
levels_bought = 0
items_bought = 0
daily_rewards = 0
checked_highscore = 0
push_clicked = 0
notifications_sent = 0
notifications_sent_after_30_days = 0
user_dark_patterns = {}
dark_patterns_off = 0
dark_patterns_on = 0
dark_patterns_fomo = 0
dark_patterns_var = 0
average_age = 0
user_counter = 0
start_survey_done = 0
end_survey_counter = 0
played_till_end = 0
influenced = 0
influenced_time = 0
total_sessions = 0
average_level_per_session = 0
average_level_per_player = 0
push_after_30_days = 0

gender_counter = {'0': 0, '1': 0, '2': 0}
education_counter = {'0': 0, '1': 0, '2': 0, '3': 0, '4': 0}
occupation_counter = {'0': 0, '1': 0, '2': 0, '3': 0, '4': 0}
frequency_playing_counter = {'0': 0, '1': 0, '2': 0, '3': 0, '4': 0, '5': 0, '6': 0}
reason_cancel_counter = {'0': 0, '1': 0, '2': 0, '3': 0, '4': 0, '5': 0, '6': 0, '7': 0}
influenced_time_counter = {'0': 0, '1': 0, '2': 0}
influenced_frequency_counter = {'0': 0, '1': 0, '2': 0}
pattern_influence_counter = {'0': 0, '1': 0, '2': 0, '3': 0, '4': 0, '5': 0, '6': 0}
pushfrequency_counter = {'0': 0, '1': 0, '2': 0}
pushtimes_counter = {'0': 0, '1': 0, '2': 0}
total_hours_playing = 0
hours_playing_per_user = 0
end_survey_done = 0
session_counter = {}
comments = []
init_app_start_date = None

# Get the date 4 days ago
four_days_ago = datetime.now().date() - timedelta(days=4)

# Get the dates for the last 3 days starting from yesterday
last_three_dates = {four_days_ago + timedelta(days=i) for i in range(1, 4)}

yesterday = (datetime.now() - timedelta(days=1)).date()

# Initialize a dictionary to store the dates when each user played
user_play_dates = {}

# Initialize the dictionaries
dark_patterns_off_stats = {'Total Users': 0, 'Total Dropouts': 0, 'Active Users': 0, 'Total Levels Started': 0,
						   'Total Levels Finished': 0, 'Total Levels Won': 0, 'Average Playtime per level': 0,
						   'Hours of Playing': 0, 'Seconds per Session': 0, 'Total Levels Bought': 0,
						   'Total Items Bought': 0, 'Total Daily Rewards Collected': 0, 'Total Highscores Checked': 0,
						   'Average Age': 0, 'Max Level': 0, 'Users Max Level': 0, 'Longest Streak': 0,
						   'Total Notifications Sent': 0, 'Total Notifications Pushed': 0,
						   'Played After Notification Pushed': 0, 'Notifications sent after 30 days': 0,
						   'Notifications clicked after 30 days': 0}
dark_patterns_on_stats = {'Total Users': 0, 'Total Dropouts': 0, 'Active Users': 0, 'Total Levels Started': 0,
						  'Total Levels Finished': 0, 'Total Levels Won': 0, 'Average Playtime per level': 0,
						  'Hours of Playing': 0, 'Seconds per Session': 0, 'Total Levels Bought': 0,
						  'Total Items Bought': 0, 'Total Daily Rewards Collected': 0, 'Total Highscores Checked': 0,
						  'Average Age': 0, 'Max Level': 0, 'Users Max Level': 0, 'Longest Streak': 0,
						  'Total Notifications Sent': 0, 'Total Notifications Pushed': 0,
						  'Played After Notification Pushed': 0, 'Notifications sent after 30 days': 0,
						  'Notifications clicked after 30 days': 0}
dark_patterns_fomo_stats = {'Total Users': 0, 'Total Dropouts': 0, 'Active Users': 0, 'Total Levels Started': 0,
							'Total Levels Finished': 0, 'Total Levels Won': 0, 'Average Playtime per level': 0,
							'Hours of Playing': 0, 'Seconds per Session': 0, 'Total Levels Bought': 0,
							'Total Items Bought': 0, 'Total Daily Rewards Collected': 0, 'Total Highscores Checked': 0,
							'Average Age': 0, 'Max Level': 0, 'Users Max Level': 0, 'Longest Streak': 0,
							'Total Notifications Sent': 0, 'Total Notifications Pushed': 0,
							'Played After Notification Pushed': 0, 'Notifications sent after 30 days': 0,
							'Notifications clicked after 30 days': 0}
dark_patterns_var_stats = {'Total Users': 0, 'Total Dropouts': 0, 'Active Users': 0, 'Total Levels Started': 0,
						   'Total Levels Finished': 0, 'Total Levels Won': 0, 'Average Playtime per level': 0,
						   'Hours of Playing': 0, 'Seconds per Session': 0, 'Total Levels Bought': 0,
						   'Total Items Bought': 0, 'Total Daily Rewards Collected': 0, 'Total Highscores Checked': 0,
						   'Average Age': 0, 'Max Level': 0, 'Users Max Level': 0, 'Longest Streak': 0,
						   'Total Notifications Sent': 0, 'Total Notifications Pushed': 0,
						   'Played After Notification Pushed': 0, 'Notifications sent after 30 days': 0,
						   'Notifications clicked after 30 days': 0}
dark_patterns_off_stats.update({
	'gender': gender_counter.copy(),
	'education': education_counter.copy(),
	'occupation': occupation_counter.copy(),
	'frequencyPlaying': frequency_playing_counter.copy(),
	'hoursPlaying': total_hours_playing,
	'moneySpent': 0,
	'endSurveyCount': end_survey_done,
	'playedtilend': 0,
	'reasoncancel': reason_cancel_counter.copy(),
	'influenced': 0,
	'influencedtime': influenced_time_counter.copy(),
	'influencedfrequency': influenced_frequency_counter.copy(),
	'patterninfluence': pattern_influence_counter.copy(),
	'pushreceived': 0,
	'pushfrequency': pushfrequency_counter.copy(),
	'pushtimes': pushtimes_counter.copy(),
	'pushbettertimes': "",
	'comments': "",
	'totalAppStarts': total_app_starts,
	'Average Level Per Session': 0,
})

dark_patterns_on_stats.update({
	'gender': gender_counter.copy(),
	'education': education_counter.copy(),
	'occupation': occupation_counter.copy(),
	'frequencyPlaying': frequency_playing_counter.copy(),
	'hoursPlaying': total_hours_playing,
	'moneySpent': 0,
	'endSurveyCount': end_survey_done,
	'playedtilend': 0,
	'reasoncancel': reason_cancel_counter.copy(),
	'influenced': 0,
	'influencedtime': influenced_time_counter.copy(),
	'influencedfrequency': influenced_frequency_counter.copy(),
	'patterninfluence': pattern_influence_counter.copy(),
	'pushreceived': 0,
	'pushfrequency': pushfrequency_counter.copy(),
	'pushtimes': pushtimes_counter.copy(),
	'pushbettertimes': "",
	'comments': "",
	'totalAppStarts': total_app_starts,
	'Average Level Per Session': 0,
})

dark_patterns_fomo_stats.update({
	'gender': gender_counter.copy(),
	'education': education_counter.copy(),
	'occupation': occupation_counter.copy(),
	'frequencyPlaying': frequency_playing_counter.copy(),
	'hoursPlaying': total_hours_playing,
	'moneySpent': 0,
	'endSurveyCount': end_survey_done,
	'playedtilend': 0,
	'reasoncancel': reason_cancel_counter.copy(),
	'influenced': 0,
	'influencedtime': influenced_time_counter.copy(),
	'influencedfrequency': influenced_frequency_counter.copy(),
	'patterninfluence': pattern_influence_counter.copy(),
	'pushreceived': 0,
	'pushfrequency': pushfrequency_counter.copy(),
	'pushtimes': pushtimes_counter.copy(),
	'pushbettertimes': "",
	'comments': "",
	'totalAppStarts': total_app_starts,
	'Average Level Per Session': 0,
})

dark_patterns_var_stats.update({
	'gender': gender_counter.copy(),
	'education': education_counter.copy(),
	'occupation': occupation_counter.copy(),
	'frequencyPlaying': frequency_playing_counter.copy(),
	'hoursPlaying': total_hours_playing,
	'moneySpent': 0,
	'endSurveyCount': end_survey_done,
	'playedtilend': 0,
	'reasoncancel': reason_cancel_counter.copy(),
	'influenced': 0,
	'influencedtime': influenced_time_counter.copy(),
	'influencedfrequency': influenced_frequency_counter.copy(),
	'patterninfluence': pattern_influence_counter.copy(),
	'pushreceived': 0,
	'pushfrequency': pushfrequency_counter.copy(),
	'pushtimes': pushtimes_counter.copy(),
	'pushbettertimes': "",
	'comments': "",
	'totalAppStarts': total_app_starts,
	'Average Level Per Session': 0,
})
print("Finished processing User data")
print("Starting to process Dark Patterns data")
try:
	for data in processed_data:
		user_id = data.get('userId')
		dark_pattern_type = data.get('darkPatterns')
		if data.get('dropout') == 1:
			if user_id not in inactive_users:
				dropout_counter += 1
				if 'age' in data and data['age']:
					dropout_age += data.get('age')
				if 'levelStart' in data and data['levelStart']:
					dropout_levels += data.get('levelStart')
				if dark_pattern_type == 0:  # Off
					dark_patterns_off_stats['Total Dropouts'] += 1
				elif dark_pattern_type == 1:  # On
					dark_patterns_on_stats['Total Dropouts'] += 1
				elif dark_pattern_type == 2:  # FOMO
					dark_patterns_fomo_stats['Total Dropouts'] += 1
				elif dark_pattern_type == 3:  # VAR
					dark_patterns_var_stats['Total Dropouts'] += 1
			continue
		if 'daysSinceStart' in data and data['daysSinceStart']:
			total_days_since_start += int(data['daysSinceStart'])
			if data['daysSinceStart'] == data['daysPlayed']:
				daily_players += 1
		if 'initAppStartDate' in data and data['initAppStartDate']:
			# Convert the 'initAppStartDate' string to a date object
			init_app_start_date = datetime.strptime(data['initAppStartDate'], '%Y-%m-%d').date()
			# If the init_app_start_date is yesterday, increment the counter
			if init_app_start_date == yesterday:
				installed_yesterday += 1
		if 'daysPlayed' in data and data['daysPlayed']:
			total_days_played += int(data['daysPlayed'])
		if 'appStartDate' in data and data['appStartDate']:
			# Convert the 'appStartDate' string to a date object
			app_start_date = datetime.strptime(data['appStartDate'], '%Y-%m-%d').date()
			# If the user_id is not in the dictionary, add it
			if user_id not in user_play_dates:
				user_play_dates[user_id] = set()
			# Add the app_start_date to the user's set of play dates
			user_play_dates[user_id].add(app_start_date)
		if 'appStartTime' in data and data['appStartTime']:
			total_app_starts += 1
		if 'timeNeededInSeconds' in data and data['timeNeededInSeconds']:
			total_time_needed += int(data['timeNeededInSeconds'])
			level_counter += 1
		if 'levelStart' in data and data['levelStart']:
			started_levels += 1
		if 'levelFinish' in data and data['levelFinish']:
			finished_levels += 1
			max_level_us = int(data['levelFinish'])
			if max_level_us == 501:
				max_level += 1
		if 'levelWon' in data and data['levelWon'] == 1:
			levels_won += 1
		if 'levelBought' in data and data['levelBought']:
			levels_bought += 1
		if 'itemBought' in data and data['itemBought']:
			items_bought += 1
		if 'collectDailyRewardsTime' in data and data['collectDailyRewardsTime']:
			daily_rewards += 1
		if 'checkHighscoreTime' in data and data['checkHighscoreTime']:
			checked_highscore += 1
		if 'pushClickDate' in data and data['pushClickDate']:
			push_click_date = datetime.strptime(data['pushClickDate'], '%Y-%m-%d').date()
			if init_app_start_date:
				date_difference = (push_click_date - init_app_start_date).days
			else:
				date_difference = None  # Or handle it appropriately
			if date_difference and date_difference <= 30:
				push_clicked += 1
			else:
				push_after_30_days += 1
		if 'notification_sent_date' in data and data['notification_sent_date']:
			notification_sent_date = datetime.strptime(data['notification_sent_date'], '%Y-%m-%d').date()
			if init_app_start_date:
				date_difference = (push_click_date - init_app_start_date).days
			else:
				date_difference = None  # Or handle it appropriately
			if date_difference and date_difference <= 30:
				notifications_sent += 1
			else:
				notifications_sent_after_30_days += 1
		user_id = data.get('userId')
		if 'gender' in data and data['gender']:
			gender_counter[data['gender']] += 1
		if 'education' in data and data['education']:
			education_counter[data['education']] += 1
		if 'occupation' in data and data['occupation']:
			occupation_counter[data['occupation']] += 1
		if 'frequencyPlaying' in data and data['frequencyPlaying']:
			frequency_playing_counter[data['frequencyPlaying']] += 1
		if 'hoursPlaying' in data and data['hoursPlaying']:
			total_hours_playing += float(data['hoursPlaying'])
		if 'endSurvey' in data and data['endSurvey']:
			end_survey_done += 1
		if 'age' in data and data['age']:
			user_age = int(data['age'])
			average_age += user_age
			# if user_age == 33 or user_age == 41:
			# 	print("User_id: " + user_id + ", Dark Pattern Type: " + str(dark_pattern_type))
			start_survey_done += 1
			user_id = data.get('userId')
			if user_id and 'darkPatterns' in data:
				# If the user is not in the dictionary, add them
				if user_id not in user_dark_patterns:
					user_counter += 1
					user_dark_patterns[user_id] = data['darkPatterns']
					# Increment the appropriate counter
					if data['darkPatterns'] == 0:
						dark_patterns_off += 1
					elif data['darkPatterns'] == 1:
						dark_patterns_on += 1
					elif data['darkPatterns'] == 2:
						dark_patterns_fomo += 1
					elif data['darkPatterns'] == 3:
						dark_patterns_var += 1
		if dark_pattern_type == 0:  # Off
			if 'gender' in data and data['gender']:
				dark_patterns_off_stats['gender'][data['gender']] += 1
			if 'education' in data and data['education']:
				dark_patterns_off_stats['education'][data['education']] += 1
			if 'occupation' in data and data['occupation']:
				dark_patterns_off_stats['occupation'][data['occupation']] = dark_patterns_off_stats['occupation'].get(
					data['occupation'], 0) + 1
			if 'frequencyPlaying' in data and data['frequencyPlaying']:
				dark_patterns_off_stats['frequencyPlaying'][data['frequencyPlaying']] += 1
			if 'hoursPlaying' in data and data['hoursPlaying']:
				dark_patterns_off_stats['hoursPlaying'] += float(data['hoursPlaying'])
			if 'moneySpent' in data and data['moneySpent']:
				dark_patterns_off_stats['moneySpent'] += float(data['moneySpent'])
			if 'endsurveydate' in data and data['endsurveydate']:
				dark_patterns_off_stats['endSurveyCount'] += 1
			if 'playedtilend' in data and data['playedtilend'] == '1':
				dark_patterns_off_stats['playedtilend'] += 1
			if 'reasoncancel' in data and data['reasoncancel']:
				reasons = data['reasoncancel'].split(',')
				for reason in reasons:
					dark_patterns_off_stats['reasoncancel'][reason] = dark_patterns_off_stats['reasoncancel'].get(
						reason, 0) + 1
			if 'influenced' in data and data['influenced'] == '1':
				dark_patterns_off_stats['influenced'] += 1
			if 'influencedtime' in data and data['influencedtime']:
				dark_patterns_off_stats['influencedtime'][data['influencedtime']] = dark_patterns_off_stats[
																						'influencedtime'].get(
					data['influencedtime'], 0) + 1
			if 'influencedfrequency' in data and data['influencedfrequency']:
				dark_patterns_off_stats['influencedfrequency'][data['influencedfrequency']] = dark_patterns_off_stats[
																								  'influencedfrequency'].get(
					data['influencedfrequency'], 0) + 1
			if 'patterninfluence' in data and data['patterninfluence']:
				patterns = data['patterninfluence'].split(',')
				for pattern in patterns:
					dark_patterns_off_stats['patterninfluence'][pattern] = dark_patterns_off_stats[
																			   'patterninfluence'].get(
						pattern, 0) + 1
			if 'pushreceived' in data and data['pushreceived'] == '1':
				dark_patterns_off_stats['pushreceived'] += 1
			if 'pushfrequency' in data and data['pushfrequency']:
				dark_patterns_off_stats['pushfrequency'][data['pushfrequency']] = dark_patterns_off_stats[
																					  'pushfrequency'].get(
					data['pushfrequency'], 0) + 1
			if 'pushtimes' in data and data['pushtimes']:
				dark_patterns_off_stats['pushtimes'][data['pushtimes']] = dark_patterns_off_stats[
																			  'pushtimes'].get(
					data['pushtimes'], 0) + 1
			if 'pushbettertimes' in data and data['pushbettertimes']:
				dark_patterns_off_stats['pushbettertimes'] += data['pushbettertimes'] + ", "
			if 'comments' in data and data['comments']:
				dark_patterns_off_stats['comments'] += data['comments'] + ", "
			if 'appStartTime' in data and data['appStartTime']:
				dark_patterns_off_stats['totalAppStarts'] += 1
		if dark_pattern_type == 1:  # On
			if 'gender' in data and data['gender']:
				dark_patterns_on_stats['gender'][data['gender']] += 1
			if 'education' in data and data['education']:
				dark_patterns_on_stats['education'][data['education']] += 1
			if 'occupation' in data and data['occupation']:
				dark_patterns_on_stats['occupation'][data['occupation']] = dark_patterns_on_stats['occupation'].get(
					data['occupation'], 0) + 1
			if 'frequencyPlaying' in data and data['frequencyPlaying']:
				dark_patterns_on_stats['frequencyPlaying'][data['frequencyPlaying']] = dark_patterns_on_stats[
																						   'frequencyPlaying'].get(
					data['frequencyPlaying'], 0) + 1
			if 'hoursPlaying' in data and data['hoursPlaying']:
				dark_patterns_on_stats['hoursPlaying'] += float(data['hoursPlaying'])
			if 'moneySpent' in data and data['moneySpent']:
				dark_patterns_on_stats['moneySpent'] += float(data['moneySpent'])
			if 'endsurveydate' in data and data['endsurveydate']:
				dark_patterns_on_stats['endSurveyCount'] += 1
			if 'playedtilend' in data and data['playedtilend'] == '1':
				dark_patterns_on_stats['playedtilend'] += 1
			if 'reasoncancel' in data and data['reasoncancel']:
				reasons = data['reasoncancel'].split(',')
				for reason in reasons:
					dark_patterns_on_stats['reasoncancel'][reason] = dark_patterns_on_stats['reasoncancel'].get(
						reason, 0) + 1
			if 'influenced' in data and data['influenced'] == '1':
				dark_patterns_on_stats['influenced'] += 1
			if 'influencedtime' in data and data['influencedtime']:
				dark_patterns_on_stats['influencedtime'][data['influencedtime']] = dark_patterns_on_stats[
																					   'influencedtime'].get(
					data['influencedtime'], 0) + 1
			if 'influencedfrequency' in data and data['influencedfrequency']:
				dark_patterns_on_stats['influencedfrequency'][data['influencedfrequency']] = dark_patterns_on_stats[
																								 'influencedfrequency'].get(
					data['influencedfrequency'], 0) + 1
			if 'patterninfluence' in data and data['patterninfluence']:
				patterns = data['patterninfluence'].split(',')
				for pattern in patterns:
					dark_patterns_on_stats['patterninfluence'][pattern] = dark_patterns_on_stats[
																			  'patterninfluence'].get(
						pattern, 0) + 1
			if 'pushreceived' in data and data['pushreceived'] == '1':
				dark_patterns_on_stats['pushreceived'] += 1
			if 'pushfrequency' in data and data['pushfrequency']:
				dark_patterns_on_stats['pushfrequency'][data['pushfrequency']] = dark_patterns_on_stats[
																					 'pushfrequency'].get(
					data['pushfrequency'], 0) + 1
			if 'pushtimes' in data and data['pushtimes']:
				dark_patterns_on_stats['pushtimes'][data['pushtimes']] = dark_patterns_on_stats[
																			 'pushtimes'].get(
					data['pushtimes'], 0) + 1
			if 'pushbettertimes' in data and data['pushbettertimes']:
				dark_patterns_on_stats['pushbettertimes'] += data['pushbettertimes'] + ", "
			if 'comments' in data and data['comments']:
				dark_patterns_on_stats['comments'] += data['comments'] + ", "
			if 'appStartTime' in data and data['appStartTime']:
				dark_patterns_on_stats['totalAppStarts'] += 1
		if dark_pattern_type == 2:  # Fomo
			if 'gender' in data and data['gender']:
				dark_patterns_fomo_stats['gender'][data['gender']] += 1
			if 'education' in data and data['education']:
				dark_patterns_fomo_stats['education'][data['education']] += 1
			if 'occupation' in data and data['occupation']:
				dark_patterns_fomo_stats['occupation'][data['occupation']] = dark_patterns_fomo_stats['occupation'].get(
					data['occupation'], 0) + 1
			if 'frequencyPlaying' in data and data['frequencyPlaying']:
				dark_patterns_fomo_stats['frequencyPlaying'][data['frequencyPlaying']] += 1
			if 'hoursPlaying' in data and data['hoursPlaying']:
				dark_patterns_fomo_stats['hoursPlaying'] += float(data['hoursPlaying'])
			if 'moneySpent' in data and data['moneySpent']:
				dark_patterns_fomo_stats['moneySpent'] += float(data['moneySpent'])
			if 'endsurveydate' in data and data['endsurveydate']:
				dark_patterns_fomo_stats['endSurveyCount'] += 1
			if 'playedtilend' in data and data['playedtilend'] == '1':
				dark_patterns_fomo_stats['playedtilend'] += 1
			if 'reasoncancel' in data and data['reasoncancel']:
				reasons = data['reasoncancel'].split(',')
				for reason in reasons:
					dark_patterns_fomo_stats['reasoncancel'][reason] = dark_patterns_fomo_stats['reasoncancel'].get(
						reason, 0) + 1
			if 'influenced' in data and data['influenced'] == '1':
				dark_patterns_fomo_stats['influenced'] += 1
			if 'influencedtime' in data and data['influencedtime']:
				dark_patterns_fomo_stats['influencedtime'][data['influencedtime']] = dark_patterns_fomo_stats[
																						 'influencedtime'].get(
					data['influencedtime'], 0) + 1
			if 'influencedfrequency' in data and data['influencedfrequency']:
				dark_patterns_fomo_stats['influencedfrequency'][data['influencedfrequency']] = dark_patterns_fomo_stats[
																								   'influencedfrequency'].get(
					data['influencedfrequency'], 0) + 1
			if 'patterninfluence' in data and data['patterninfluence']:
				patterns = data['patterninfluence'].split(',')
				for pattern in patterns:
					dark_patterns_fomo_stats['patterninfluence'][pattern] = dark_patterns_fomo_stats[
																				'patterninfluence'].get(
						pattern, 0) + 1
			if 'pushreceived' in data and data['pushreceived'] == '1':
				dark_patterns_fomo_stats['pushreceived'] += 1
			if 'pushfrequency' in data and data['pushfrequency']:
				dark_patterns_fomo_stats['pushfrequency'][data['pushfrequency']] = dark_patterns_fomo_stats[
																					   'pushfrequency'].get(
					data['pushfrequency'], 0) + 1
			if 'pushtimes' in data and data['pushtimes']:
				dark_patterns_fomo_stats['pushtimes'][data['pushtimes']] = dark_patterns_fomo_stats[
																			   'pushtimes'].get(
					data['pushtimes'], 0) + 1
			if 'pushbettertimes' in data and data['pushbettertimes']:
				dark_patterns_fomo_stats['pushbettertimes'] += data['pushbettertimes'] + ", "
			if 'comments' in data and data['comments']:
				dark_patterns_fomo_stats['comments'] += data['comments'] + ", "
			if 'appStartTime' in data and data['appStartTime']:
				dark_patterns_fomo_stats['totalAppStarts'] += 1
		if dark_pattern_type == 3:  # Var
			if 'gender' in data and data['gender']:
				dark_patterns_var_stats['gender'][data['gender']] += 1
			if 'education' in data and data['education']:
				dark_patterns_var_stats['education'][data['education']] += 1
			if 'occupation' in data and data['occupation']:
				dark_patterns_var_stats['occupation'][data['occupation']] = dark_patterns_var_stats['occupation'].get(
					data['occupation'], 0) + 1
			if 'frequencyPlaying' in data and data['frequencyPlaying']:
				dark_patterns_var_stats['frequencyPlaying'][data['frequencyPlaying']] += 1
			if 'hoursPlaying' in data and data['hoursPlaying']:
				dark_patterns_var_stats['hoursPlaying'] += float(data['hoursPlaying'])
			if 'moneySpent' in data and data['moneySpent']:
				dark_patterns_var_stats['moneySpent'] += float(data['moneySpent'])
			if 'endsurveydate' in data and data['endsurveydate']:
				dark_patterns_var_stats['endSurveyCount'] += 1
			if 'playedtilend' in data and data['playedtilend'] == '1':
				dark_patterns_var_stats['playedtilend'] += 1
			if 'reasoncancel' in data and data['reasoncancel']:
				reasons = data['reasoncancel'].split(',')
				for reason in reasons:
					dark_patterns_var_stats['reasoncancel'][reason] = dark_patterns_var_stats['reasoncancel'].get(
						reason, 0) + 1
			if 'influenced' in data and data['influenced'] == '1':
				dark_patterns_var_stats['influenced'] += 1
			if 'influencedtime' in data and data['influencedtime']:
				dark_patterns_var_stats['influencedtime'][data['influencedtime']] = dark_patterns_var_stats[
																						'influencedtime'].get(
					data['influencedtime'], 0) + 1
			if 'influencedfrequency' in data and data['influencedfrequency']:
				dark_patterns_var_stats['influencedfrequency'][data['influencedfrequency']] = dark_patterns_var_stats[
																								  'influencedfrequency'].get(
					data['influencedfrequency'], 0) + 1
			if 'patterninfluence' in data and data['patterninfluence']:
				patterns = data['patterninfluence'].split(',')
				for pattern in patterns:
					dark_patterns_var_stats['patterninfluence'][pattern] = dark_patterns_var_stats[
																			   'patterninfluence'].get(
						pattern, 0) + 1
			if 'pushreceived' in data and data['pushreceived'] == '1':
				dark_patterns_var_stats['pushreceived'] += 1
			if 'pushfrequency' in data and data['pushfrequency']:
				dark_patterns_var_stats['pushfrequency'][data['pushfrequency']] = dark_patterns_var_stats[
																					  'pushfrequency'].get(
					data['pushfrequency'], 0) + 1
			if 'pushtimes' in data and data['pushtimes']:
				dark_patterns_var_stats['pushtimes'][data['pushtimes']] = dark_patterns_var_stats[
																			  'pushtimes'].get(
					data['pushtimes'], 0) + 1
			if 'pushbettertimes' in data and data['pushbettertimes']:
				dark_patterns_var_stats['pushbettertimes'] += data['pushbettertimes'] + ", "
			if 'comments' in data and data['comments']:
				dark_patterns_var_stats['comments'] += data['comments'] + ", "
			if 'appStartTime' in data and data['appStartTime']:
				dark_patterns_var_stats['totalAppStarts'] += 1
		if 'playedtilend' in data and data['playedtilend']:
			end_survey_counter += 1
			if data['playedtilend'] == '1':
				played_till_end += 1
		if 'influenced' in data and data['influenced']:
			if data['influenced'] == '1':
				influenced += 1
		if 'influencedtime' in data and data['influencedtime']:
			if data['influencedtime'] == '1':
				influenced_time += 1
		if 'comments' in data and data['comments']:
			comments.append({
				'userId': user_id,
				'comments': data['comments'],
				'darkPatterns': dark_pattern_type
			})
		# Increment the corresponding values based on the DarkPattern type
		if dark_pattern_type == 0:  # Off
			if data.get('levelStart'):
				dark_patterns_off_stats['Total Levels Started'] += 1
			if data.get('levelFinish'):
				if user_id not in session_counter:
					session_counter[user_id] = {'total_levelFinished': 0, 'total_sessions': set(),
												'dark_pattern': dark_pattern_type}
				session_counter[user_id]['total_levelFinished'] += 1
				session_counter[user_id]['total_sessions'].add(data.get('session'))
				dark_patterns_off_stats['Total Levels Finished'] += 1
			if data.get('levelWon'):
				dark_patterns_off_stats['Total Levels Won'] += 1
			if data.get('timeNeededInSeconds'):
				dark_patterns_off_stats['Hours of Playing'] += int(data['timeNeededInSeconds'])
			if data.get('levelBought'):
				dark_patterns_off_stats['Total Levels Bought'] += 1
			if data.get('itemBought'):
				dark_patterns_off_stats['Total Items Bought'] += 1
			if data.get('collectDailyRewardsTime'):
				dark_patterns_off_stats['Total Daily Rewards Collected'] += 1
			if data.get('checkHighscoreTime'):
				dark_patterns_off_stats['Total Highscores Checked'] += 1
			if data.get('age'):
				dark_patterns_off_stats['Average Age'] += int(data.get('age'))
			if data.get('levelFinish'):
				max_level_finish = int(data.get('levelFinish'))
				dark_patterns_off_stats['Max Level'] = max(dark_patterns_off_stats['Max Level'],
														   max_level_finish)
				if max_level_finish == 501:
					dark_patterns_off_stats['Users Max Level'] += 1
			if data.get('notification_sent_date'):
				notification_sent_date = datetime.strptime(data['notification_sent_date'], '%Y-%m-%d').date()
				date_difference = (notification_sent_date - init_app_start_date).days
				if date_difference <= 30:
					dark_patterns_off_stats['Total Notifications Sent'] += 1
				else:
					dark_patterns_off_stats['Notifications sent after 30 days'] += 1
			if data.get('pushClickDate'):
				push_click_date = datetime.strptime(data['pushClickDate'], '%Y-%m-%d').date()
				if init_app_start_date:
					date_difference = (push_click_date - init_app_start_date).days
				else:
					date_difference = None  # Or handle it appropriately
				if date_difference <= 30:
					dark_patterns_off_stats['Total Notifications Pushed'] += 1
				else:
					dark_patterns_off_stats['Notifications clicked after 30 days'] += 1
		elif dark_pattern_type == 1:  # On
			if data.get('levelStart'):
				dark_patterns_on_stats['Total Levels Started'] += 1
			if data.get('levelFinish'):
				if user_id not in session_counter:
					session_counter[user_id] = {'total_levelFinished': 0, 'total_sessions': set(),
												'dark_pattern': dark_pattern_type}
				session_counter[user_id]['total_levelFinished'] += 1
				session_counter[user_id]['total_sessions'].add(data.get('session'))
				dark_patterns_on_stats['Total Levels Finished'] += 1
			if data.get('levelWon'):
				dark_patterns_on_stats['Total Levels Won'] += 1
			if data.get('timeNeededInSeconds'):
				dark_patterns_on_stats['Hours of Playing'] += int(data['timeNeededInSeconds'])
			if data.get('levelBought'):
				dark_patterns_on_stats['Total Levels Bought'] += 1
			if data.get('itemBought'):
				dark_patterns_on_stats['Total Items Bought'] += 1
			if data.get('collectDailyRewardsTime'):
				dark_patterns_on_stats['Total Daily Rewards Collected'] += 1
			if data.get('checkHighscoreTime'):
				dark_patterns_on_stats['Total Highscores Checked'] += 1
			if data.get('age'):
				dark_patterns_on_stats['Average Age'] += int(data.get('age'))
			if data.get('levelFinish'):
				max_level_finish = int(data.get('levelFinish'))
				dark_patterns_on_stats['Max Level'] = max(dark_patterns_on_stats['Max Level'],
														  max_level_finish)
				if max_level_finish == 501:
					dark_patterns_on_stats['Users Max Level'] += 1
			if data.get('notification_sent_date'):
				notification_sent_date = datetime.strptime(data['notification_sent_date'], '%Y-%m-%d').date()
				if init_app_start_date:
					date_difference = (push_click_date - init_app_start_date).days
				else:
					date_difference = None  # Or handle it appropriately
				if date_difference and date_difference <= 30:
					dark_patterns_on_stats['Total Notifications Sent'] += 1
				else:
					dark_patterns_on_stats['Notifications sent after 30 days'] += 1
			if data.get('pushClickDate'):
				push_click_date = datetime.strptime(data['pushClickDate'], '%Y-%m-%d').date()
				if init_app_start_date:
					date_difference = (push_click_date - init_app_start_date).days
				else:
					date_difference = None  # Or handle it appropriately
				if date_difference and date_difference <= 30:
					dark_patterns_on_stats['Total Notifications Pushed'] += 1
				else:
					dark_patterns_on_stats['Notifications clicked after 30 days'] += 1
		elif dark_pattern_type == 2:  # FOMO
			if data.get('levelStart'):
				dark_patterns_fomo_stats['Total Levels Started'] += 1
			if data.get('levelFinish'):
				if user_id not in session_counter:
					session_counter[user_id] = {'total_levelFinished': 0, 'total_sessions': set(),
												'dark_pattern': dark_pattern_type}
				session_counter[user_id]['total_levelFinished'] += 1
				session_counter[user_id]['total_sessions'].add(data.get('session'))
				dark_patterns_fomo_stats['Total Levels Finished'] += 1
			if data.get('levelWon'):
				dark_patterns_fomo_stats['Total Levels Won'] += 1
			if data.get('timeNeededInSeconds'):
				dark_patterns_fomo_stats['Hours of Playing'] += int(data['timeNeededInSeconds'])
			if data.get('levelBought'):
				dark_patterns_fomo_stats['Total Levels Bought'] += 1
			if data.get('itemBought'):
				dark_patterns_fomo_stats['Total Items Bought'] += 1
			if data.get('collectDailyRewardsTime'):
				dark_patterns_fomo_stats['Total Daily Rewards Collected'] += 1
			if data.get('checkHighscoreTime'):
				dark_patterns_fomo_stats['Total Highscores Checked'] += 1
			if data.get('age'):
				dark_patterns_fomo_stats['Average Age'] += int(data.get('age'))
			if data.get('levelFinish'):
				max_level_finish = int(data.get('levelFinish'))
				dark_patterns_fomo_stats['Max Level'] = max(dark_patterns_fomo_stats['Max Level'],
															max_level_finish)
				if max_level_finish == 501:
					dark_patterns_fomo_stats['Users Max Level'] += 1
			if data.get('notification_sent_date'):
				notification_sent_date = datetime.strptime(data['notification_sent_date'], '%Y-%m-%d').date()
				date_difference = (notification_sent_date - init_app_start_date).days
				if date_difference <= 30:
					dark_patterns_fomo_stats['Total Notifications Sent'] += 1
				else:
					dark_patterns_fomo_stats['Notifications sent after 30 days'] += 1
			if data.get('pushClickDate'):
				push_click_date = datetime.strptime(data['pushClickDate'], '%Y-%m-%d').date()
				date_difference = (push_click_date - init_app_start_date).days
				if date_difference <= 30:
					dark_patterns_fomo_stats['Total Notifications Pushed'] += 1
				else:
					dark_patterns_fomo_stats['Notifications clicked after 30 days'] += 1
		elif dark_pattern_type == 3:  # VAR
			if data.get('levelStart'):
				dark_patterns_var_stats['Total Levels Started'] += 1
			if data.get('levelFinish'):
				if user_id not in session_counter:
					session_counter[user_id] = {'total_levelFinished': 0, 'total_sessions': set(),
												'dark_pattern': dark_pattern_type}
				session_counter[user_id]['total_levelFinished'] += 1
				session_counter[user_id]['total_sessions'].add(data.get('session'))
				dark_patterns_var_stats['Total Levels Finished'] += 1
			if data.get('levelWon'):
				dark_patterns_var_stats['Total Levels Won'] += 1
			if data.get('timeNeededInSeconds'):
				dark_patterns_var_stats['Hours of Playing'] += int(data['timeNeededInSeconds'])
			if data.get('levelBought'):
				dark_patterns_var_stats['Total Levels Bought'] += 1
			if data.get('itemBought'):
				dark_patterns_var_stats['Total Items Bought'] += 1
			if data.get('collectDailyRewardsTime'):
				dark_patterns_var_stats['Total Daily Rewards Collected'] += 1
			if data.get('checkHighscoreTime'):
				dark_patterns_var_stats['Total Highscores Checked'] += 1
			if data.get('age'):
				dark_patterns_var_stats['Average Age'] += int(data.get('age'))
			if data.get('levelFinish'):
				max_level_finish = int(data.get('levelFinish'))
				dark_patterns_var_stats['Max Level'] = max(dark_patterns_var_stats['Max Level'],
														   max_level_finish)
				if max_level_finish == 501:
					dark_patterns_var_stats['Users Max Level'] += 1
			if data.get('notification_sent_date'):
				notification_sent_date = datetime.strptime(data['notification_sent_date'], '%Y-%m-%d').date()
				date_difference = (notification_sent_date - init_app_start_date).days
				if date_difference <= 30:
					dark_patterns_var_stats['Total Notifications Sent'] += 1
				else:
					dark_patterns_var_stats['Notifications sent after 30 days'] += 1
			if data.get('pushClickDate'):
				push_click_date = datetime.strptime(data['pushClickDate'], '%Y-%m-%d').date()
				date_difference = (push_click_date - init_app_start_date).days
				if date_difference <= 30:
					dark_patterns_var_stats['Total Notifications Pushed'] += 1
				else:
					dark_patterns_var_stats['Notifications clicked after 30 days'] += 1
except Exception as e:
	print(f"Error: {e}")
	traceback.print_exc()
average_time_needed_per_level = 0
longest_streaks = {0: 0, 1: 0, 2: 0, 3: 0}
for dark_pattern_type, play_dates in play_dates_by_type.items():
	for dates in play_dates.values():
		# Sort the dates
		dates.sort()

		# Find the longest streak of consecutive dates
		longest_streak = 0
		current_streak = 1
		for i in range(1, len(dates)):
			if dates[i] == dates[i - 1] + timedelta(days=1):
				current_streak += 1
			else:
				longest_streak = max(longest_streak, current_streak)
				current_streak = 1
		longest_streak = max(longest_streak, current_streak)

		if dark_pattern_type in longest_streaks:
			longest_streaks[dark_pattern_type] = max(longest_streaks[dark_pattern_type], longest_streak)
		else:
			longest_streaks[dark_pattern_type] = longest_streak  # Initialize if key doesn't exist
try:
	dark_patterns_off_stats['Total Users'] = dark_patterns_off
	dark_patterns_on_stats['Total Users'] = dark_patterns_on
	dark_patterns_fomo_stats['Total Users'] = dark_patterns_fomo
	dark_patterns_var_stats['Total Users'] = dark_patterns_var

	dark_patterns_off_stats['Active Users'] = dark_patterns_off - dark_patterns_off_stats['Total Dropouts']
	dark_patterns_on_stats['Active Users'] = dark_patterns_on - dark_patterns_on_stats['Total Dropouts']
	dark_patterns_fomo_stats['Active Users'] = dark_patterns_fomo - dark_patterns_fomo_stats['Total Dropouts']
	dark_patterns_var_stats['Active Users'] = dark_patterns_var - dark_patterns_var_stats['Total Dropouts']

	dark_patterns_off = dark_patterns_off_stats['Active Users']
	dark_patterns_on = dark_patterns_on_stats['Active Users']
	dark_patterns_fomo = dark_patterns_fomo_stats['Active Users']
	dark_patterns_var = dark_patterns_var_stats['Active Users']

	dark_patterns_off_stats['Average Playtime per level'] = round(
		dark_patterns_off_stats['Hours of Playing'] / dark_patterns_off_stats['Total Levels Started'] if
		dark_patterns_off_stats['Total Levels Started'] != 0 else 0, 2)
	dark_patterns_on_stats['Average Playtime per level'] = round(
		dark_patterns_on_stats['Hours of Playing'] / dark_patterns_on_stats['Total Levels Started'] if
		dark_patterns_on_stats['Total Levels Started'] != 0 else 0, 2)
	dark_patterns_fomo_stats['Average Playtime per level'] = round(
		dark_patterns_fomo_stats['Hours of Playing'] / dark_patterns_fomo_stats['Total Levels Started'] if
		dark_patterns_fomo_stats['Total Levels Started'] != 0 else 0, 2)
	dark_patterns_var_stats['Average Playtime per level'] = round(
		dark_patterns_var_stats['Hours of Playing'] / dark_patterns_var_stats['Total Levels Started'] if
		dark_patterns_var_stats['Total Levels Started'] != 0 else 0, 2)

	total_sessions_per_dark_pattern = {}
	# Iterate over the session_counter dictionary
	for user_id, user_info in session_counter.items():
		# Get the dark pattern type and the number of sessions for the user
		dark_pattern_type = user_info['dark_pattern']
		num_sessions = len(user_info['total_sessions'])
		# Add the number of sessions to the corresponding entry in the total_sessions_per_dark_pattern dictionary
		if dark_pattern_type in total_sessions_per_dark_pattern:
			total_sessions_per_dark_pattern[dark_pattern_type] += num_sessions
		else:
			total_sessions_per_dark_pattern[dark_pattern_type] = num_sessions

	dark_patterns_off_stats['Seconds per Session'] = round(
		dark_patterns_off_stats['Hours of Playing'] / total_sessions_per_dark_pattern.get(0, 0) if
		total_sessions_per_dark_pattern.get(0, 0) != 0 else 0, 2)
	dark_patterns_on_stats['Seconds per Session'] = round(
		dark_patterns_on_stats['Hours of Playing'] / total_sessions_per_dark_pattern.get(1, 0) if
		total_sessions_per_dark_pattern.get(1, 0) != 0 else 0, 2)
	dark_patterns_fomo_stats['Seconds per Session'] = round(
		dark_patterns_fomo_stats['Hours of Playing'] / total_sessions_per_dark_pattern.get(2, 0) if
		total_sessions_per_dark_pattern.get(2, 0) != 0 else 0, 2)
	dark_patterns_var_stats['Seconds per Session'] = round(
		dark_patterns_var_stats['Hours of Playing'] / total_sessions_per_dark_pattern.get(3, 0) if
		total_sessions_per_dark_pattern.get(3, 0) != 0 else 0, 2)

	dark_patterns_off_stats['Hours of Playing'] = round(dark_patterns_off_stats['Hours of Playing'] / 3600, 2)
	dark_patterns_on_stats['Hours of Playing'] = round(dark_patterns_on_stats['Hours of Playing'] / 3600, 2)
	dark_patterns_fomo_stats['Hours of Playing'] = round(dark_patterns_fomo_stats['Hours of Playing'] / 3600, 2)
	dark_patterns_var_stats['Hours of Playing'] = round(dark_patterns_var_stats['Hours of Playing'] / 3600, 2)

	hours_playing_per_user = dark_patterns_off_stats['Hours of Playing'] + dark_patterns_on_stats['Hours of Playing'] + \
							 dark_patterns_fomo_stats['Hours of Playing'] + dark_patterns_var_stats['Hours of Playing']
	dark_patterns_off_stats['Average Age'] = round(
		dark_patterns_off_stats['Average Age'] / dark_patterns_off if dark_patterns_off != 0 else 0, 2)
	dark_patterns_on_stats['Average Age'] = round(
		dark_patterns_on_stats['Average Age'] / dark_patterns_on if dark_patterns_on != 0 else 0, 2)
	dark_patterns_fomo_stats['Average Age'] = round(
		dark_patterns_fomo_stats['Average Age'] / dark_patterns_fomo if dark_patterns_fomo != 0 else 0, 2)
	dark_patterns_var_stats['Average Age'] = round(
		dark_patterns_var_stats['Average Age'] / dark_patterns_var if dark_patterns_var != 0 else 0, 2)

	dark_patterns_off_stats['Average Levels'] = round(
		dark_patterns_off_stats['Total Levels Started'] / dark_patterns_off_stats['Active Users'] if
		dark_patterns_off_stats['Active Users'] != 0 else 0, 2)
	dark_patterns_on_stats['Average Levels'] = round(
		dark_patterns_on_stats['Total Levels Started'] / dark_patterns_on_stats['Active Users'] if
		dark_patterns_on_stats['Active Users'] != 0 else 0, 2)
	dark_patterns_fomo_stats['Average Levels'] = round(
		dark_patterns_fomo_stats['Total Levels Started'] / dark_patterns_fomo_stats['Active Users'] if
		dark_patterns_fomo_stats['Active Users'] != 0 else 0, 2)
	dark_patterns_var_stats['Average Levels'] = round(
		dark_patterns_var_stats['Total Levels Started'] / dark_patterns_var_stats['Active Users'] if
		dark_patterns_var_stats['Active Users'] != 0 else 0, 2)

	dark_patterns_off_stats['Longest Streak'] = longest_streaks[0]
	dark_patterns_on_stats['Longest Streak'] = longest_streaks[1]
	dark_patterns_fomo_stats['Longest Streak'] = longest_streaks[2]
	dark_patterns_var_stats['Longest Streak'] = longest_streaks[3]

	dark_patterns_off_stats['hoursPlaying'] = round(
		dark_patterns_off_stats['hoursPlaying'] / dark_patterns_off if dark_patterns_off != 0 else 0, 2)
	dark_patterns_on_stats['hoursPlaying'] = round(
		dark_patterns_on_stats['hoursPlaying'] / dark_patterns_on if dark_patterns_on != 0 else 0, 2)
	dark_patterns_fomo_stats['hoursPlaying'] = round(
		dark_patterns_fomo_stats['hoursPlaying'] / dark_patterns_fomo if dark_patterns_fomo != 0 else 0, 2)
	dark_patterns_var_stats['hoursPlaying'] = round(
		dark_patterns_var_stats['hoursPlaying'] / dark_patterns_var if dark_patterns_var != 0 else 0, 2)

	dark_patterns_off_stats['moneySpent'] = round(
		dark_patterns_off_stats['moneySpent'] / dark_patterns_off if dark_patterns_off != 0 else 0, 2)
	dark_patterns_on_stats['moneySpent'] = round(
		dark_patterns_on_stats['moneySpent'] / dark_patterns_on if dark_patterns_on != 0 else 0, 2)
	dark_patterns_fomo_stats['moneySpent'] = round(
		dark_patterns_fomo_stats['moneySpent'] / dark_patterns_fomo if dark_patterns_fomo != 0 else 0, 2)
	dark_patterns_var_stats['moneySpent'] = round(
		dark_patterns_var_stats['moneySpent'] / dark_patterns_var if dark_patterns_var != 0 else 0, 2)

	for user in session_counter.values():
		if user['dark_pattern'] == 0:
			dark_patterns_off_stats['Average Level Per Session'] += user['total_levelFinished'] / len(
				user['total_sessions'])
		elif user['dark_pattern'] == 1:
			dark_patterns_on_stats['Average Level Per Session'] += user['total_levelFinished'] / len(
				user['total_sessions'])
		elif user['dark_pattern'] == 2:
			dark_patterns_fomo_stats['Average Level Per Session'] += user['total_levelFinished'] / len(
				user['total_sessions'])
		elif user['dark_pattern'] == 3:
			dark_patterns_var_stats['Average Level Per Session'] += user['total_levelFinished'] / len(
				user['total_sessions'])

	dark_patterns_off_stats['Average Level Per Session'] = round(
		dark_patterns_off_stats['Average Level Per Session'] / dark_patterns_off_stats['Active Users'] if
		dark_patterns_off_stats['Active Users'] != 0 else 0, 2)
	dark_patterns_on_stats['Average Level Per Session'] = round(
		dark_patterns_on_stats['Average Level Per Session'] / dark_patterns_on_stats['Active Users'] if
		dark_patterns_on_stats['Active Users'] != 0 else 0, 2)
	dark_patterns_fomo_stats['Average Level Per Session'] = round(
		dark_patterns_fomo_stats['Average Level Per Session'] / dark_patterns_fomo_stats['Active Users'] if
		dark_patterns_fomo_stats['Active Users'] != 0 else 0, 2)
	dark_patterns_var_stats['Average Level Per Session'] = round(
		dark_patterns_var_stats['Average Level Per Session'] / dark_patterns_var_stats['Active Users'] if
		dark_patterns_var_stats['Active Users'] != 0 else 0, 2)

	dark_patterns_on_stats['Played After Notification Pushed'] = level_finished_after_push

	total_sessions = dark_patterns_off_stats['Average Level Per Session'] + dark_patterns_on_stats[
		'Average Level Per Session'] + dark_patterns_fomo_stats['Average Level Per Session'] + dark_patterns_var_stats[
						 'Average Level Per Session']

	if dark_patterns_var_stats['Average Level Per Session'] == 0:
		average_level_per_session = (total_sessions / 2)
	else:
		average_level_per_session = (total_sessions / 4)

	for play_dates in user_play_dates.values():
		if last_three_dates.issubset(play_dates):
			users_played_last_three_days += 1
		if any(date in play_dates for date in last_three_dates):
			users_played_any_of_last_three_days += 1
	average_time_needed_per_level = total_time_needed / level_counter if level_counter > 0 else 0
	average_level_per_player = finished_levels / userCounter if userCounter > 0 else 0
except Exception as e:
	print(f"Error: {e}")
	traceback.print_exc()

statistics_overview = {
	'userNumber': 'Statistics',
	'dropout': 'Users dropped out',
	'userId': 'Inactive Users',
	'daysSinceStart': "Days Since Start Total",
	'daysPlayed': "Days Played Total",
	'initAppStartTime': 'Users that played daily',
	'initAppStartDate': 'Played all last 3 days',
	'startOfLevelTime': "Average Level per Session",
	'startOfLevelDate': "Average Level per Player",
	'appStartTime': "Played any of last 3 days",
	'appStartDate': "Total App Starts",
	'timeNeededInSeconds': "Average Playtime per level",
	'levelStart': "Total Levels Started",
	'levelFinish': "Total Levels Finished",
	'levelWon': "Total Levels Won",
	'finishOfLevelTime': "Max Level Users",
	'finishOfLevelDate': "Total Users",
	'levelBought': "Total Levels Bought",
	'levelBoughtTime': "Hours of Playing",
	'itemBought': 'Total Items Bought',
	'collectDailyRewardsTime': 'Total Daily Rewards Collected',
	'collectDailyRewardsDate': 'Total Highscores Checked',
	'checkHighscoreTime': 'Played After Notification Pushed',
	'checkHighscoreDate': 'Total Push Notifications Clicked after 30 days',
	'pushClickTime': 'Total Push Notifications Clicked',
	'pushClickDate': 'Total Notifications Sent after 30 days',
	'notification_sent_time': 'Total Notifications Sent',
	'notification_sent_date': 'End Survey Done',
	'appCloseTime': 'Start Survey Done',
	'appCloseDate': 'DarkPatterns Off',
	'session': 'DarkPatterns On',
	'sessionCounter': 'DarkPatterns FOMO',
	'darkPatterns': 'DarkPatterns VAR',
	'age': 'Average Age',
	'gender': 'Gender',
	'education': 'Education',
	'occupation': 'Occupation',
	'frequencyPlaying': 'Frequency of Playing',
	'hoursPlaying': 'hoursPlaying/user',
	'endSurvey': 'Played till end',
	'endsurveytime': 'Realised DPs',
	'endsurveydate': 'Last EndSurvey Done',
}
if user_counter == 0:
	user_counter = 1
statistics = {
	'userNumber': datetime.now(),
	'dropout': dropout_counter,
	'userId': total_users - inactive_user_counter,
	'daysSinceStart': total_days_since_start,
	'daysPlayed': total_days_played,
	'initAppStartTime': daily_players,
	'initAppStartDate': users_played_last_three_days,
	'startOfLevelTime': average_level_per_session,
	'startOfLevelDate': average_level_per_player,
	'appStartTime': users_played_any_of_last_three_days,
	'appStartDate': total_app_starts,
	'timeNeededInSeconds': round(average_time_needed_per_level, 2),
	'levelStart': started_levels,
	'levelFinish': finished_levels,
	'levelWon': levels_won,
	'finishOfLevelTime': max_level,
	'finishOfLevelDate': dark_patterns_on + dark_patterns_off + dark_patterns_fomo + dark_patterns_var,
	'levelBought': levels_bought,
	'levelBoughtTime': hours_playing_per_user,
	'itemBought': items_bought,
	'collectDailyRewardsTime': daily_rewards,
	'collectDailyRewardsDate': checked_highscore,
	'checkHighscoreTime': level_finished_after_push,
	'checkHighscoreDate': push_after_30_days,
	'pushClickTime': push_clicked,
	'pushClickDate': notifications_sent_after_30_days,
	'notification_sent_time': notifications_sent,
	'notification_sent_date': end_survey_counter,
	'appCloseTime': start_survey_done,
	'appCloseDate': dark_patterns_off,
	'session': dark_patterns_on,
	'sessionCounter': dark_patterns_fomo,
	'darkPatterns': dark_patterns_var,
	'age': round(average_age / user_counter, 2),
	'gender': gender_counter,
	'education': education_counter,
	'occupation': occupation_counter,
	'frequencyPlaying': frequency_playing_counter,
	'hoursPlaying': round(total_hours_playing / user_counter, 2),
	'endSurvey': played_till_end,
	'endsurveytime': influenced,
	'endsurveydate': latest_endsurveydate,
}

print("Finished processing Dark Patterns Data")

if use_flutter:
	processed_data.append(statistics)
	processed_data.append({})
	processed_data.append({})
combined_statistics = dict(zip(statistics_overview.values(), statistics.values()))
print("\n")
for key, value in combined_statistics.items():
	print(f"{key}: {value}")

# Print the results
# print("Dropout Age:", dropout_age / dropout_counter)
print("DarkPatterns Off:", dark_patterns_off_stats)
print("DarkPatterns On:", dark_patterns_on_stats)
if not use_flutter:
	print("DarkPatterns FOMO:", dark_patterns_fomo_stats)
	print("DarkPatterns VAR:", dark_patterns_var_stats)

# Determine the filename based on the value of use_flutter
filename = 'statistics_flutter.txt' if use_flutter else 'statistics_ak.txt'

# Open the file in write mode ('w')
with open(filename, 'w') as file:
	# Write the combined statistics to the file
	file.write("Combined Statistics:\n")
	for key, value in combined_statistics.items():
		file.write(f"{key}: {value}\n")
	file.write("\n")
	# Write the dark_patterns statistics to the file
	file.write("DarkPatterns Off:\n")
	for key, value in dark_patterns_off_stats.items():
		file.write(f"{key}: {value}\n")
	file.write("\n")
	file.write("DarkPatterns On:\n")
	for key, value in dark_patterns_on_stats.items():
		file.write(f"{key}: {value}\n")
	file.write("\n")
	file.write("DarkPatterns FOMO:\n")
	for key, value in dark_patterns_fomo_stats.items():
		file.write(f"{key}: {value}\n")
	file.write("\n")
	file.write("DarkPatterns VAR:\n")
	for key, value in dark_patterns_var_stats.items():
		file.write(f"{key}: {value}\n")
printing = False
if printing:
	for comment in comments:
		print(comment)
# Converting the processed data into a DataFrame
print("\nConverting the processed data into a DataFrame... Please wait")
processed_df = pd.DataFrame(processed_data)
processed_df.head()
if use_flutter:
	excel_file_path = 'flutter_data.xlsx'
else:
	excel_file_path = 'dark_patterns_data.xlsx'
print(
	"\nSaving the DataFrame as an Excel file... Please wait and make sure the excel file stays closed until creation is completed")
# Save the DataFrame as an Excel file
processed_df.to_excel(excel_file_path, index=False, freeze_panes=(1, 1))
print("Excel creation completed.")
