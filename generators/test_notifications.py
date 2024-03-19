import unittest
from unittest.mock import patch, call
from notification_cron import send_end_survey_reminder


class TestSendEndSurveyReminder(unittest.TestCase):
	@patch('notification_cron.send_message')
	@patch('notification_cron.update_database')
	def test_send_end_survey_reminder(self, mock_update_database, mock_send_message):
		# Define your test data
		user_tokens = [{'days_since_start': 32, 'survey_filled': False, 'token': 'token1'},
					   {'days_since_start': 30, 'survey_filled': False, 'token': 'token2'},
					   {'days_since_start': 32, 'survey_filled': True, 'token': 'token3'}]
		flutter_tokens = [{'days_since_start': 32, 'survey_filled': False, 'token': 'token4'},
						  {'days_since_start': 30, 'survey_filled': True, 'token': 'token5'},
						  {'days_since_start': 32, 'survey_filled': True, 'token': 'token6'}]

		# Replace the actual user_tokens and flutter_tokens with your test data
		with patch('notification_cron.user_tokens', user_tokens), patch('notification_cron.flutter_tokens',
																		flutter_tokens):
			send_end_survey_reminder()

		# Check that send_message and update_database were called with the correct arguments
		mock_send_message.assert_has_calls([
			call('token1', 'Vielen Dank fürs Spielen, wir würden uns freuen, wenn du an unserer Umfrage teilnimmst!'),
			call('token4', 'Vielen Dank fürs Spielen, wir würden uns freuen, wenn du an unserer Umfrage teilnimmst!')
		])
		mock_update_database.assert_has_calls([call(user_tokens[0]), call(flutter_tokens[0])])


if __name__ == '__main__':
	unittest.main()
