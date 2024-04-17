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


def load_database(reference):
	cred = credentials.Certificate('credentials.json')
	firebase_admin.initialize_app(cred, {
		'databaseURL': 'https://darkpatterns-ac762-default-rtdb.europe-west1.firebasedatabase.app'
	})
	return db.reference('/' + reference).get()


processed_data = []


def load_json_file():
	# Path to your JSON file
	json_file_path = 'darkpatterns-ac762-default-rtdb-export.json'
	# Load the JSON file into a Python dictionary with the correct encoding
	with open(json_file_path, 'r', encoding='utf-8') as file:  # or use 'latin-1', 'iso-8859-1', or 'cp1252'
		json_data = json.load(file)
		return json_data


use_database = True
# Access the 'users' data
use_flutter = False
user_data = {}
if use_flutter:
	users_data = load_database("flutter")
else:
	if use_database:
		users_data = load_database('users')
	else:
		users_data = load_json_file()['users']
userCounter = 1
# Total number of users
total_users = len(users_data)
# Counter for inactive users starts from the total number of users
inactive_user_counter = total_users
total_counter = 0
for user_id, user_info in users_data.items():
	try:
		row = {
			'userNumber': userCounter,
			'userId': user_id,
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
			'darkPatterns': int(user_info.get('darkPatterns', 0)) if user_info.get('darkPatterns') is not None else '',
			'age': "",
			'gender': "",
			'education': "",
			'occupation': "",
			'residence': "",
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

		# Processing 'startOfLevel'
		start_of_level = user_info.get('startOfLevel', None)
		start_times = {}
		if start_of_level:
			for levels in start_of_level.values():
				level, time = levels.split(', ')
				# If the level is already in the dictionary, append the new start time
				if level in start_times:
					start_times[level].append(extract_date_time(time))
				# If the level is not in the dictionary, create a new list with the start time
				else:
					start_times[level] = [extract_date_time(time)]

		# Processing 'finishOfLevel'
		finish_of_level = user_info.get('finishOfLevel', None)
		if finish_of_level:
			for levels in finish_of_level.values():
				if levels.count(',') < 2:
					comma_index = levels.find(' Time:')
					levels = levels[:comma_index] + "," + levels[comma_index:]
				level, won, time = levels.split(', ')
				if level in start_times and start_times[level]:  # Check if start_times[level] is not empty
					# Convert 'finish_time' to datetime object
					finish_time = extract_date_time(time)[1]
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
					finish_date = extract_date_time(time)[0]
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
				level, time = levels_bought.split(', ')
				extracted_date_time = extract_date_time(time)
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
				item, time = items_bought.split(', ')
				extracted_date_time = extract_date_time(time)
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
						elif identifier == 5:
							row['residence'] = answer
						elif identifier == 7:
							row['frequencyPlaying'] = answer
						elif identifier == 8:
							row['hoursPlaying'] = answer
						elif identifier == 9:
							row['moneySpent'] = answer

					except ValueError:
						continue
				processed_data.append(row.copy())

		row['age'] = ""
		row['gender'] = ""
		row['education'] = ""
		row['occupation'] = ""
		row['residence'] = ""
		row['frequencyPlaying'] = ""
		row['hoursPlaying'] = ""
		row['moneySpent'] = ""

		end_survey = user_info.get('endSurvey', None)
		if end_survey:
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
		for action in sorted_actions:
			if action['action'] == 'appStart':
				session_counter = 0
				session += 1
				for dictionary in processed_data:
					if (dictionary.get('appStartDate') == action['date'] and
							dictionary.get('appStartTime') == action['time']):
						dictionary['session'] = session
						dictionary['sessionCounter'] = session_counter
						break
			if action['action'] == 'levelFinished':
				session_counter += 1
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
		if not has_activity:
			inactive_user_counter -= 1
		else:
			userCounter += 1
			processed_data.append({})
		total_counter += 1
		print(f"\rNumber of users processed: {total_counter}/{total_users}", end="")
	except Exception as e:
		print(f"Skipping user {user_id} due to error: {e}\nTraceback: {traceback.format_exc()}")
		continue

total_days_since_start = 0
total_days_played = 0
daily_players = 0
users_played_last_three_days = 0
users_played_any_of_last_three_days = 0
installed_yesterday = 0
total_app_starts = 0
total_time_needed = 0
count = 0
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

# Get the date 4 days ago
four_days_ago = datetime.now().date() - timedelta(days=4)

# Get the dates for the last 3 days starting from yesterday
last_three_dates = {four_days_ago + timedelta(days=i) for i in range(1, 4)}

yesterday = (datetime.now() - timedelta(days=1)).date()

# Initialize a dictionary to store the dates when each user played
user_play_dates = {}
for data in processed_data:
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
		# Get the user_id
		user_id = data.get('userId')
		# If the user_id is not in the dictionary, add it
		if user_id not in user_play_dates:
			user_play_dates[user_id] = set()
		# Add the app_start_date to the user's set of play dates
		user_play_dates[user_id].add(app_start_date)
	if 'appStartTime' in data and data['appStartTime']:
		total_app_starts += 1
	if 'timeNeededInSeconds' in data and data['timeNeededInSeconds']:
		if data['timeNeededInSeconds'] <= 300:
			total_time_needed += int(data['timeNeededInSeconds'])
			count += 1
	if 'levelStart' in data and data['levelStart']:
		started_levels += 1
	if 'levelFinish' in data and data['levelFinish']:
		finished_levels += 1
		if int(data['levelFinish']) > max_level:
			max_level = int(data['levelFinish'])
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
	if 'pushClickTime' in data and data['pushClickTime']:
		push_clicked += 1
	if 'notification_sent_time' in data and data['notification_sent_time']:
		notifications_sent += 1
	user_id = data.get('userId')
	if 'age' in data and data['age']:
		average_age += int(data['age'])
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

# Check if each user played each of the last 3 days
for play_dates in user_play_dates.values():
	if last_three_dates.issubset(play_dates):
		users_played_last_three_days += 1
	if any(date in play_dates for date in last_three_dates):
		users_played_any_of_last_three_days += 1
average_time_needed = total_time_needed / count if count > 0 else 0

statistics_overview = {
	'userNumber': 'Statistics',
	'userId': 'Inactive Users',
	'daysSinceStart': "Days Since Start Total",
	'daysPlayed': "Days Played Total",
	'initAppStartTime': 'Users that played daily',
	'initAppStartDate': 'Played all last 3 days',
	'startOfLevelTime': "Installed yesterday",
	'appStartTime': "Played any of last 3 days",
	'appStartDate': "Total App Starts",
	'timeNeededInSeconds': "Average Playtime per level",
	'levelStart': "Total Levels Started",
	'levelFinish': "Total Levels Finished",
	'levelWon': "Total Levels Won",
	'finishOfLevelTime': "Max Level",
	'levelBought': "Total Levels Bought",
	'itemBought': 'Total Items Bought',
	'collectDailyRewardsTime': 'Total Daily Rewards Collected',
	'checkHighscoreTime': 'Total Highscores Checked',
	'pushClickTime': 'Total Push Notifications Clicked',
	'notification_sent_time': 'Total Notifications Sent',
	'appCloseDate': 'DarkPatterns Off',
	'session': 'DarkPatterns On',
	'sessionCounter': 'DarkPatterns FOMO',
	'darkPatterns': 'DarkPatterns VAR',
	'age': 'Average Age',
	'gender': 'Start Survey Done',
	'education': 'End Survey Done',
	'endSurvey': 'Played till end',
	'endsurveydate': 'Realised DPs',
}

if use_flutter:
	processed_data.append(statistics_overview)

statistics = {
	'userNumber': datetime.now(),
	'userId': total_users - inactive_user_counter,
	'daysSinceStart': total_days_since_start,
	'daysPlayed': total_days_played,
	'initAppStartTime': daily_players,
	'initAppStartDate': users_played_last_three_days,
	'startOfLevelTime': installed_yesterday,
	'appStartTime': users_played_any_of_last_three_days,
	'appStartDate': total_app_starts,
	'timeNeededInSeconds': average_time_needed,
	'levelStart': started_levels,
	'levelFinish': finished_levels,
	'levelWon': levels_won,
	'finishOfLevelTime': max_level,
	'levelBought': levels_bought,
	'itemBought': items_bought,
	'collectDailyRewardsTime': daily_rewards,
	'checkHighscoreTime': checked_highscore,
	'pushClickTime': push_clicked,
	'notification_sent_time': notifications_sent,
	'appCloseDate': dark_patterns_off,
	'session': dark_patterns_on,
	'sessionCounter': dark_patterns_fomo,
	'darkPatterns': dark_patterns_var,
	'age': average_age / user_counter,
	'gender': start_survey_done,
	'education': end_survey_counter,
	'endSurvey': played_till_end,
	'endsurveydate': influenced,
}

if use_flutter:
	processed_data.append(statistics)
	processed_data.append({})
	processed_data.append({})
combined_statistics = dict(zip(statistics_overview.values(), statistics.values()))
for key, value in combined_statistics.items():
	print(f"{key}: {value}")

# Converting the processed data into a DataFrame
processed_df = pd.DataFrame(processed_data)
processed_df.head()
if use_flutter:
	excel_file_path = 'flutter_data.xlsx'
else:
	excel_file_path = 'dark_patterns_data.xlsx'

# Save the DataFrame as an Excel file
processed_df.to_excel(excel_file_path, index=False, freeze_panes=(1, 1))
