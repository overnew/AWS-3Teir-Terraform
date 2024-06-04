#!/bin/bash

# Nginx 설치
apt update
apt install -y nginx


index_file="/var/www/html/index.html"

cat <<EOF > $index_file
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to Jin</title>
</head>
<body>
    <h1>Welcome to WEB</h1>
    <p>Hello, this is a simple webpage served by Nginx.</p>
    <a href="/was">Go to was Page</a>
</body>
</html>
EOF

systemctl start nginx

# Nginx 설정 파일 열기
nginx_config="/etc/nginx/sites-available/default"

# Nginx 프록시 설정 추가
cat <<EOF > $nginx_config
server {
    listen 80;
    server_name babo;

    location /was {
        proxy_pass http://internal-3-tier-app-alb-2072048027.ap-northeast-2.elb.amazonaws.com/;
    }
}
EOF



# 설정 적용 및 Nginx 재시작
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

