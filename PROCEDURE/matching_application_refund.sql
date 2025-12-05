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