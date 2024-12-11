#!/bin/bash

# Settings
DOMAIN="Set domain"
PORT=443
DAYS_THRESHOLD=30
EMAIL_TO="To e-mail"
EMAIL_SUBJECT="SSL Certificate Expiry Notification"
EMAIL_BODY="The SSL certificate for $DOMAIN is expiring in less than $DAYS_THRESHOLD days."

# Function to check SSL certificate expiry date
check_ssl_expiry() {
    expiry_date=$(echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:$PORT" 2>/dev/null | openssl x509 -noout -dates | grep 'notAfter=' | cut -d'=' -f2)
    expiry_date_seconds=$(date --date="$expiry_date" +%s)
    current_date_seconds=$(date +%s)
    remaining_days=$(( (expiry_date_seconds - current_date_seconds) / 86400 ))
    echo $remaining_days
}

# Check and send email if necessary
remaining_days=$(check_ssl_expiry)

# Display the number of days until the SSL certificate expires
echo "Number of days until the SSL certificate for $DOMAIN expires: $remaining_days"

if [ "$remaining_days" -lt "$DAYS_THRESHOLD" ]; then
    echo -e "To: $EMAIL_TO\nSubject: $EMAIL_SUBJECT\n\n$EMAIL_BODY" | sendmail -t
    if [ $? -eq 0 ]; then
        echo "Email sent successfully."
    else
        echo "Error sending email."
    fi
fi
