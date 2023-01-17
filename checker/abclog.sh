#!/bin/bash
TODAY=$(date +%Y-%m-%d)

# daily log backup
sudo cp /home/ec2-user/abclog/nginx/access.log /home/ec2-user/log/nginx/access_${TODAY}.log
sudo cp /home/ec2-user/abclog/nginx/error.log /home/ec2-user/log/nginx/error_${TODAY}.log
sudo cp /home/ec2-user/abclog/gunicorn/access.log /home/ec2-user/log/gunicorn/access_${TODAY}.log
sudo cp /home/ec2-user/abclog/gunicorn/error.log /home/ec2-user/log/gunicorn/error_${TODAY}.log

# 기존 로그파일 내용 지우기
sudo cp /home/ec2-user/empty.log /home/ec2-user/abclog/nginx/access.log
sudo cp /home/ec2-user/empty.log /home/ec2-user/abclog/nginx/error.log
sudo cp /home/ec2-user/empty.log /home/ec2-user/abclog/gunicorn/access.log
sudo cp /home/ec2-user/empty.log /home/ec2-user/abclog/gunicorn/error.log

# 권한 변경
sudo chmod -R 777 /home/ec2-user/log/

# 30일 지난 로그 삭제및 S3 Upload
find /home/ec2-user/log/nginx/* -mtime -1 -exec sh -c "aws s3 cp {} s3://abcbit-log/All_log/$TODAY/nginx/ --storage-class STANDARD --profile abc-profile; rm -f {};" \;
find /home/ec2-user/log/gunicorn/* -mtime -1 -exec sh -c "aws s3 cp {} s3://abcbit-log/All_log/$TODAY/gunicorn/ --storage-class STANDARD --profile abc-profile; rm -f {};" \;
