DELIMITER //

CREATE PROCEDURE 환불상태변경(
    IN p_matches_id BIGINT
)
BEGIN
    DECLARE v_status VARCHAR(20);

    -- 경기 상태 가져오기
    SELECT status INTO v_status
    FROM matches
    WHERE id = p_matches_id;

    -- 경기 상태가 '취소'일 때만 실행
    IF v_status = '취소' THEN
        -- 결제 내역 있는 신청만 환불 처리
        UPDATE match_apply
        SET refund_time = NOW(),
            status = '환불'
        WHERE matchesID = p_matches_id
          AND payment_time IS NOT NULL;
    END IF;

END //

DELIMITER ;
