# ABCbit 인프라 자동화

### Solution Architecture
```
Terraform을 이용한 AWS의 리소스 생성 및 자동화 
```
![image](https://user-images.githubusercontent.com/84059211/212466595-97a4bbe5-d361-4e38-ad72-0f0f5cc3e9ec.png)

<br/>

### Kubernetes
```
namespace(NS)를 통한 Kubernetes환경 분리
1. (NS)abcbit : 코인 거래 웹 서비스 ABCbit 배포 및 고가용성을 위한 HPA(Horizontal Pod Autoscaling) 설정
2. (NS)test : 실제 배포 전, 코드 수정 및 변경 사항의 동작 확인을 위한 설정
3. (NS)argocd : 자동 배포 및 argoCD 웹콘솔 접속을 위한 설정
4. (NS)monitoring : prometheus를 통한 Node 및 Pod의 매트릭 수집 및 매트릭 시각화를 위한 Grafana namespace 설정
```
![image](https://user-images.githubusercontent.com/84059211/212466655-d20a7099-78ea-4139-be11-0ce9950462c3.png)

<br/>

### Monitorting
```
EKS의 Node 및 Pod 모니터링 진행
1. Prometheus를 통한 Node, Pod 메트릭 정보 수집
2. Grafana 연동을 통해 Prometheus가 수집한 메트릭 시각화 진행
3. CPU, Memory등의 사용률 뿐만 아니라 HPA(Horizontal Pod Autoscaling)상태, Deployment의 업데이트 현황등을 모니터링 진행하여 상태 체크
```
![image](https://user-images.githubusercontent.com/84059211/212467121-db4aa420-dafa-47c7-9528-c567451be119.png)

<br/>

#### AWS 리소스 모니터링
```
AWS의 리소스 모니터링 진행
1. EKS의 Node, Pod의 모니터링은 Prometheus와 Grafana를 통해 진행함
2. 그 외 AWS의 리소스인 RDS, ALB, EFS는 AWS의 Cloud Watch를 통해 모니터링 진행
3. RDS는 CPU를 중점으로, ALB는 URL체크를 통한 서비스 상태 체크, 공유 스토리지인 EFS는 Data I/O등을 중점으로 확인 진행
```
![image](https://user-images.githubusercontent.com/84059211/212467184-1bd1d661-7365-4478-b80f-ad8f3f4edbfc.png)

<br/>

#### 모니터링 이중화를 위한 쉘 스크립트 작성
```
1. 웹 서비스의 URL별 상태 체크 진행(메인, 거래소, 자동매매 페이지 별로 URL 상태 체크)
2. Pod가 멈춰 있는 상태이거나 이거나 비정상적인 종료가 되었을때 등, 정상 동작하지 않을 경우 파드 삭제
3. 위 작업들은 진행 후 Slack을 통해 알림을 받을 수 있음
```
![image](https://user-images.githubusercontent.com/84059211/212467216-f6e2c7ff-d5fd-4dbe-b769-5091ab08400e.png)

<br/>

### Log 관리
```
1. AWS 파일 시스템 스토리지인 EFS에 모든 로그 저장 후, 10일 뒤 삭제
2. 매일 자정 EFS의 로그들은 AWS S3에 저장 됨
3. S3에 LifeCycle 설정 하여 비용 절감 
```
![image](https://user-images.githubusercontent.com/84059211/212467232-c9a98e2b-a5d7-4760-b8e1-ab8cc45e792f.png)
