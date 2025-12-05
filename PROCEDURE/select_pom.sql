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
