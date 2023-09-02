# Terraform으로 AWS Client VPN 구성

## 목표

Terraform으로 Client VPN Endpoint 구성 및 Private subnet 내 인스턴스들과 통신 확인

## 구상도

![AWS_Client_VPC 구상도](https://github.com/ddinggu/blog-comments/assets/37839700/b08ad1ad-b591-41d7-9dd1-607ec0208eff)

## 준비사항 및 버전

1. AWS Client VPN 프로그램 설치: https://aws.amazon.com/ko/vpn/client-vpn-download/
2. AWS CLI: 2.11.2(profile이 ap-northeast-2에 있는지 확인)
3. git 설치 여부 확인
4. Terraform: 1.4.2
5. Terraform AWS Provider: 5.14.0

### terraform.tfvars 생성

Private subnet의 인스턴스에 접근하기 위한 AWS에 등록된 key명을 변수로 등록

```
# terraform.tfvars

key_pair_id = "free_tier_instance_key"
```

## 실행방법

1. 상호인증을 위한 클라이언트와 서버 인증서, 키를 만든 후 AWS ACM에 해당 인증서를 등록하는 스크립트 실행 `sh ./import_cert.sh`
2. 서버와 클라이언트 인증서 등록여부 확인 `aws acm list-certificates --query "CertificateSummaryList[*].DomainName" --output yaml`을 실행하여 도메인명에 'server'와 'client1.domain.tld'이 있는지 확인
3. `terraform apply`로 서비스들 프로비저닝
4. 클라이언트 접속 구성파일 다운
   ![vpn_configfile_down](https://github.com/ddinggu/blog-comments/assets/37839700/24685d2b-a792-43d3-b525-3f5c0827157f)
5. 구성파일 수정
   ![opvn_settings](https://github.com/ddinggu/blog-comments/assets/37839700/86d5756d-3857-4bb0-9fb3-b5c3b1562161)

- Client VPN 엔드포인트 DNS를 찾아 임의의 문자열을 앞에 추가하여 `<random_string>.cvpn-endpoint-...` 형식이 되도록 수정
- 6번째 줄뒤에 클라이언트 인증서서와 키 데이터 경로 추가
  `--cert "<프로젝트 절대경로>/vpn-ca/certificates/client1.domain.tld.crt"`
  `--key "<프로젝트 절대경로>/vpn-ca/certificates/client1.domain.tld.key"`

6. AWS Client VPN 프로그램에 5번 구성파일 추가 후 연결
   ![aws_vpn_profile_settings](https://github.com/ddinggu/blog-comments/assets/37839700/68e08171-2bdc-4930-aed5-243cfb8d4f23)
7. ssh로 각 인스턴스에 접속하여 확인, 인터넷 접속 가능 여부 확인
8. Clean up: `sh ./cleanup.sh` 실행 및 AWS 콘솔에서 ACM에 등록한 인증서 제거

## Client VPN에 대한 설명

[개인 블로그 글](https://ddinggu-blog.vercel.app/aws-client-vpn-%EA%B5%AC%EC%B6%95%ED%95%B4%EB%B3%B4%EA%B8%B0) 참고
