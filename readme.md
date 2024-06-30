# 밀리프레소 웹 서비스 & 비실시간 SIEM 환경 구축 

<br>
<br>

## 개요

MZC MSP SA 양성과정 최종 프로젝트
<br>
AWS 서버리스 웹 애플리케이션 및 SIEM 을 주제로 전체 인프라를 Terraform을 통해 구현


<br>

<strong>아키텍처
</strong>
<br>

<img width="100%" src= "https://github.com/overnew/Cloud-SIEM-Infra-Terraform/assets/43613584/340b2b73-ef17-493d-aebc-158121426fb9">

<br>
<br>
<br>

## 구현 기능

<strong> 밀리프레소 정기 구독 서비스를 위한 웹서비스 구축 목표</strong>
1.	고가용성 및 탄력성을 가진 AWS 인프라 구성
2.	보안을 강화한 인프라 설계
3.	인프라 자원 모니터링 제공
4.	웹 서비스를 위한 CI/CD 제공
5.	정기적인 백업 진행
6.	인프라 로그의 중앙화 수집/저장
7.	Opensearch를 통한 비실시간 SIEM 분석 구현
8.	전체 인프라를 테라폼으로 제공


<br><br>

<strong>테라폼의 관리를 벗어난 리소스 </strong>
<br>

아래의 리소스는 테라폼으로 삭제가 일어나는 것을 방지하기 위해 직접 생성이 필요한 리소스 리스트이다.

1.	Route53 도메인 및 호스팅 영역
2.	KMS 키 
3.	Code Commit 리포지토리 및 ECR 리포지토리
4.	AWS Prometheus 및 AWS Grafana


<br>
<br>

## 보안 흐름


<br>
  
  <img width="80%" src= "https://github.com/overnew/Cloud-SIEM-Infra-Terraform/assets/43613584/9433fa69-20c9-49dd-aea4-1732ba7e0d9b">


<br>
<br>

## 구현물 확인

- [아키텍처 설명 자료 및 시연 영상 링크](https://www.canva.com/design/DAGIviOXHcM/owQlW-IY6UvKjoSwvsYQZA/view?utm_content=DAGIviOXHcM&utm_campaign=designshare&utm_medium=link&utm_source=editor)
  <br>
  <br>

- 밀리프레소 웹 서비스

<img width="80%" src= "https://github.com/overnew/Cloud-SIEM-Infra-Terraform/assets/43613584/35a1d72b-1275-4f30-8b9c-a8d335f51933">

  <br>
  
  <img width="80%" src= "https://github.com/overnew/Cloud-SIEM-Infra-Terraform/assets/43613584/08340d0f-19fd-4fdf-b4a1-63c160266781">


<br>
<br>


- Code Pipeline CI/CD

<img width="80%" src= "https://github.com/overnew/Cloud-SIEM-Infra-Terraform/assets/43613584/c90ffdd6-0cc4-47b2-a15c-4f600e8404c0">

  <br>
<img width="80%" src= "https://github.com/overnew/Cloud-SIEM-Infra-Terraform/assets/43613584/592ba32a-c2da-41b3-9953-1d560ebe97f1">


<br>
<br>


- 모니터링 (AWS Prometheus, AWS Grafana)

<img width="80%" src= "https://github.com/overnew/Cloud-SIEM-Infra-Terraform/assets/43613584/afc873e5-f79b-4307-8be4-4541e6f0e5b6">

  <br>
<img width="80%" src= "https://github.com/overnew/Cloud-SIEM-Infra-Terraform/assets/43613584/9e5cf976-0247-4de6-a0a8-7cea1f000fd4">



<br>
<br>

- 비실시간 SIEM (Open search)

<img width="80%" src= "https://github.com/overnew/Cloud-SIEM-Infra-Terraform/assets/43613584/583f50cd-2276-46cb-8cea-7c5fd6f17e38">

  <br>
<img width="80%" src= "https://github.com/overnew/Cloud-SIEM-Infra-Terraform/assets/43613584/cc8c0ff3-81bf-4343-8cc3-25485ab1a272">
