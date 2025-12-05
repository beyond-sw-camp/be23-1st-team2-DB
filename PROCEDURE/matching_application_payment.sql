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
