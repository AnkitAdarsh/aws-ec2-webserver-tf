#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo yum install -y mod_ssl
cd /etc/pki/tls/certs
sudo ./make-dummy-cert localhost.crt
sudo sed -i 's|SSLCertificateKeyFile /etc/pki/tls/private/localhost.key|#SSLCertificateKeyFile /etc/pki/tls/private/localhost.key|g' /etc/httpd/conf.d/ssl.conf
sudo echo "<h1>Hello There! .. This website is being loaded securely from the host - $(hostname -f).. Have a great day..</h1>" > /var/www/html/index.html
sudo systemctl restart httpd
sudo yum install -y amazon-cloudwatch-agent
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/bin/
sudo cat >/tmp/config.json <<EOL
{
    "agent": {
        "run_as_user": "root"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/etc/httpd/logs/ssl_error_log",
                        "log_group_name": "ssl_error_log",
                        "log_stream_name": "{instance_id}"
                    },
                    {
                        "file_path": "/etc/httpd/logs/ssl_access_log",
                        "log_group_name": "ssl_access_log",
                        "log_stream_name": "{instance_id}"
                    },
                    {
                        "file_path": "/etc/httpd/logs/ssl_request_log",
                        "log_group_name": "ssl_request_log",
                        "log_stream_name": "{instance_id}"
                    }
                ]
            }
        }
    }
}
EOL
sudo mv /tmp/config.json /opt/aws/amazon-cloudwatch-agent/bin/config.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
