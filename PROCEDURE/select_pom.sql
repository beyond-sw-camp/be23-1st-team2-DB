DELIMITER //

CREATE PROCEDURE POM선정(
    IN p_matchesID BIGINT
)
BEGIN
    DECLARE v_pom_member BIGINT DEFAULT NULL;

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

    UPDATE matches
    SET POM = v_pom_member
    WHERE ID = p_matchesID;

    SELECT
        p_matchesID AS match_id,
        v_pom_member AS selected_pom_member,
        'POM 선정 완료' AS message;

END //

DELIMITER ;
