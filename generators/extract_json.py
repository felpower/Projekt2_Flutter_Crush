import pandas as pd
from datetime import datetime
import json
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db


def extract_date_time(timestamp_str):
    try:
        if timestamp_str.startswith("Time: "):
            timestamp_str = timestamp_str.split("Time: ")[-1].replace(" ", "-")
        # Try to create a datetime object from the ISO formatted string
        timestamp = datetime.fromisoformat(timestamp_str)
        # Return both the date and time components
        return timestamp.date(), timestamp.time()
    except ValueError:
        # If there is a ValueError, it means the string was not properly ISO formatted
        return None, None


def load_database():
    cred = credentials.Certificate('credentials.json')
    firebase_admin.initialize_app(cred, {
        'databaseURL': 'https://darkpatterns-ac762-default-rtdb.europe-west1.firebasedatabase.app'
    })
    ref = db.reference('/')
    data = ref.get()
    return data


# Re-processing the 'users' data with the corrected function
processed_data = []

# Path to your JSON file
json_file_path = 'darkpatterns-ac762-default-rtdb-export.json'

# Load the JSON file into a Python dictionary with the correct encoding
with open(json_file_path, 'r', encoding='utf-8') as file:  # or use 'latin-1', 'iso-8859-1', or 'cp1252'
    json_data = json.load(file)

# Access the 'users' data
users_data = json_data['users']

for user_id, user_info in users_data.items():
    row = {'userId': user_id,
           'initAppStartDate': [],
           'initAppStartTime': [],
           'appStartDate': [],
           'appStartTime': [],
           'level': [],
           'startOfLevelTime': [],
           'finishOfLevelTime': [],
           'levelWon': [],
           'collectDailyRewardsTime': [],
           'checkHighscoreTime': [],
           'pushClick': [],
           'appCloseTime': [],
           'appCloseDate': [],
           'darkPatterns': int(user_info.get('darkPatterns', 0)) if user_info.get('darkPatterns') is not None else '',
           'startSurvey': [], }

    # Extracting date and time from 'bootAppStartTime' if it exists
    init_start_time = user_info.get('initAppStartTime', None)
    if init_start_time:
        for date_time in init_start_time.values():
            start_date, start_time = extract_date_time(date_time)
            row['initAppStartDate'].append(str(start_date))
            row['initAppStartTime'].append(str(start_time))

    # Extracting date and time from 'appStartTime' if it exists
    app_start_date = user_info.get('appStartDate', None)
    if app_start_date:
        for date_time in app_start_date.values():
            start_date, start_time = extract_date_time(date_time)
            row['appStartDate'].append(str(start_date))
            row['appStartTime'].append(str(start_time))

    # Extracting date and time from 'bootAppStartTime' if it exists
    app_close_date = user_info.get('appCloseTime', None)
    if app_close_date:
        for date_time in app_close_date.values():
            start_date, start_time = extract_date_time(date_time)
            row['appCloseDate'].append(str(start_date))
            row['appCloseTime'].append(str(start_time))

    # Processing 'startOfLevel'
    start_of_level = user_info.get('startOfLevel', None)
    if start_of_level:
        for levels in start_of_level.values():
            level, time = levels.split(', ')
            row['level'].append([int(i) for i in level.split() if i.isdigit()])
            row['startOfLevelTime'].append(str(extract_date_time(time)[1]))

    # Processing 'finishOfLevel'
    finish_of_level = user_info.get('finishOfLevel', None)
    if finish_of_level:
        for levels in finish_of_level.values():
            if levels.count(',') < 2:
                comma_index = levels.find(' Time:')
                levels = levels[:comma_index] + "," + levels[comma_index:]
            level, won, time = levels.split(', ')
            row['levelWon'].append(won.split(': ')[1])
            row['finishOfLevelTime'].append(str(extract_date_time(time)[1]))

    # Processing 'collectDailyReward'
    daily_rewards = user_info.get('collectDailyRewardsTime', None)
    if daily_rewards:
        for rewards_time in daily_rewards.values():
            row['collectDailyRewardsTime'].append(str(extract_date_time(rewards_time)[1]))

    check_high_score = user_info.get('checkHighScoreTime', None)
    if check_high_score:
        for high_score_time in check_high_score.values():
            row['checkHighscoreTime'].append(str(extract_date_time(high_score_time)[1]))

    push_click = user_info.get('pushClick', None)
    if push_click:
        for push_click_time in push_click.values():
            row['pushClick'].append(str(extract_date_time(push_click_time)[1]))

    start_survey = user_info.get('startSurvey', None)
    if start_survey:
        for start_survey_result in start_survey.values():
            row['startSurvey'].append(str(start_survey_result.split('[')[1].split(']')[0].split(', ')))

    end_survey = user_info.get('endSurvey', None)
    if end_survey:
        for end_survey_result in end_survey.values():
            row['endSurvey'].append(str(end_survey_result.split('[')[1].split(']')[0].split(', ')))

    processed_data.append(row)

# Converting the processed data into a DataFrame
processed_df = pd.DataFrame(processed_data)
processed_df.head()
excel_file_path = 'dark_patterns_data.xlsx'

# Save the DataFrame as an Excel file
processed_df.to_excel(excel_file_path, index=False)
