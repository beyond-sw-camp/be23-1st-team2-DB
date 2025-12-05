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
