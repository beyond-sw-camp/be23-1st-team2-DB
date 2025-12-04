DROP PROCEDURE IF EXISTS 회원등록;
DELIMITER //
create
    definer = root@localhost procedure 회원등록(IN p_name varchar(255), IN p_email varchar(255), IN p_login_id varchar(255),
                                            IN p_password varchar(255), IN p_phone varchar(255),
                                            IN p_account varchar(255))
BEGIN
    START TRANSACTION;

    INSERT INTO user (
        name,
        email,
        login_id,
        password,
        phone_number,
        status
    ) VALUES (
                 p_name,
                 p_email,
                 p_login_id,
                 p_password,
                 p_phone,
                 'n'
             );

    INSERT INTO member (
        userID,
        account,
        pomCount
    ) VALUES (
                 LAST_INSERT_ID(),
                 p_account,
                 0
             );

    COMMIT;
END;

DELIMITER ;