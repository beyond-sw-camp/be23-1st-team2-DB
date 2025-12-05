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