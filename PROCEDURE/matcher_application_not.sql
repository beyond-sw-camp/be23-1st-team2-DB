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