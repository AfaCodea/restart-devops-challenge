#!/bin/bash
# User data script for AWS Restart Challenge
# Amazon Linux 2023 - Deploy web server with hello.html

# Update system packages
yum update -y

# Install Apache web server
yum install -y httpd

# Start and enable Apache service
systemctl start httpd
systemctl enable httpd

# Create the HTML file from template
cat > /var/www/html/index.html << 'HTMLEOF'
${html_content}
HTMLEOF

# Set proper permissions
chmod 644 /var/www/html/index.html
chown apache:apache /var/www/html/index.html

# Restart Apache to ensure everything is loaded
systemctl restart httpd
