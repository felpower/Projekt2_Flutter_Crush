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

users_data = load_database()['errors']


def delete_error(user_id):
	ref = db.reference(f'/errors/{user_id}')
	ref.delete()


delete_error("testVersion-V02-24-01-19–12:08-H6FwYapNk5I8Tp5")
