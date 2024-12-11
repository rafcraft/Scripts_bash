import ssl
import socket
import json
from datetime import datetime
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


# Function to load configuration from JSON file
def load_config(config_file: str) -> dict:
    with open(config_file, 'r') as file:
        conf = json.load(file)
    return conf


# check date to expire cert SSL
def get_ssl_expiry_days(port_host, host_name: str) -> int:
    context = ssl.create_default_context()
    with socket.create_connection((host_name, port_host)) as connection:
        with context.wrap_socket(connection, server_hostname=host_name) as ssl_connection:
            ssl_info = ssl_connection.getpeercert()
            expiry_date_str = ssl_info['notAfter']
            expiry_date = datetime.strptime(expiry_date_str, '%b %d %H:%M:%S %Y %Z')
            current_datetime = datetime.now()
            return (expiry_date - current_datetime).days


# Function to send e-mail
def send_email(sub: str, bd: str, to_email: str, from_email: str,
               from_password: str, smtp_server: str, smtp_port: int):
    # Email configuration
    msg = MIMEMultipart()
    msg['From'] = from_email
    msg['To'] = to_email
    msg['Subject'] = sub
    msg.attach(MIMEText(bd, 'plain'))

    # Send message
    try:
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()
            server.login(from_email, from_password)
            server.sendmail(from_email, to_email, msg.as_string())
        print("Email sent successfully")
    except Exception as e:
        print(f"Failed to send email: {e}")


# Load configuration
config = load_config('config.json')
hostname = config['hostname']
port = config['port']

if get_ssl_expiry_days(port, hostname) < config['expiry_threshold_days']:
    subject = f"The SSL certificate for {hostname} will expire in {get_ssl_expiry_days(port, hostname)} days"
    body = (f"Certyfikat SSL dla {hostname} wygaśnie za {get_ssl_expiry_days(port, hostname)}"
            f"dni. Proszę o jego odnowienie.\n"
            f"The SSL certificate for {hostname} will expire in {get_ssl_expiry_days(port, hostname)}"
            f" days. Please renew it.")
    send_email(subject, body, config['to_email'], config['from_email'],
               config['from_password'], config['smtp_server'], config['smtp_port'])
