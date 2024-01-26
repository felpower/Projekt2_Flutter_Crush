import json

import firebase_admin
import pandas as pd
from firebase_admin import credentials
from firebase_admin import db


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


users_data = load_database()['logs']

for user_id, error_info in users_data.items():
	# Iterate over the error entries
	for entry_id, entry_info in error_info.items():
		# Check if entry_info is a dictionary
		if isinstance(entry_info, dict):
			# Extract the error details
			error_details = {
				'user_id': user_id,
				'log': entry_info.get('log'),
				'message': entry_info.get('message'),
				'timestamp': entry_info.get('timestamp'),
				'userAgent': entry_info.get('userAgent'),
			}
			# Add the error details to the list
			processed_data.append(error_details)
		else:
			error_details = {
				'user_id': user_id,
				'log': error_info.get('log'),
				'message': error_info.get('message'),
				'timestamp': error_info.get('timestamp'),
				'userAgent': error_info.get('userAgent'),
			}
			# Add the error details to the list
			processed_data.append(error_details)

# Converting the processed data into a DataFrame
processed_df = pd.DataFrame(processed_data)
processed_df.head()
excel_file_path = 'logs.xlsx'

# Save the DataFrame as an Excel file
processed_df.to_excel(excel_file_path, index=False)
