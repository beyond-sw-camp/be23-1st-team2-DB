#### 주요 기능 프로시저

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
        SET status = '매칭 승인'
        WHERE id = p_match_id
          AND status = '대기';

        SELECT '매칭 성공' AS result, v_apply_count AS applied_people;

    ELSE
        -- 매칭 실패 처리
        UPDATE matches
        SET status = '매칭 실패'
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

</div>
</details>