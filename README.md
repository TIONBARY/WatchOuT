![WatchOuT_Logo](/uploads/9ca0336067bf12a4e8ed0110bf61d728/WatchOuT_Logo.png)

# 개요
- **프로젝트 기간** : 2022.10.10 ~ 2022.11.17 (7주)
  - 1인 가구를 위한 치안 앱

- **주요 기능**
  1. SOS기능
     - 사이렌과 함께 등록 된 비상 연락처로 위치 정보를 포함한 문자 자동 발송
  2. 안전 귀가
     - 귀갓길 공유대상에게 실시간으로 본인의 위치 공유, 지도로 위치를 표시
     - 사용자의 귀가 정보를 수신받는 상대방에게 입장 코드를 포함시켜 귀가 시작을 알리는 문자 전송
     - 안전 귀가 지도 상단에 위치한 탭을 눌러 근처에 있는 편의점, 약국, CCTV, 안심벨 등의 위치를 확인
  3. 스마트 워치 연동
     - 실시간으로 심박수를 수신하여 건강 이상 발생 시 비상연락처로 위치 정보를 포함한 응급 문자 발송
     - 스마트 워치에 설치된 Watch OuT 앱에 설치된 응급 상황 버튼을 클릭해 응급 상황 전파
  4. 바로 신고
     - 범죄 현장을 목격 시 사진을 찍으면 사진과 함께 112에 문자 발송
  5. 홈 캠
    - 본인이 등록한 홈 캠의 경우 언제든 어플을 통해 확인 가능
    - 비어있는 집에 괴한이 들어 왔을 때, 감시
    - 상대방으로부터 비상 연락 기능이 활성화되면 입장 코드를 포함한 응급 상황 알림 문자 발송
    - 입장 코드를 입력해 상대방이 등록한 홈 캠에 일시적으로 접속, 응급 상황 인지
    - 일정 시간이 지나면 사생활 보호를 위해 더 이상 상대방의 홈 캠 영상을 확인할 수 없음
  6. 홈 위젯
    - 앱을 키지 않고도 바로 SOS 기능을 이용할 수 있도록 홈 위젯 기능을 구현
    - 바탕화면에 위치시킨 후 클릭하면 SOS 기능이 자동 실행됨

- **부가 기능**
    1. 안심 귀가 서비스
       - 사용자가 등록한 주소지를 기준으로, 지자체가 제공하는 여성 안심 귀갓길을 신청할 수 있는 번호로 자동 연결
    2. Short Cut
       - 앱을 꾹 누를 시 안전 지도 및 응급 상황 메뉴얼 기능으로 접속
    3. 안전 지도
       - Kakao Map API와 공공 데이터를 활용
       - 사용자의 기기에 CCTV, 약국, 병원, 편의점, 안심택배 등 범죄로부터 피신할 수 있는 Safe Zone을 표시하여 제공
    4. 백그라운드 실행
        - 백그라운드에서도 앱이 실행될 수 있게하여, 앱을 켜놓지 않은 상태에서도 비상 상황을 감지하고 도움을 요청
    5. 성범죄자 알림e
        - 검색하고자 하는 지역 근처에 등록된 성범죄자를 확인할 수 있는 사이트로 자동 연동
    6. 가이드
        - 앱에 포함된 기능이 많아 적절한 설명과 사용 방법을 안내
        - 클릭 시 설명 타겟을 제외한 나머지 화면은 blur 처리
        - 설명 타켓의 화면 근처에는 설명문이 제시되고, 다음 버튼 클릭하여 진행
    7. 위기상황 대처 메뉴얼
        - 스토킹, 납치, 유괴, 교통사고, 안전사고 등 여러 범죄 및 사고에 대처할 수 있는 요령 메뉴얼 제공
    8. 범죄 및 건강 안전 교육
        - 메인 화면 상단에 안전 관련 유튜브 영상 카로셀 제공
        - 웹 크롤링을 이용해 데이터를 수신하여 최신 자료로 자동 업데이트
    9. 설정
       - 설정 페이지에서 원하는 기능을 한 번의 클릭으로 on/off
       - 스마트 워치가 감지하는 이상 심박수 기준을 사용자에 맞게 커스터마이징
       - '응급 설정' 버튼 클릭 시 안드로이드가 제공하는 응급 메세지 설정 화면으로 자동 이동 

# 팀원 소개
| 이름   | 역할 | 담당        |
| ------ | ---- | ----------- |
| 김도훈 | 팀장 | `Full-stack` |
| 김시언 | 팀원 | `Full-stack` |
| 김준우 | 팀원 | `Full-stack` |
| 윤지환 | 팀원 | `Full-stack` |
| 최윤정 | 팀원 | `Full-stack` |
| 한준수 | 팀원 | `Full-stack` |

# 기술 스택

### 협업툴
<img src="https://img.shields.io/badge/GitLab-FCA121?style=for-the-badge&logo=GitLab&logoColor=white">
<img src="https://img.shields.io/badge/MatterMost-0058CC?style=for-the-badge&logo=MatterMost&logoColor=white">
<img src="https://img.shields.io/badge/JIRA-0052CC?style=for-the-badge&logo=JIRA&logoColor=white">
<img src="https://img.shields.io/badge/Notion-000000?style=for-the-badge&logo=Notion&logoColor=white">

