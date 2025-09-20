from flask import Flask, jsonify, request, send_from_directory
import mysql.connector
from db_config import DB_CONFIG
import boto3
from datetime import datetime, timedelta
import os

base_dir = os.path.dirname(os.path.abspath(__file__))
static_dir = os.path.join(base_dir, 'frontend_files')
app = Flask(__name__, static_folder=static_dir)

#app = Flask(__name__, static_folder='../frontend_files')

# MySQL DB connection
def get_db_connection():
    return mysql.connector.connect(
        host=DB_CONFIG['host'],
        user=DB_CONFIG['user'],
        password=DB_CONFIG['password'],
        database=DB_CONFIG['database']
    )

# CloudWatch CPU metrics
def get_instance_metrics(instance_id):
    cloudwatch = boto3.client('cloudwatch', region_name='us-east-1')
    cpu = cloudwatch.get_metric_statistics(
        Namespace='AWS/EC2',
        MetricName='CPUUtilization',
        Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
        StartTime=datetime.utcnow() - timedelta(minutes=10),
        EndTime=datetime.utcnow(),
        Period=300,
        Statistics=['Average']
    )
    avg_cpu = round(cpu['Datapoints'][0]['Average'], 2) if cpu['Datapoints'] else 0.0
    return {
        'cpu': avg_cpu,
        'memory': 'N/A'  # Needs CW agent
    }

# Serve frontend
#@app.route('/')
#def serve_frontend():
#    return send_from_directory(app.static_folder, 'index.html')

@app.route("/healthz")
def health_check():
    return "OK", 200

@app.route('/api/data', methods=['GET'])
def get_data():
    try:
        conn = mysql.connector.connect(
            host=DB_CONFIG['host'],
            user=DB_CONFIG['user'],
            password=DB_CONFIG['password'],
            database=DB_CONFIG['database']
        )
        cursor = conn.cursor()
        cursor.execute("SELECT message FROM messages LIMIT 1")
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        if result:
            return jsonify({'message': result[0]}), 200
        else:
            return jsonify({'message': 'No data'}), 200
    except mysql.connector.Error as err:
        # Log the error, return a 500 status
        return jsonify({'error': str(err)}), 500

@app.route('/api/instances', methods=['GET'])
def list_instances():
    try:
        ec2 = boto3.resource('ec2', region_name='us-east-1')
        instances = ec2.instances.all()

        result = {'app': [], 'web': [], 'db': []}
        for instance in instances:
            role = 'other'
            for tag in instance.tags or []:
                if tag['Key'].lower() == 'role':
                    role = tag['Value'].lower()

            metrics = get_instance_metrics(instance.id)
            instance_data = {
                'id': instance.id,
                'type': instance.instance_type,
                'state': instance.state['Name'],
                'cpu': f"{metrics['cpu']}%",
                'memory': metrics['memory']
            }

            if role in result:
                result[role].append(instance_data)

        return jsonify(result), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # Using host=0.0.0.0 so ALB can reach
    app.run(host='0.0.0.0', port=3000)

