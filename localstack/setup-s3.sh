export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
ENDPOINT=http://localhost:4566
BUCKET=
LOCAL_PATH=

aws --endpoint-url=$ENDPOINT s3 mb s3://$BUCKET || true
aws --endpoint-url=$ENDPOINT s3 sync $LOCAL s3://$BUCKET