#!/bin/bash
# 상태 개수
CLBO=$(kubectl get pods -A | grep -i CrashLoopBackOff | grep -v "grep" | wc -l)
Pending=$(kubectl get pods -A | grep -i Pending | grep -v "grep" | wc -l)
Unknown=$(kubectl get pods -A | grep -i Unknown | grep -v "grep" | wc -l)
Failed=$(kubectl get pods -A | grep -i Failed | grep -v "grep" | wc -l)
result=$(($CLBO+$Pending+$Unknown+$Failed))
# namespace / pod name
nCLBO=$(kubectl get pods -A | grep -i CrashLoopBackOff | awk '{print $1, $2}')
nPending=$(kubectl get pods -A | grep -i Pending | awk '{print $1, $2}')
nUnknown=$(kubectl get pods -A | grep -i Unknown | awk '{print $1, $2}')
nFailed=$(kubectl get pods -A | grep -i Failed | awk '{print $1, $2}')

if [ $result == "0" ]; then
  echo "Pod is running"
else
  if [ $CLBO != "0" ]; then
    echo "Pod is CrashLoopBackOff & restarted"
    kubectl get pods -A | grep -i CrashLoopBackOff | awk '{print $1,$2}' | xargs -n 2 kubectl delete pod -n
    #slack 알림 전송
    curl -X POST --data-urlencode "payload={\"channel\": \"#aws1-test\", \"username\": \"pod-check Bot\", \"text\": \"$nCLBO is CrashLoopBackOff & restarted! \", \"icon_emoji\": \":family:\"}" https://hooks.slack.com/services/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
    continue
  elif [ $Pending != "0" ]; then
    echo "Pod is Pending & restarted"
    kubectl get pods -A | grep -i Pending | awk '{print $1,$2}' | xargs -n 2 kubectl delete pod -n
    #slack 알림 전송
    curl -X POST --data-urlencode "payload={\"channel\": \"#aws1-test\", \"username\": \"pod-check Bot\", \"text\": \"$nPending is Pending & restarted! \", \"icon_emoji\": \":family:\"}" https://hooks.slack.com/services/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
    continue
  elif [ $Unknwon != "0" ]; then
    echo "Pod is Unknown & restarted"
    kubectl get pods -A | grep -i Unknown | awk '{print $1,$2}' | xargs -n 2 kubectl delete pod -n
    #slack 알림 전송
    curl -X POST --data-urlencode "payload={\"channel\": \"#aws1-test\", \"username\": \"pod-check Bot\", \"text\": \"$nUnknown is Unknown & restarted! \", \"icon_emoji\": \":family:\"}" https://hooks.slack.com/services/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
    continue
  elif [ $Failed != "0" ]; then
    echo "Pod is Failed & restarted"
    kubectl get pods -A | grep -i Failed | awk '{print $1,$2}' | xargs -n 2 kubectl delete pod -n
    #slack 알림 전송
    curl -X POST --data-urlencode "payload={\"channel\": \"#aws1-test\", \"username\": \"pod-check Bot\", \"text\": \"$nFailed is Failed & restarted! \", \"icon_emoji\": \":family:\"}" https://hooks.slack.com/services/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
  fi
fi
