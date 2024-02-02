import json
from datetime import datetime

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


users_data = load_database()['feedback']

for user_id, user_info in users_data.items():
	row = {'userId': user_id,
		   'feedback': user_info.get('info', None),
		   'timestamp': user_info.get('timestamp', None),
		   'userAgent': user_info.get('userAgent', None),
		   'file': user_info.get('fileUrl', None),
		   'task_completed': False
		   }
	processed_data.append(row.copy())

# Converting the processed data into a DataFrame
processed_df = pd.DataFrame(processed_data)
processed_df.head()
excel_file_path = 'feedback.xlsx'

# Save the DataFrame as an Excel file
processed_df.to_excel(excel_file_path, index=False)
