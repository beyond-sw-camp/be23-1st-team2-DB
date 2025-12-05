## 🔎 4. DB 모델링
![DB_AI_FIXED (2)](https://github.com/user-attachments/assets/2a365604-e41c-4d87-adbb-b24c9698123e)
https://www.erdcloud.com/d/xgt9LzrHYkuyy4dbG

---

## 5. SQL

### 5-1. DDL (데이터 정의어)

<details>
  <summary>-- 1. 사용자(심판, 회원)</summary>

사용자 테이블은 심판과 회원 테이블의 부모테이블로 로그인을 하기 위한 정보들을 가지고 있습니다.
회원은 축구 매칭 서비스를 이용하는 회원입니다.
심판은 축구 매칭을 만들고 심판으로 참여합니다.

- user: 로그인을 위한 정보들을 가지고 있습니다.
- member: 계좌번호와 pom 선정된 횟수 데이터를 가지고 있습니다.
- referee: 심판 자격증, 수수료, 계좌번호를 가지고 있습니다. 

```sql
    CREATE TABLE user (
    ID bigint NOT NULL AUTO_INCREMENT,
    name varchar(255) NOT NULL,
    email varchar(255) NOT NULL UNIQUE,
    login_id varchar(255) NOT NULL UNIQUE,
    password varchar(255) NOT NULL,
    phone_number varchar(255) NOT NULL,
    status ENUM('Y', 'N') NOT NULL DEFAULT 'N',
    PRIMARY KEY (ID)
) COMMENT='사용자';
```

```sql
CREATE TABLE member (
    ID bigint NOT NULL AUTO_INCREMENT,
    userID bigint NOT NULL,
    account varchar(255) NOT NULL,
    pomCount int NOT NULL DEFAULT 0,
    PRIMARY KEY (ID),
    FOREIGN KEY (userID) REFERENCES user (ID)
) COMMENT='회원';
```

```sql
CREATE TABLE referee (
    ID bigint NOT NULL AUTO_INCREMENT,
    userID bigint NOT NULL,
    certificate varchar(255) NOT NULL ,
    pay_account varchar(255) NOT NULL,
    fee_rate int NOT NULL DEFAULT 3,
    PRIMARY KEY (ID),
    FOREIGN KEY (userID) REFERENCES user (ID)
) COMMENT='심판';
```
</details>

<details>
  <summary>-- 2. 심판</summary>

심판은 구장과 시간을 정해서 경기를 주선합니다.
경기가 성사된 후에는 정산금을 받습니다.

- referee_payment: 심판 정산 금액을 조회하기 위한 테이블입니다.
- match: 심판에 의해 구장과 시간대가 선택되어 경기가 열립니다.
'계획', '열림', '닫힘', '취소' 상태로 변할 수 있고,
처음은 '계획'상태입니다.

```sql
    CREATE TABLE referee_payment (
    ID bigint NOT NULL AUTO_INCREMENT,
    refereeID bigint NOT NULL,
    paymentDate datetime NOT NULL ,
    payment int NOT NULL,
    PRIMARY KEY (ID),
    FOREIGN KEY (refereeID) REFERENCES referee (ID)
) COMMENT='심판 정산 내역';
```

```sql
CREATE TABLE matches (
    ID bigint NOT NULL AUTO_INCREMENT,
    stadiumID bigint NOT NULL,
    refereeID bigint NOT NULL,
    match_price int NOT NULL,
    date date NOT NULL,
    time time NOT NULL,
    member_count int NOT NULL,
    POM varchar(255),
    status ENUM('계획', '열림', '닫힘', '취소') NOT NULL DEFAULT '계획',
    PRIMARY KEY (ID),
    FOREIGN KEY (stadiumID) REFERENCES stadium (ID),
    FOREIGN KEY (refereeID) REFERENCES referee (ID)
) COMMENT='경기';
```

</details>

<details>
  <summary>-- 3. 회원</summary>

회원은 계획된 경기에 신청하며, 결제를 하고, 경기가 성사되면 해당 경기의 pom을 선정합니다. 만약 인원이 모이지 않아 경기가 취소될 경우 환불을 받습니다.

- match_apply: 회원과 참여하는 경기가 기록되고, '승인', '대기', '환불' 상태로 변할 수 있습니다. 신청을 하면 결제가 이루어지며, 결제 날짜가 기록되고, '대기'상태가 됩니다. 최소인원을 충족하면 '승인'상태로 변경되고 인원이 모이지 않으면 '환불'상태가 됩니다. 
- pom_vote: 경기가 끝난 후 각 회원이 pom을 투표한 기록이 저장됩니다.

```sql
CREATE TABLE match_apply (
    ID bigint NOT NULL AUTO_INCREMENT,
    memberID bigint NOT NULL,
    matchesID bigint NOT NULL,
    status ENUM('승인', '대기', '환불') NOT NULL DEFAULT '대기',
    apply_price int NOT NULL DEFAULT 10000,
    payment_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    refund_time datetime NULL,

    PRIMARY KEY (ID),
    FOREIGN KEY (memberID) REFERENCES member (ID),
    FOREIGN KEY (matchesID) REFERENCES matches (ID)
) COMMENT='경기 신청';
```

```sql
CREATE TABLE pom_vote (
    ID bigint NOT NULL AUTO_INCREMENT,
    applyID bigint NOT NULL,
    voter_memberID bigint NOT NULL,
    voted_memberID bigint NULL,

    PRIMARY KEY (ID),
    FOREIGN KEY (applyID) REFERENCES match_apply (ID),
    FOREIGN KEY (voter_memberID) REFERENCES member (ID),
    FOREIGN KEY (voted_memberID) REFERENCES member (ID)
) COMMENT='투표';
```

</details>

<details>
  <summary>-- 4. 구장</summary>

구장은 구장, 구장 옵션, 구장 옵션별 상세 테이블이 존재합니다.
구장이 옵션을 동적으로 추가할 수 있도록 설계하여, 각 구장마다 다양한 옵션이 존재할 수 있습니다.

- stadium: 구장의 이름, 위치, 최대 수용인원, 구장의 상테메시지가 저장됩니다.
- stadium_option: 샤워실, 흡연실, 유료주차 등의 옵션명을 추가할 수 있습니다.
- stadium_detail_option: 구장과 구장 옵션을 가져와서, 각 구장의 옵션들을 확인할 수 있습니다.

```sql
CREATE TABLE stadium (
    ID bigint NOT NULL AUTO_INCREMENT,
    name varchar(255) NOT NULL,
    condition_text text,
    location varchar(255),
    max_count int NOT NULL,
    PRIMARY KEY (ID)
) COMMENT='구장';
```

```sql
CREATE TABLE stadium_option (
    ID bigint NOT NULL AUTO_INCREMENT,
    name varchar(255) NOT NULL,
    PRIMARY KEY (ID)
) COMMENT='구장 옵션';
```

```sql
CREATE TABLE stadium_detail_option (
    ID bigint NOT NULL AUTO_INCREMENT,
    stadiumID bigint NOT NULL,
    optionID bigint NOT NULL,

    PRIMARY KEY (ID),
    UNIQUE KEY UQ_stadium_option (stadiumID, optionID),
    FOREIGN KEY (stadiumID) REFERENCES stadium (ID),
    FOREIGN KEY (optionID) REFERENCES stadium_option (ID)
) COMMENT='구장 상세';
```

</details>

### 5-2. DML (데이터 조작어)
<details>
<summary>-- 입력순서</summary>
1. user_dummy.sql
2. member_dummy.sql
3. referee_dummy.sql
4. referee_payment_dummy.sql
5. matches_dummy.sql
6. matches_apply_dummy.sql
7. pom_vote_dummy.sql
8. stadium_dummy.sql
9. stadium_option_dummy.sql
10. stadium_detail_option.sql
📁 [DML 파일 바로가기](./SQL)
</details>