import json
import urllib3
import os

def lambda_handler(event, context):
  # SNS 메시지 추출
  message = event['Records'][0]['Sns']['Message']
  
  alarm_name = message['AlarmName']
  description = message['AlarmDescription']
  region = message['Region']
  time = message['StateChangeTime']

  #alarm_name = "ldj-waf-rate-limit"
  #description = "WAF rate Limit alert!"
  #region = "Asia Pacific (Tokyo)"
  #time = "2024-06-03T02:16:53.527+0000"

  
  slack_webhook_url = os.environ['SLACK_WEBHOOK_URL']
  slack_message = {
	"blocks": [
		{
			"type": "header",
			"text": {
				"type": "plain_text",
				"text": "경고: " + alarm_name
			}
		}
	]
  }
  
  # 추가 정보 필드 추가 (선택 사항)
  additional_fields = []
  
  if description:
      additional_fields.append({
          "title": "설명",
          "value": description,
          "short": True
      })
  
  if region:
      additional_fields.append({
          "title": "지역",
          "value": region,
          "short": True
      })
  
  if time:
      additional_fields.append({
          "title": "시간",
          "value": time,
          "short": True
      })
  
  # 기본 메시지와 추가 정보 필드 결합
  if additional_fields:
      slack_message["attachments"] = [
          {
              "color": "#F44336",
              "fields": additional_fields
          }
      ]
  
  # JSON 문자열로 변환
  slack_message = json.dumps(slack_message)

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