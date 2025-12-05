DROP PROCEDURE IF EXISTS 심판등록;
DELIMITER //
create
    definer = root@localhost procedure 심판등록(IN p_name varchar(255), IN p_email varchar(255), IN p_login_id varchar(255),
                                            IN p_password varchar(255), IN p_phone varchar(255),
                                            IN p_certificate varchar(255), IN p_pay_account varchar(255),
                                            IN p_fee_rate int)
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

    INSERT INTO referee (
        userID,
        certificate,
        pay_account,
        fee_rate
    ) VALUES (
                 LAST_INSERT_ID(),
                 p_certificate,
                 p_pay_account,
                 p_fee_rate
             );

    COMMIT;
END;

DELIMITER ;