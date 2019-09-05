import json
import os
import boto3

def lambda_handler(event, context):

    batch_client = boto3.client('batch')
    s3 = boto3.client('s3')
    
    # Event variables
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    obj = event["Records"][0]["s3"]["object"]["key"]
    data_dir = os.path.dirname(os.path.dirname(os.path.dirname(obj)))
    data_wts_dir = os.path.dirname((os.path.dirname(obj))
    job_name = bucket + "---" + data_dir.replace('/', '_').replace('.', '_')

    # List objects in Patients result folder
    response = s3.list_objects(Bucket=bucket, Prefix=data_dir, Delimiter='/')
    # Extract Prefix for WGS results path - e.g. it'll be 'Patients/ID/WGS/' or 'Patients/ID/WTS/' (if WGS results doesn't exist)
    result_WGS = json.dumps(response["CommonPrefixes"][0]["Prefix"]).strip('\"')
    # Check if WGS results exist
    if result_WGS.split(("/"))[-2] == 'WGS':
        result_umccrise = s3.list_objects(Bucket=bucket, Prefix=result_WGS, Delimiter='/')
        data_wgs_dir = json.dumps(result_umccrise["CommonPrefixes"][0]["Prefix"]).strip('\"')+"umccrised"
        print(data_wgs_dir)
    else:
        print("WGS results for the sample are not available")

    return data_wts_dir, data_wgs_dir
