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