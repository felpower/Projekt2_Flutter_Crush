# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
import firebase_admin
from firebase_admin import credentials, db
import pandas as pd


def load_database():
    cred = credentials.Certificate('credentials.json')
    firebase_admin.initialize_app(cred, {
        'databaseURL': 'https://darkpatterns-ac762-default-rtdb.europe-west1.firebasedatabase.app'
    })
    return_value = {}
    ref = db.reference('/')
    data = ref.get()
    users = data['users']
    for user_name, items in users.items():
        for key, item in items.items():
            print(f"Outer Key: {user_name}, Inner Dictionary: {items}")

    return return_value


# Press the green button in the gutter to run the script.
def create_excel():
    df = pd.DataFrame(database)  # Convert your structured data to a DataFrame
    df.to_excel('output.xlsx', index=False)  # Export to Excel


if __name__ == '__main__':
    database = load_database()
    create_excel()

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
