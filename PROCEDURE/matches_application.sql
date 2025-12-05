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