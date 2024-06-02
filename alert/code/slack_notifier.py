import json
import urllib3
import os

def lambda_handler(event, context):
  # SNS 메시지 추출
  message = event['Records'][0]['Sns']['Message']

  # Slack Webhook URL 가져오기
  slack_webhook_url = os.environ['SLACK_WEBHOOK_URL']

  # Slack 메시지 
  slack_message = json.dumps({
    "text": message
  })
    

  http = urllib3.PoolManager()
  # Slack 메시지 전송
  try:
    response = http.request('POST', slack_webhook_url ,headers={'Content-Type': 'application/json'},body=slack_message)
    #requests.post(slack_webhook_url, json=slack_message)
    #if response.status_code != 200:
    #  raise Exception('Slack message sending failed. Code: {}. Content: {}'.format(response.status_code, response.content))
  except Exception as e:
    print(e)
    raise e