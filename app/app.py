import os
import boto3
from flask import Flask, render_template_string

app = Flask(__name__)

# Fetch AWS credentials from environment variables
AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
REGION = "us-east-1"

# Initialize Boto3 clients
session = boto3.Session(
    aws_access_key_id=AWS_ACCESS_KEY,
    aws_secret_access_key=AWS_SECRET_KEY,
    region_name=REGION
)
ec2_client = session.client("ec2")
elb_client = session.client("elbv2")


@app.route("/")
def home():
    try:
        # Fetch EC2 instances
        instances = ec2_client.describe_instances()
        instance_data = []
        for reservation in instances["Reservations"]:
            for instance in reservation["Instances"]:
                instance_data.append({
                    "ID": instance["InstanceId"],
                    "State": instance["State"]["Name"],
                    "Type": instance["InstanceType"],
                    "Public IP": instance.get("PublicIpAddress", "N/A")
                })

        # Fetch VPCs
        vpcs = ec2_client.describe_vpcs()
        vpc_data = [
            {"VPC ID": vpc["VpcId"], "CIDR": vpc["CidrBlock"]}
            for vpc in vpcs["Vpcs"]
        ]

        # Fetch Load Balancers
        lbs = elb_client.describe_load_balancers()
        lb_data = [
            {"LB Name": lb["LoadBalancerName"], "DNS Name": lb["DNSName"]}
            for lb in lbs["LoadBalancers"]
        ]

        # Fetch AMIs (only owned by the account)
        amis = ec2_client.describe_images(Owners=["self"])
        ami_data = [
            {"AMI ID": ami["ImageId"], "Name": ami.get("Name", "N/A")}
            for ami in amis["Images"]
        ]

        error_message = None

    except Exception as e:
        # Handle AWS API errors gracefully
        error_message = f"Error fetching AWS resources: {str(e)}"
        instance_data = []
        vpc_data = []
        lb_data = []
        ami_data = []

    html_template = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>AWS Resources Monitor</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 20px; }
            h1 { color: #333; }
            table { border-collapse: collapse; width: 100%; margin-bottom: 30px; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background-color: #f2f2f2; }
            .error { color: red; background-color: #ffe6e6; padding: 10px; border-radius: 5px; }
        </style>
    </head>
    <body>
        {% if error_message %}
        <div class="error">{{ error_message }}</div>
        {% endif %}

        <h1>Running EC2 Instances</h1>
        <table>
            <tr><th>ID</th><th>State</th><th>Type</th><th>Public IP</th></tr>
            {% for instance in instance_data %}
            <tr>
                <td>{{ instance['ID'] }}</td>
                <td>{{ instance['State'] }}</td>
                <td>{{ instance['Type'] }}</td>
                <td>{{ instance['Public IP'] }}</td>
            </tr>
            {% endfor %}
        </table>

        <h1>VPCs</h1>
        <table>
            <tr><th>VPC ID</th><th>CIDR</th></tr>
            {% for vpc in vpc_data %}
            <tr>
                <td>{{ vpc['VPC ID'] }}</td>
                <td>{{ vpc['CIDR'] }}</td>
            </tr>
            {% endfor %}
        </table>

        <h1>Load Balancers</h1>
        <table>
            <tr><th>LB Name</th><th>DNS Name</th></tr>
            {% for lb in lb_data %}
            <tr>
                <td>{{ lb['LB Name'] }}</td>
                <td>{{ lb['DNS Name'] }}</td>
            </tr>
            {% endfor %}
        </table>

        <h1>Available AMIs</h1>
        <table>
            <tr><th>AMI ID</th><th>Name</th></tr>
            {% for ami in ami_data %}
            <tr>
                <td>{{ ami['AMI ID'] }}</td>
                <td>{{ ami['Name'] }}</td>
            </tr>
            {% endfor %}
        </table>
    </body>
    </html>
    """

    return render_template_string(
        html_template,
        instance_data=instance_data,
        vpc_data=vpc_data,
        lb_data=lb_data,
        ami_data=ami_data,
        error_message=error_message,
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)

    