import boto3
import os
import datetime
# 아래 변수들은 구성> 환경변수에 설정한 변수들이 입력된다.

GROUP_NAME = os.environ['GROUP_NAME']
DESTINATION_BUCKET = os.environ['DESTINATION_BUCKET']
PREFIX = os.environ['PREFIX']
PERIOD = os.environ['PERIOD']
PERIOD = int(PERIOD)
currentTime = datetime.datetime.now()
startDate = currentTime - datetime.timedelta(PERIOD)
endDate = currentTime - datetime.timedelta(PERIOD - 1)
fromDate = int(startDate.timestamp() * 1000)
toDate = int(endDate.timestamp() * 1000)
BUCKET_PREFIX = os.path.join(PREFIX,startDate.strftime('%Y{0}%m{0}%d').format(os.path.sep))

def lambda_handler(event, context):
  print(currentTime, startDate, endDate, PERIOD, fromDate, toDate)
  client = boto3.client("logs")
  client.create_export_task(
    logGroupName= GROUP_NAME,
    fromTime = fromDate,
    to=toDate,
    destination=DESTINATION_BUCKET,
    destinationPrefix=BUCKET_PREFIX
  )