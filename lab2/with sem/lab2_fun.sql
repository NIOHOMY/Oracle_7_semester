SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION get_total_marks_by_surname (
    p_surname IN CHAR,
    p_subj_name IN CHAR
) RETURN SYS_REFCURSOR
IS
    v_kurs INTEGER;
    v_sem_start INTEGER;
    v_sem_end INTEGER;
    v_stud_id STUDENT.STUD_ID%TYPE;
    v_total_marks NUMBER;
    student_cursor SYS_REFCURSOR;
BEGIN
    OPEN student_cursor FOR
        SELECT DISTINCT STUD_ID, KURS
        FROM STUDENT
        WHERE SURNAME = p_surname;

    LOOP
        FETCH student_cursor INTO v_stud_id, v_kurs;
        EXIT WHEN student_cursor%NOTFOUND;

        v_sem_start := (v_kurs - 1) * 2 + 1;
        v_sem_end := v_sem_start + 1;

        BEGIN
            SELECT SUM(e.MARK)
            INTO v_total_marks
            FROM EXAMS e
            JOIN SUBJECT s ON e.SUBJ_ID = s.SUBJ_ID
            WHERE e.STUD_ID = v_stud_id
            AND s.SUBJ_NAME = p_subj_name
            AND s.SEMESTR BETWEEN v_sem_start AND v_sem_end;

            IF v_total_marks IS NULL THEN
                v_total_marks := 0;
                RAISE NO_DATA_FOUND;
            END IF;

            DBMS_OUTPUT.PUT_LINE('Student ID: ' || v_stud_id || ', Total Marks: ' || v_total_marks);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Student ID: ' || v_stud_id || ', No marks found.');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Student ID: ' || v_stud_id || ', Error: ' || SQLERRM);
        END;
    END LOOP;

    RETURN student_cursor;
END;
/
