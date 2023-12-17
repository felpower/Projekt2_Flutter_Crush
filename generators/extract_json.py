import json
import re
from datetime import datetime
import pandas as pd
import firebase_admin
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


use_database = False
# Access the 'users' data
user_data = {}
if use_database:
    users_data = load_database()['users']
else:
    users_data = load_json_file()['users']
for user_id, user_info in users_data.items():
    row = {'userId': user_id,
           'initAppStartDate': "",
           'initAppStartTime': "",
           'appStartDate': "",
           'appStartTime': "",
           'levelStart': "",
           'startOfLevelTime': "",
           'levelFinish': "",
           'finishOfLevelTime': "",
           'levelWon': "",
           'collectDailyRewardsTime': "",
           'checkHighscoreTime': "",
           'pushClick': "",
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
           }

    # Extracting date and time from 'bootAppStartTime' if it exists
    init_start_time = user_info.get('initAppStartTime', None)
    if init_start_time:
        for date_time in init_start_time.values():
            start_date, start_time = extract_date_time(date_time)
            row['initAppStartDate'] = str(start_date)
            row['initAppStartTime'] = str(start_time)
            processed_data.append(row.copy())

    row['initAppStartDate'] = ""
    row['initAppStartTime'] = ""

    # # Extracting date and time from 'appStartTime' if it exists
    app_start_date = user_info.get('appStartDate', None)
    if app_start_date:
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
            start_times[level] = (str(extract_date_time(time)[1]))

    # Processing 'finishOfLevel'
    finish_of_level = user_info.get('finishOfLevel', None)
    if finish_of_level:
        for levels in finish_of_level.values():
            if levels.count(',') < 2:
                comma_index = levels.find(' Time:')
                levels = levels[:comma_index] + "," + levels[comma_index:]
            level, won, time = levels.split(', ')
            if level in start_times:
                row['levelStart'] = ([int(i) for i in level.split() if i.isdigit()])
                row['startOfLevelTime'] = start_times[level]
                row['levelFinish'] = ([int(i) for i in level.split() if i.isdigit()])
                row['levelWon'] = won.split(': ')[1]
                row['finishOfLevelTime'] = str(extract_date_time(time)[1])
                processed_data.append(row.copy())
                del start_times[level]

    # Append remaining 'startOfLevel' times that did not have a corresponding 'finishOfLevel'
    for level, start_time in start_times.items():
        row['levelStart'] = ([int(i) for i in level.split() if i.isdigit()])
        row['startOfLevelTime'] = start_time
        row['levelFinish'] = ([int(i) for i in level.split() if i.isdigit()])
        row['levelWon'] = "false"
        row['finishOfLevelTime'] = ""
        processed_data.append(row.copy())

    row['levelStart'] = ""
    row['startOfLevelTime'] = ""
    row['levelFinish'] = ""
    row['levelWon'] = ""
    row['finishOfLevelTime'] = ""

    # Processing 'collectDailyReward'
    daily_rewards = user_info.get('collectDailyRewardsTime', None)
    if daily_rewards:
        for rewards_time in daily_rewards.values():
            row['collectDailyRewardsTime'] = str(extract_date_time(rewards_time)[1])
            processed_data.append(row.copy())

    row['collectDailyRewardsTime'] = ""

    check_high_score = user_info.get('checkHighScoreTime', None)
    if check_high_score:
        for high_score_time in check_high_score.values():
            row['checkHighscoreTime'] = str(extract_date_time(high_score_time)[1])
            processed_data.append(row.copy())

    row['checkHighscoreTime'] = ""

    push_click = user_info.get('pushClick', None)
    if push_click:
        for push_click_time in push_click.values():
            row['pushClick'] = str(extract_date_time(push_click_time)[1])
            processed_data.append(row.copy())

    row['pushClick'] = ""

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
                elif identifier == 6:
                    row['frequencyPlaying'] = answer
                elif identifier == 7:
                    row['hoursPlaying'] = answer
                elif identifier == 8:
                    row['moneySpent'] = answer

            processed_data.append(row.copy())

    end_survey = user_info.get('endSurvey', None)

    if end_survey:
        for end_survey_result in end_survey.values():
            row['endSurvey'] = str(end_survey_result.split('[')[1].split(']')[0].split(', '))
            processed_data.append(row.copy())
    processed_data.append({})

# Converting the processed data into a DataFrame
processed_df = pd.DataFrame(processed_data)
processed_df.head()
excel_file_path = 'dark_patterns_data.xlsx'

# Save the DataFrame as an Excel file
processed_df.to_excel(excel_file_path, index=False)
