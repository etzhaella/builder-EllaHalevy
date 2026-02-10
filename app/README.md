# AWS Resources Dashboard

A Flask web application that displays AWS resources including EC2 instances, VPCs, Load Balancers, and AMIs in a simple web interface.

## Features

- View running EC2 instances with their state, type, and public IP
- Display VPCs with their CIDR blocks
- Show Load Balancers with their DNS names
- List available AMIs owned by the account
- Error handling for AWS API issues
- Clean, responsive web interface

## Prerequisites

- Python 3.7 or higher
- AWS Account with appropriate permissions
- AWS credentials configured

## Installation

1. Clone the repository:
```bash
git clone https://github.com/etzhaella/EllaHalevy_AWS_pro1210.git
cd EllaHalevy_AWS_pro1210
```

2. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

## Configuration

Set up your AWS credentials as environment variables:

```bash
export AWS_ACCESS_KEY_ID=your_access_key_here
export AWS_SECRET_ACCESS_KEY=your_secret_key_here
```

Or use AWS CLI configuration:
```bash
aws configure
```

## Required AWS Permissions

Your AWS credentials need the following permissions:
- `ec2:DescribeInstances`
- `ec2:DescribeVpcs`
- `ec2:DescribeImages`
- `elasticloadbalancing:DescribeLoadBalancers`

## Usage

1. Start the application:
```bash
python app.py
```

2. Open your browser and navigate to:
```
http://localhost:5001
```

## Project Structure

```
├── app.py              # Main Flask application
├── requirements.txt    # Python dependencies
└── README.md          # This file
```

## Development

This project is currently on the `dev` branch. To contribute:

1. Create a feature branch from `dev`
2. Make your changes
3. Test thoroughly
4. Submit a pull request to the `dev` branch

## Error Handling

The application includes error handling for:
- Missing AWS credentials
- Network connectivity issues
- AWS API rate limiting
- Invalid AWS permissions

## Security Notes

- Never commit AWS credentials to version control
- Use IAM roles when possible instead of access keys
- Regularly rotate your AWS credentials
- Follow the principle of least privilege for AWS permissions

## License

This project is for educational purposes as part of AWS training.
