import requests
import boto3
from botocore.exceptions import ClientError
import logging
from flask import Flask, request, Response, send_file



app = Flask(__name__)
s3 = boto3.client('s3')


@app.route('/', methods=['GET', 'POST'])
def handle_request():
    print('hello world')
    return {'hello': 'world'}

def if_bucket_exsist(file_id):
    try:
        response = s3.list_buckets()
        for bucket in response['Buckets']:
            if (bucket["Name"]==file_id):
                return False
    except ClientError as e:
        logging.error(e)
        return False

    return True

def image_generated():
    return True

@app.route('/store', methods=['GET'])
def store_request(bucket_name=None, region=None):
    try:
        file_name = 'A2.jpg'
        object_name = file_name
        args = request.args.to_dict()
        file_id = args['user_id']
        bucket_name = file_id
        region = 'us-west-1'
        if if_bucket_exsist(file_id):
            if region is None:
                s3_client = boto3.client('s3')
                s3_client.create_bucket(Bucket=bucket_name)
            else:
                s3_client = boto3.client('s3', region_name=region)
                location = {'LocationConstraint': region}
                s3_client.create_bucket(Bucket=bucket_name,
                                        CreateBucketConfiguration=location)
        if image_generated():
            s3.upload_file(file_name, bucket_name, object_name)

    except ClientError as e:
        logging.error(e)
        return {'working':'failed'}
    return {'working':'ok'}


if __name__ == '__main__':
	app.run(host = '0.0.0.0')