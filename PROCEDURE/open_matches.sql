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