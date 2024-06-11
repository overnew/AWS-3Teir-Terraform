import urllib3
import json
import boto3
import os

def lambda_handler(event, context):
    
  #In this implementation, payload.summary is set to description (to mimic pagerduty_config.description)
  #In this implementation, payload.source is set to client_url
  
  try:
    message= event['Records'][0]['Sns']['Message']
    #message = json.loads(event['Records'][0]['Sns']['Message'])
    #print(event)

    
    taskNum = 1
    if "ut" not in message:
      taskNum = -1

    
        # ECS 클라이언트 생성
    ecs_client = boto3.client('ecs')

    # 서비스 이름 및 클러스터 이름 가져오기
    service_name = "web-service"
    cluster_name = "web-ecs"

    # 현재 작업 수 가져오기
    current_task_count = ecs_client.describe_services(
        cluster=cluster_name,
        services=[service_name]
    )['services'][0]['desiredCount']

    if current_task_count <= 1:
      return
    elif current_task_count >=6:
      return

    # 작업 수 늘리기
    new_task_count = current_task_count + taskNum
    ecs_client.update_service(
        cluster=cluster_name,
        service=service_name,
        desiredCount=new_task_count
    )

   

    http = urllib3.PoolManager()
    
    slack_webhook_url = os.environ['SLACK_WEBHOOK_URL']
    slack_message = {
    "blocks": [
    	{
    		"type": "header",
    		"text": {
    			"type": "plain_text",
    			"text": "경고: " + message
    		}
    	}
    ]
    }
    
    slack_message = json.dumps(slack_message)
    response = http.request('POST', slack_webhook_url ,headers={'Content-Type': 'application/json'},body=slack_message)
    

    # 결과 반환
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'Service {service_name} in cluster {cluster_name} task count updated to {new_task_count}'
        })
    }

  except Exception as e:
    raise e
    return