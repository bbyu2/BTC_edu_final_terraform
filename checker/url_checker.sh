#!/bin/bash
result=$(curl -L -k -s --connect-timeout 15 --retry 3 -o /dev/null -w "%{http_code}\n" http://www.abcbit.shop)
if [ $result -ge 200 ] && [ $result -lt 400 ]
then
echo "Web Page is healthy"
exit 0
else
echo "Web Page is not healthy"
curl -X POST --data-urlencode "payload={\"channel\": \"#aws1-test\", \"username\": \"Web Checker \", \"text\": \"Web Page is not healthy \", \"icon_url\": \"https://www.laurel-group.com/wp-content/uploads/AWS-logo-300x300.png\"}" https://hooks.slack.com/services/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
fi
