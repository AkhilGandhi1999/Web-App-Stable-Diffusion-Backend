import time
import boto3
from botocore.exceptions import ClientError
import logging
from flask import Flask, request, send_file
import re
import os
from glob import glob
from io import BytesIO
from zipfile import ZipFile


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

def image_generated(text):
    try:
        os.chdir('stable-diffusion/')
        os.system("python scripts/txt2img.py --prompt {} --plms --ckpt sd-v1-4.ckpt --skip_grid --n_samples 1".format(text))
        return True
    except:
        return False

@app.route('/store', methods=['GET'])
def store_request(bucket_name=None, region=None):
    try:
        args = request.args.to_dict()
        file_id = args['user_id']
        text = args['caption']
        bucket_name = re.sub(r'@.*', '', file_id)
        region = 'us-west-1'
        if if_bucket_exsist(bucket_name):
            if region is None:
                s3_client = boto3.client('s3')
                s3_client.create_bucket(Bucket=bucket_name)
            else:
                s3_client = boto3.client('s3', region_name=region)
                location = {'LocationConstraint': region}
                s3_client.create_bucket(Bucket=bucket_name,
                                        CreateBucketConfiguration=location)
        if image_generated(text):
            #upload to the bucket
            os.chdir('outputs/txt2img-samples/samples/')
            for f in os.listdir():
                file_name = f
                object_name = file_name
                s3.upload_file(file_name, bucket_name, object_name)

            #package images in zip file
            stream = BytesIO()
            with ZipFile(stream, 'w') as zf:
                for file in glob(os.path.join('*.png')):
                    zf.write(file, os.path.basename(file))
            stream.seek(0)

            #clean the folder after running the model
            for f in os.listdir(dir):
                os.remove(os.path.join(f))

            #return the zip file
            return send_file(
                stream,
                as_attachment=True,
                download_name='archive.zip'
            )

    except ClientError as e:
        logging.error(e)
        return {'working':'failed'}
    return {'working':'ok'}

@app.route('/getRecent', methods=['GET'])
def getRecent():
    try:
        args = request.args.to_dict()
        buck_n = args['user_id']
        bucket_name = re.sub(r'@.*', '', buck_n)
        s3 = boto3.resource('s3')
        my_bucket = s3.Bucket(bucket_name)
        
        os.chdir('send_images/')
        # download file into current directory
        for s3_object in my_bucket.objects.all():
            # Need to split s3_object.key into path and file name, else it will give error file not found.
            path, filename = os.path.split(s3_object.key)
            my_bucket.download_file(s3_object.key, filename)

        stream = BytesIO()
        with ZipFile(stream, 'w') as zf:
            for file in glob(os.path.join('*.png')):
                zf.write(file, os.path.basename(file))
        stream.seek(0)

        return send_file(
            stream,
            as_attachment=True,
            download_name='archive.zip'
        )
        
    except ClientError as e:
        logging.error(e)
        return {'working':'failed'}

if __name__ == '__main__':
	app.run(host = '0.0.0.0')