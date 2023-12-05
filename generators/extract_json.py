import pandas as pd
from datetime import datetime
import json
import re

# Revised function to safely extract the last timestamp value from a nested dictionary
def extract_last_timestamp_value_safe(nested_dict):
    if not isinstance(nested_dict, dict) or not nested_dict:
        return ''
    # Get the last key in the dictionary which should correspond to the last timestamp entry
    last_key = sorted(nested_dict.keys())[-1]
    return nested_dict[last_key]


def extract_date_time(timestamp_str):
    try:
        timestamp_str = timestamp_str.split("Time: ")[-1].replace(" ", "-")
        # Try to create a datetime object from the ISO formatted string
        timestamp = datetime.fromisoformat(timestamp_str)
        # Return both the date and time components
        return timestamp.date(), timestamp.time()
    except ValueError:
        # If there is a ValueError, it means the string was not properly ISO formatted
        return None, None


# Re-processing the 'users' data with the corrected function
processed_data = []


# Path to your JSON file
json_file_path = 'path_to_your_json_file.json'

# Load the JSON file into a Python dictionary with the correct encoding
with open(json_file_path, 'r', encoding='utf-8') as file:  # or use 'latin-1', 'iso-8859-1', or 'cp1252'
    json_data = json.load(file)

# Access the 'users' data
users_data = json_data['users']

for user_id, user_info in users_data.items():
    row = {
        'userid': user_id,
        'initAppStartDate': extract_last_timestamp_value_safe(user_info.get('initAppStartTime', {})),
        'appStartDate': '',
        'appStartTime': '',
        'level': '',
        'startOfLevelTime': '',
        'finishOfLevelTime': '',
        'levelWon': '',
        'collectDailyRewardTime': extract_last_timestamp_value_safe(user_info.get('collectDailyRewardsTime', {})),
        'checkHighscoreTime': extract_last_timestamp_value_safe(user_info.get('checkHighScoreTime', {})),
        'appCloseTime': extract_last_timestamp_value_safe(user_info.get('closeAppTime', {})),
        'darkpatterns': int(user_info.get('darkPatterns', 0)) if user_info.get('darkPatterns') is not None else ''
    }

    # Extracting date and time from 'bootAppStartTime' if it exists and is a string
    boot_app_start = user_info.get('bootAppStartTime', None)
    if boot_app_start and isinstance(boot_app_start, str):
        boot_app_start_date, boot_app_start_time = extract_date_time(boot_app_start)
        row['appStartDate'] = boot_app_start_date
        row['appStartTime'] = boot_app_start_time

    # Processing 'startOfLevel'
    if 'startOfLevel' in user_info and user_info['startOfLevel']:
        # Extract the last timestamp value for the level start
        row['level'] = list(user_info['startOfLevel'].values())  # Assuming the last key is the level
        last_start_timestamp = extract_last_timestamp_value_safe(user_info['startOfLevel'])
        row['startOfLevelTime'] = extract_date_time(last_start_timestamp)[1]

    # Processing 'finishOfLevel'
    if 'finishOfLevel' in user_info and user_info['finishOfLevel']:
        # Extract the last timestamp value for the level finish
        last_finish_info = user_info['finishOfLevel'][list(user_info['finishOfLevel'].keys())[-1]]
        row['finishOfLevelTime'] = extract_date_time(last_finish_info)[1]
        result = re.search('Won: (.*) Time:', last_finish_info)
        row['levelWon'] = result.group(1)

    processed_data.append(row)

# Converting the processed data into a DataFrame
processed_df = pd.DataFrame(processed_data)
processed_df.head()
excel_file_path = 'path_to_save_your_excel_file.xlsx'

# Save the DataFrame as an Excel file
processed_df.to_excel(excel_file_path, index=False)