


 
<img width="500" height="500" alt="Image" src="https://github.com/user-attachments/assets/f6565b6e-46e6-4ad0-869c-75ccf3e85520" />
 

  ⚽ 풋살 매칭 DB 프로젝트 – MatchBall

**팀명: FutFut**

**팀원**
황건하, 이수림, 박준형, 정민정

## 스택
<p>
<img src="https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white">  
<img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white">  
<img src="https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white">  
<img src="https://img.shields.io/badge/VS%20Code-007ACC?style=for-the-badge&logo=visual-studio-code&logoColor=white">  
<img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white">




</p>


### 💡 프로젝트 개요

![Image](https://github.com/user-attachments/assets/b6a3194e-fd45-4485-a676-d93afa98ec1c)

복잡한 풋살 경기 매칭 + 예약 + 정산 + 히스토리 관리를 DB 중심으로 처리할 수 있도록 설계된 플랫폼입니다.  

사용자(회원)는 팀 없이도 경기에 신청/참여할 수 있고,  심판은 경기를 생성할 수 있습니다.  
데이터베이스 + SQL + 자동화 로직 기반으로,  
풋살을 즐기는 개개인의 회원과 심판들에게 편리한 경기 참여 서비스를 제공합니다.


### ✨ 주요 기능

1. 회원: 경기 신청, 결제, 취소/환불, POM 투표  
2. 심판/매칭: 구장 선택 및 경기 생성, 신청 인원 체크 → 매칭 또는 환불  
3. 결제 / 환불 / 정산  
4. 조회 / 내역 조회 기능 (경기 목록, 신청 내역, 결제/환불 내역, 구장 상세, 히스토리)  

---

## 🗓️ WBS


<img width="1313" height="1036" alt="image" src="https://github.com/user-attachments/assets/8f70fd2c-0489-4166-8c07-a08b0b641d72" />

https://docs.google.com/spreadsheets/d/1fIUSy4qkfBQxXwY54RJ-XUnWjjOReSNoq1BAZvF45AA/edit?gid=827308645#gid=827308645


---
## 📝 요구사항정의서


<img width="1228" height="826" alt="image" src="https://github.com/user-attachments/assets/a58998d2-f7b6-49f0-b071-3bc3c063ff95" />

https://docs.google.com/spreadsheets/d/1JPzOK-3ZNih2dvhaKj_woaxKXlj8aVoJJ0jWgI7P8M4/edit?gid=683578131#gid=683578131

---

## 🔎 4. DB 모델링
<img width="2010" height="1272" alt="Image" src="https://github.com/user-attachments/assets/e932899f-fdaf-42c5-84eb-a7739271be12" />
https://www.erdcloud.com/d/xgt9LzrHYkuyy4dbG

---

## 5. SQL

### 5-1. DDL (데이터 정의어)

<details>
  <summary>1. 사용자(심판, 회원)</summary>

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
  <summary>2. 심판</summary>

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
  <summary>3. 회원</summary>

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
  <summary>4. 구장</summary>

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

</div>
</details>

<hr/>

#### 주요 기능 프로시저

<details>
<summary><b>회원</b></summary>

```sql
// 회원 등록

DROP PROCEDURE IF EXISTS 회원등록;
DELIMITER //
create
    definer = root@localhost procedure 회원등록(IN p_name varchar(255), IN p_email varchar(255), IN p_login_id varchar(255),
                                            IN p_password varchar(255), IN p_phone varchar(255),
                                            IN p_account varchar(255))
BEGIN
    START TRANSACTION;

    INSERT INTO user (
        name,
        email,
        login_id,
        password,
        phone_number,
        status
    ) VALUES (
                 p_name,
                 p_email,
                 p_login_id,
                 p_password,
                 p_phone,
                 'n'
             );

    INSERT INTO member (
        userID,
        account,
        pomCount
    ) VALUES (
                 LAST_INSERT_ID(),
                 p_account,
                 0
             );

    COMMIT;
END;

DELIMITER ;

```
</details>

</div>
</details>

<details>
<summary><b>심판</b></summary>

```sql
// 심판 등록


DROP PROCEDURE IF EXISTS 심판등록;
DELIMITER //
create
    definer = root@localhost procedure 심판등록(IN p_name varchar(255), IN p_email varchar(255), IN p_login_id varchar(255),
                                            IN p_password varchar(255), IN p_phone varchar(255),
                                            IN p_certificate varchar(255), IN p_pay_account varchar(255),
                                            IN p_fee_rate int)
BEGIN
    START TRANSACTION;

    INSERT INTO user (
        name,
        email,
        login_id,
        password,
        phone_number,
        status
    ) VALUES (
                 p_name,
                 p_email,
                 p_login_id,
                 p_password,
                 p_phone,
                 'n'
             );

    INSERT INTO referee (
        userID,
        certificate,
        pay_account,
        fee_rate
    ) VALUES (
                 LAST_INSERT_ID(),
                 p_certificate,
                 p_pay_account,
                 p_fee_rate
             );

    COMMIT;
END;

DELIMITER ;

```

```sql
// 경기 open


DROP PROCEDURE IF EXISTS 경기오픈;

DELIMITER //
create
    definer = root@localhost procedure 경기오픈(IN p_referee_id bigint, IN p_stadium_id bigint, IN p_match_price int,
                                            IN p_date date, IN p_time time, IN p_member_count int,
                                            IN p_pom varchar(255))
BEGIN
    DECLARE v_count INT DEFAULT 0;

    -- 심판 존재 확인
    SELECT COUNT(*) INTO v_count
    FROM referee
    WHERE id = p_referee_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '존재하지 않는 심판입니다.';
    END IF;

    -- 구장 존재 확인
    SELECT COUNT(*) INTO v_count
    FROM stadium
    WHERE id = p_stadium_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '존재하지 않는 구장입니다.';
    END IF;

    -- 같은 날짜·시간대 중복 경기 확인
    SELECT COUNT(*) INTO v_count
    FROM matches
    WHERE refereeID = p_referee_id
      AND date = p_date
      AND time = p_time;

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '해당 심판은 이미 같은 시간대 경기가 존재합니다.';
    END IF;

    -- 신규 경기 생성
    INSERT INTO matches(
        stadiumID, refereeID, match_price,
        date, time, member_count, POM, status
    ) VALUES (
                 p_stadium_id, p_referee_id, p_match_price,
                 p_date, p_time, p_member_count, p_pom, '열림'
             );

    -- 생성된 match ID 반환
    SELECT LAST_INSERT_ID() AS match_id;

END;

DELIMITER ;

```

```sql
// 심판급여 정산

DELIMITER //

CREATE PROCEDURE 심판정산입력(IN rID BIGINT)
BEGIN
    DECLARE fee INT;
    DECLARE calcPayment INT;

    -- 심판 수수료율 조회
    SELECT fee_rate INTO fee
    FROM referee
    WHERE ID = rID;

    -- 고정금액 20000원에서 수수료 계산
    -- 수수료만큼 제외: payment = 20000 * (100 - fee_rate) / 100
    SET calcPayment = ROUND(20000 * (100 - fee) / 100);

    -- 정산 테이블에 저장
    INSERT INTO referee_payment (refereeID, paymentDate, payment)
    VALUES (rID, CURRENT_TIMESTAMP, calcPayment);
END //

DELIMITER ;

```
</details>

</div>
</details>


<details>
<summary><b>구장</b></summary>

```sql
// 구장등록


DROP PROCEDURE IF EXISTS 구장등록;
DELIMITER //

CREATE PROCEDURE 구장등록(
    IN p_name VARCHAR(255),
    IN p_location VARCHAR(255),
    IN p_condition TEXT,
    IN p_max_count INT
)
BEGIN
    DECLARE v_count INT DEFAULT 0;

    -- 중복 구장명 확인
    SELECT COUNT(*) INTO v_count
    FROM stadium
    WHERE name = p_name;

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '이미 존재하는 구장 이름입니다.';
    END IF;

    -- 신규 구장 생성
    INSERT INTO stadium(name, location, condition_text, max_count)
    VALUES (p_name, p_location, p_condition, p_max_count);

    -- 생성된 stadium ID 반환
    SELECT LAST_INSERT_ID() AS stadium_id;

END //

DELIMITER ;

```

```sql
//구장 옵션 생성

DELIMITER //

CREATE PROCEDURE CreateStadiumOption (
    IN p_stadiumID BIGINT,
    IN p_optionID BIGINT
)
BEGIN
    -- 이미 존재하는지 확인
    IF EXISTS (
        SELECT 1
        FROM stadium_detail_option
        WHERE stadiumID = p_stadiumID
          AND optionID = p_optionID
    ) THEN
        SELECT '이미 등록된 옵션입니다.' AS result;

    ELSE
        -- 신규 등록
        INSERT INTO stadium_detail_option (stadiumID, optionID)
        VALUES (p_stadiumID, p_optionID);

        SELECT '구장 옵션이 성공적으로 등록되었습니다.' AS result;
    END IF;
END 

// DELIMITER ;

```
</details>

</div>
</details>


<details>
<summary><b>경기</b></summary>

```sql
// 경기신청

DELIMITER //

CREATE PROCEDURE 경기신청(
    IN p_member_id BIGINT,
    IN p_matches_id BIGINT
)
BEGIN
    DECLARE v_current_count INT DEFAULT 0;
    DECLARE v_max_count INT DEFAULT 0;
    DECLARE v_match_price INT;

    -- 경기 존재 여부 확인 및 최대 인원, 가격 가져오기
    SELECT max_count, match_price
    INTO v_max_count, v_match_price
    FROM matches
    WHERE id = p_matches_id;

    IF v_max_count IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '존재하지 않는 경기입니다.';
    END IF;

    -- 이미 신청했는지 확인
    SELECT COUNT(*) INTO v_current_count
    FROM match_apply
    WHERE matchesID = p_matches_id
      AND memberID = p_member_id
      AND refund_time IS NULL;

    IF v_current_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '이미 신청한 경기입니다.';
    END IF;

    -- 현재 신청 인원 확인
    SELECT COUNT(*) INTO v_current_count
    FROM match_apply
    WHERE matchesID = p_matches_id
      AND refund_time IS NULL;

    -- 최대 인원 체크
    IF v_current_count >= v_max_count THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '이미 최대 인원으로 신청이 불가능합니다.';
    END IF;

    -- 신청 진행
    INSERT INTO match_apply(matchesID, memberID, apply_price, status)
    VALUES(p_matches_id, p_member_id, v_match_price, '신청');

    SELECT '신청 완료' AS result;

END //

DELIMITER ;

```

```sql
// 경기신청 불가


DELIMITER //

CREATE PROCEDURE 경기신청불가(
    IN p_member_id BIGINT,
    IN p_matches_id BIGINT
)
BEGIN
    DECLARE v_current_count INT DEFAULT 0;
    DECLARE v_max_count INT DEFAULT 0;

    -- 경기 존재 여부 확인 및 최대 인원 가져오기
    SELECT max_count
    INTO v_max_count
    FROM matches
    WHERE id = p_matches_id;

    IF v_max_count IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '존재하지 않는 경기입니다.';
    END IF;

    -- 현재 신청 인원 확인 (환불된 인원 제외)
    SELECT COUNT(*) INTO v_current_count
    FROM match_apply
    WHERE matchesID = p_matches_id
      AND refund_time IS NULL;

    -- 최대 인원 초과 시 신청 불가
    IF v_current_count >= v_max_count THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '이미 최대 인원으로 신청이 불가능합니다.';
    END IF;

    SELECT '신청 가능' AS result;

END //

DELIMITER ;
```
</details>

</div>
</details>

<details>
<summary><b>매칭</b></summary>
	
```sql
// 매치 성공, 실패 시나리오

DELIMITER //

CREATE PROCEDURE 매치시나리오(
    IN p_match_id BIGINT
)
BEGIN
    DECLARE v_apply_count INT DEFAULT 0;
    DECLARE v_match_datetime DATETIME;
    DECLARE v_current DATETIME;

    -- 현재 시간
    SET v_current = NOW();

    -- 경기 날짜 + 시간 합쳐서 DATETIME 생성
    SELECT TIMESTAMP(`date`, `time`)
    INTO v_match_datetime
    FROM matches
    WHERE id = p_match_id;

    -- 경기 존재 여부 확인
    IF v_match_datetime IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '존재하지 않는 경기입니다.';
    END IF;

    -- 1시간 전 체크
    IF v_match_datetime <= DATE_ADD(v_current, INTERVAL 1 HOUR) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '이미 경기 시작 1시간 전이 지났습니다.';
    END IF;

    -- match_apply 테이블에서 신청 인원 수 확인
    SELECT COUNT(*) INTO v_apply_count
    FROM match_apply
    WHERE matchesID = p_match_id;

    -- 최소 인원 10명 이상 → 매칭 성공
    IF v_apply_count >= 10 THEN

        -- 상태 업데이트
        UPDATE matches
        SET status = '승인'
        WHERE id = p_match_id
          AND status = '대기';

        SELECT '성공' AS result, v_apply_count AS applied_people;

    ELSE
        -- 매칭 실패 처리
        UPDATE matches
        SET status = '취소'
        WHERE id = p_match_id
          AND status = '대기';

        -- 환불 처리 (결제한 사람만)
        UPDATE match_apply
        SET refund_time = NOW()
        WHERE matchesID = p_match_id
          AND payment_time IS NOT NULL;

        SELECT '매칭 실패 - 환불 완료' AS result, v_apply_count AS applied_people;
    END IF;

END //

DELIMITER ;



```
</details>

</div>
</details>

<details>
<summary><b>pom 선정 기능 </b></summary>
	
```sql

// 경기 종료 후 모든 플레이어 투표 진행

DELIMITER //

create
    definer = root@localhost procedure POM투표(IN p_applyID bigint, IN p_voterID bigint, IN p_votedID bigint)
BEGIN

    INSERT INTO pom_vote (applyID, voter_memberID, voted_memberID)
    VALUES (p_applyID, p_voterID, p_votedID);

END;

DELIMITER ;


// 경기 종료 후 해당 경기 pom 선정

DELIMITER //

CREATE PROCEDURE SelectPOM(
    IN p_matchesID BIGINT
)
BEGIN
    DECLARE v_pom_member BIGINT DEFAULT NULL;

    /*
        1) POM 최다득표자 조회
           - NULL 투표 제외
    */
    SELECT voted_memberID
    INTO v_pom_member
    FROM pom_vote
    WHERE applyID IN (
        SELECT ID
        FROM match_apply
        WHERE matchesID = p_matchesID
    )
    AND voted_memberID IS NOT NULL
    GROUP BY voted_memberID
    ORDER BY COUNT(*) DESC
    LIMIT 1;


    /*
        2) matches 테이블에 POM 업데이트
    */
    UPDATE matches
    SET POM = v_pom_member
    WHERE ID = p_matchesID;


    /*
        3) POM 카운트 증가 (NULL 이 아닌 경우만)
    */
    IF v_pom_member IS NOT NULL THEN
        UPDATE member
        SET pomCount = pomCount + 1
        WHERE ID = v_pom_member;
    END IF;


    /*
        4) 결과 출력
    */
    SELECT 
        p_matchesID AS match_id,
        v_pom_member AS selected_pom_member,
        'POM 선정 및 pomCount 업데이트 완료' AS message;

END //

DELIMITER ;



```
</details>

</div>
</details>


<details>
<summary><b>결제</b></summary>
	
```sql
// 경기 선택 후 결제 진행

DELIMITER //

create
    definer = root@localhost procedure 매칭신청(IN p_memberID bigint, IN p_matchID bigint, IN p_price int)
BEGIN
    DECLARE v_max_count INT DEFAULT 0;
    DECLARE v_current_count INT DEFAULT 0;

    -- 1) 경기 정원(max_count) 조회
    SELECT s.max_count
      INTO v_max_count
    FROM matches m
    JOIN stadium s ON s.ID = m.stadiumID
    WHERE m.ID = p_matchID;

    -- 2) 현재 해당 경기 신청 인원 조회
    SELECT COUNT(*)
      INTO v_current_count
    FROM match_apply
    WHERE matchesID = p_matchID;

    -- 3) 정원 체크 후 신청 INSERT
    IF v_current_count < v_max_count THEN
        INSERT INTO match_apply (
            memberID,
            matchesID,
            apply_price,
            payment_time
        )
        VALUES (
            p_memberID,
            p_matchID,
            p_price,
            NOW()
        );
    ELSE
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '정원이 가득 찼습니다.';
    END IF;

END;


//
DELIMITER ;

// 경기 신청 후 결제 취소

DELIMITER //

CREATE
    DEFINER = `root`@`localhost` PROCEDURE 매칭신청취소(
        IN p_applyID BIGINT,
        IN p_memberID BIGINT
    )
BEGIN
    DECLARE v_matchID BIGINT;
    DECLARE v_match_datetime DATETIME;
    DECLARE v_now DATETIME;

    SET v_now = NOW();

    -- 신청 내역 확인
    SELECT matchesID
      INTO v_matchID
    FROM match_apply
    WHERE ID = p_applyID
      AND memberID = p_memberID
      AND refund_time IS NULL;

    IF v_matchID IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '신청 내역이 없거나 이미 취소된 내역입니다.';
    END IF;

    -- 경기 시간 확인
    SELECT TIMESTAMP(m.date, m.time)
      INTO v_match_datetime
    FROM matches m
    WHERE m.ID = v_matchID;

    -- 경기 1시간 전 이후 취소 불가
    IF v_now >= DATE_SUB(v_match_datetime, INTERVAL 1 HOUR) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '경기 시작 1시간 전 이후에는 취소할 수 없습니다.';
    END IF;

    -- 신청 취소 / 환불 처리
    UPDATE match_apply
       SET refund_time = v_now,
           status = '환불'
     WHERE ID = p_applyID;

    -- matches 테이블 인원 감소
    UPDATE matches
       SET member_count = member_count - 1
     WHERE ID = v_matchID
       AND member_count > 0;

END;

//
DELIMITER ;

```
</details>

</div>
</details>


<details>
<summary><b>환불</b></summary>
	
```sql

// 매칭 실패로 인한 환불

DELIMITER //

CREATE PROCEDURE 환불상태변경(
    IN p_matches_id BIGINT
)
BEGIN
    DECLARE v_status VARCHAR(20);

    -- 경기 상태 가져오기
    SELECT status INTO v_status
    FROM matches
    WHERE id = p_matches_id;

    -- 경기 상태가 '취소'일 때만 실행
    IF v_status = '취소' THEN
        -- 결제 내역 있는 신청만 환불 처리
        UPDATE match_apply
        SET refund_time = NOW(),
            status = '환불'
        WHERE matchesID = p_matches_id
          AND payment_time IS NOT NULL;
    END IF;

END //

DELIMITER ;




```
</details>

## 6. 소감


### 박준형
첫 프로젝트라서 모든 게 서툴렀고, 딜레이 될 거라 예상하지 못했던
ERD 설계에서 큰 어려움을 겪었습니다.
그래도 팀원 모두 할 수 있다고 말하며 열정적인 대화 덕분에
무사히 마무리할 수 있었습니다!

### 이수림
ERD설계에서 대부분 시간을 쓰게되면서 다른부분에 신경쓰지 못한 것이 아쉽습니다. 전반적인 것 보다는 일부분에 집중했던 것 같습니다. 
참여 과정동안 요구사항과 wbs로 돌아가면서 해당 시스템의 중요성을 알았습니다.
ERD때 최대한 배운 것을 활용하려 했고, 그 과정에서 개념이 다시 정립된 부분이 있었습니다. 협력하고 도움 받으며 마무리 한 것 같습니다.


### 황건하
시간이 많을 줄 알았는데 일정을 제대로 관리하지 못한부분이 아쉽습니다.
WBS와 요구사항 명세서를 부실하게 작성해 ERD 설계를 하면서 돌아가는 일이 많이 시간이 부족했던 것 같습니다.
그래도 대화하며 ERD설계를 완성하고 원하는 기능들을 구현하면서 많이 배울 수 있었습니다.

### 정민정
README가 프로젝트의 ‘첫인상’이라는 부담감 때문에 내용 구성과 흐름을 어떻게 잡을지 고민이 많았습니다.
설치 방법 / 사용법 / 기능 설명 / 기술 스택 / 프로젝트 소개 등을 Markdown 형식으로 깔끔하게 정리하는 게 생각보다 어렵고 번거로웠습니다.

</div>
</details>

