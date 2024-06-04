#!/bin/bash

# Apache2, PHP, PHP-MySQL 설치
apt update
apt install -y apache2 php libapache2-mod-php php-mysql

cat <<EOF > /var/www/html/test.php
<!DOCTYPE html>
<html>
<head>
    <title>PHP Info</title>
</head>
<body>
    <h1>out test</h1>
    <?php
    // phpinfo() 함수 호출
    phpinfo();
    ?>
</body>
</html>
EOF

# index.php 파일 생성
cat <<EOF > /var/www/html/my.php
<!DOCTYPE html>
<html>
<head>
    <title>User Search</title>
</head>
<body>
    <h1>User Search</h1>
    <form action="my.php" method="post">
        <label for="id">Enter User ID:</label>
        <input type="text" id="id" name="id">
        <button type="submit" name="search">Search</button>
        <button type="submit" name="init">Initialize</button>
    </form>

    <?php
    \$mysqli = new mysqli("terraform-20240420014155648400000002.cxk20qkiw68i.ap-northeast-2.rds.amazonaws.com", "rootroot", "rootroot");

    if (\$mysqli->connect_errno) {
        echo "Failed to connect to MySQL: " . \$mysqli->connect_error;
        exit();
    }

    // 초기화 버튼이 눌린 경우
    if (isset(\$_POST['init'])) {
        // 데이터베이스 생성
        \$sql_create_db = "CREATE DATABASE IF NOT EXISTS test_db";
        if (\$mysqli->query(\$sql_create_db) === TRUE) {
            echo "Database created successfully<br>";
        } else {
            echo "Error creating database: " . \$mysqli->error . "<br>";
        }

        // 데이터베이스 선택
        \$mysqli->select_db("test_db");

        // 테이블 생성
        \$sql_create_table = "CREATE TABLE IF NOT EXISTS users (
                            id INT AUTO_INCREMENT PRIMARY KEY,
                            name VARCHAR(50))";
        if (\$mysqli->query(\$sql_create_table) === TRUE) {
            echo "Table created successfully<br>";
        } else {
            echo "Error creating table: " . \$mysqli->error . "<br>";
        }

        // 데이터 삽입
        \$sql_insert_data = "INSERT INTO users (name) VALUES ('root'), ('Jin'), ('Doe')";
        if (\$mysqli->query(\$sql_insert_data) === TRUE) {
            echo "Data inserted successfully<br>";
        } else {
            echo "Error inserting data: " . \$mysqli->error . "<br>";
        }
    }

    // 사용자 검색
    if (isset(\$_POST['search'])) {
        \$id = \$_POST['id'];
        \$mysqli->select_db("test_db");

        \$result = \$mysqli->query("SELECT * FROM users WHERE id=\$id");
        if (\$result->num_rows > 0) {
            while (\$row = \$result->fetch_assoc()) {
                echo "ID: " . \$row['id'] . ", Name: " . \$row['name'] . "<br>";
            }
        } else {
            echo "No user found with ID: \$id";
        }
    }

    \$mysqli->close();
    ?>
</body>
</html>
EOF

# Apache2 재시작
systemctl restart apache2

echo "done"