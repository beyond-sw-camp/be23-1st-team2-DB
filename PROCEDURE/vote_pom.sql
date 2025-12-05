DELIMITER //

create
    definer = root@localhost procedure POM투표(IN p_applyID bigint, IN p_voterID bigint, IN p_votedID bigint)
BEGIN

    INSERT INTO pom_vote (applyID, voter_memberID, voted_memberID)
    VALUES (p_applyID, p_voterID, p_votedID);

END;

DELIMITER ;

