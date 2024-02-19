import json
import re
from datetime import date, datetime

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


def load_database():
	cred = credentials.Certificate('credentials.json')
	firebase_admin.initialize_app(cred, {
		'databaseURL': 'https://darkpatterns-ac762-default-rtdb.europe-west1.firebasedatabase.app'
	})
	ref = db.reference('/')
	data = ref.get()
	return data


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
database = load_database()
if use_flutter:
	users_data = database['flutter']
else:
	if use_database:
		users_data = database['users']
	else:
		users_data = load_json_file()['users']
userCounter = 1
inactive_users_data = []
# Total number of users
total_users = len(users_data)

# Counter for inactive users starts from the total number of users
inactive_user_counter = total_users
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
				processed_data.append(row.copy())

		row['appStartDate'] = ""
		row['appStartTime'] = ""

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
					time_difference = finish_datetime - start_datetime
					row['levelStart'] = int(''.join(filter(str.isdigit, level)))
					row['startOfLevelTime'] = str(closest_start_time[1])
					row['startOfLevelDate'] = str(closest_start_time[0])
					row['levelFinish'] = int(''.join(filter(str.isdigit, level)))
					row['levelWon'] = 1 if won.split(': ')[1].lower() == 'true' else 0

					row['finishOfLevelTime'] = str(finish_time)
					row['finishOfLevelDate'] = str(extract_date_time(time)[0])
					# Assign the time difference to the 'timeNeededInSec' field in the row dictionary
					row['timeNeededInSeconds'] = time_difference.total_seconds()
					start_times[level].remove(closest_start_time)
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
				processed_data.append(row.copy())

		# Processing 'collectDailyReward'
		daily_rewards = user_info.get('collectDailyRewardsTime', None)
		if daily_rewards:
			for rewards_time in daily_rewards.values():
				extracted_date_time = extract_date_time(rewards_time)
				row['collectDailyRewardsTime'] = str(extracted_date_time[1])
				row['collectDailyRewardsDate'] = str(extracted_date_time[0])
				processed_data.append(row.copy())

		row['collectDailyRewardsTime'] = ""
		row['collectDailyRewardsDate'] = ""

		check_high_score = user_info.get('checkHighScoreTime', None)
		if check_high_score:
			for high_score_time in check_high_score.values():
				extracted_date_time = extract_date_time(high_score_time)
				row['checkHighscoreTime'] = str(extracted_date_time[1])
				row['checkHighscoreDate'] = str(extracted_date_time[0])
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

				processed_data.append(row.copy())

		end_survey = user_info.get('endSurvey', None)
		if end_survey:
			for end_survey_result in end_survey.values():
				for question in end_survey_result.split('[')[1].split(']')[0].split(', '):
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
				processed_data.append(row.copy())

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

		# If the user has no other activity, add their data to the separate list and continue to the next user
		if not has_activity:
			inactive_users_data.append({
				'userNumber': inactive_user_counter,
				'userId': user_id,
				'initAppStartTime': "",
				'initAppStartDate': "",
				'appStartTime': "",
				'appStartDate': "",
				'appCloseTime': "",
				'appCloseDate': "",
			})
			inactive_user_counter -= 1
		else:
			userCounter += 1
			processed_data.append({})
	except Exception as e:
		print(f"Skipping user {user_id} due to error: {e}")
		continue

# After processing all users, append the data of inactive users to the end of your main processed data list
processed_data.extend(inactive_users_data)

# Converting the processed data into a DataFrame
processed_df = pd.DataFrame(processed_data)
processed_df.head()
excel_file_path = 'dark_patterns_data.xlsx'

# Save the DataFrame as an Excel file
processed_df.to_excel(excel_file_path, index=False, freeze_panes=(1, 1))