### Back-end
<img src="https://img.shields.io/badge/Java-007396?style=for-the-badge&logo=Java&logoColor=white">
<img src="https://img.shields.io/badge/SpringBoot-6DB33F?style=for-the-badge&logo=SpringBoot&logoColor=white">
<img src="https://img.shields.io/badge/FIREBASE-ffce2c?style=for-the-badge&logo=FIREBASE&logoColor=white">

### Front-end
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=Flutter&logoColor=white">
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=Dart&logoColor=white">
<img src="https://img.shields.io/badge/Kotlin-7F52FF?style=for-the-badge&logo=Kotlin&logoColor=white">

### 서버
<img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=Docker&logoColor=white">
<img src="https://img.shields.io/badge/nginx-009639?style=for-the-badge&logo=NGINX&logoColor=white">

# [와이어 프레임](https://www.figma.com/file/RYgyub2v7cD5SOX8sbwSho/WatchOut?node-id=0%3A1&t=1omgooS8BxJouK6U-0)
![와이어 프레임](/uploads/0e1c77aeac71ddc1db23f43254493b1c/KakaoTalk_20221116_164041797.png)

# [기능 명세서](https://docs.google.com/spreadsheets/d/1Rmz9WcaGeFQ0PJOm9KE1XvrQsQdp6v0D_ok7_yyYaC4/edit#gid=0)
![기능 명세서](/uploads/2c7638340220f54b8d6a4c0a3f6ac4fe/image.png)

# [API 명세서](https://docs.google.com/spreadsheets/d/1Rmz9WcaGeFQ0PJOm9KE1XvrQsQdp6v0D_ok7_yyYaC4/edit#gid=276985241)
![API 명세서](/uploads/f7218ac86544b6f706c3fc5850d1bae6/image.png)

# 컬러팔레트
<img src="https://img.shields.io/badge/323232-323232?style=for-the-badge&logo=&logoColor=white">
<img src="https://img.shields.io/badge/FFC84B-FFC84B?style=for-the-badge&logo=&logoColor=white">
<img src="https://img.shields.io/badge/0E54AA-0E54AA?style=for-the-badge&logo=&logoColor=white">
<img src="https://img.shields.io/badge/E4804E-E4804E?style=for-the-badge&logo=&logoColor=white">

# JIRA
![JIRA]()

# 기능별 화면

### Gitmoji의 이모지 설명

| Emoji | Code                          | Description              |
| ----- | ----------------------------- | ------------------------ |
| ✨     | `:sparkles:`                  | 새 기능                  |
| ♻️     | `:recycle:`                   | 코드 리팩토링            |
| ⚡️     | `:zap:`                       | 성능 개선                |
| 🔧     | `:wrench:`                    | 리소스 수정/삭제         |
| 🐛     | `:bug:`                       | 버그 수정                |
| 📝     | `:memo:`                      | 문서 추가/수정           |
| 💄     | `:lipstick:`                  | UI/스타일 파일 추가/수정 |
| 🎉     | `:tada:`                      | 프로젝트 시작            |
| ✅     | `:white_check_mark:`          | 테스트 추가/수정         |
| ➕     | `:heavy_plus_sign:`           | package / 의존성 추가    |
| ➖     | `:heavy_minus_sign:`          | package / 의존성 삭제    |
| ⏪     | `:rewind:`                    | 변경 사항 되돌리기       |
| 🔀     | `:twisted_rightwards_arrows:` | 브랜치 합병              |
| 🗃     | `:card_file_box:`             | 데이터베이스 관련 수정   |
| 💡     | `:bulb:`                      | 주석 추가/수정           |
| 🚀     | `:rocket:`                    | 배포                     |



### Commit Convention

- `Feat` : 새로운 기능을 추가할 경우

- `Fix` : 버그를 고친 경우

- `Update` : 코드 수정

- `Style` : 코드 포맷 변경, 세미 콜론 누락, 코드 수정이 없는 경우

- `Refactor` : 프로덕션 코드 리팩토링

- `Docs` : 문서를 수정한 경우

- `Test` : 테스트 추가, 테스트 리팩토링(프로덕션 코드 변경 X)

- `Chore`

   : 빌드 테스트 업데이트, 패키지 매니저를 설정하는 경우

  - `Rename` : 파일 혹은 폴더명을 수정하거나 옮기는 작업만인 경우
  - `Merge` : 일주일에 최소 한번!(꼭 말하고 하기)
  - `Design` : CSS 등 사용자 UI 디자인 변경

```
💡 ex) `:sparkles:` navbar 수정
```



### branch Convention(기능별로 쓰기)

- `master` : 제품 출시될 수 있는 브랜치
- `develop` : 다음 출시 버전 개발하는 브랜치
- `feature` : 기능을 개발하는 브랜치 (기능 별 생성후 병합)
- `hotfix` : 출시 버전에서 버그를 수정하는 브랜치

```
💡 ex) Feat#Jwt_BE : 백엔드의 Jwt 기능 추가
```
