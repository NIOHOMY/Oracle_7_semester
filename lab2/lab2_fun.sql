SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION get_total_marks_by_surname (
    p_surname IN CHAR,
    p_subj_name IN CHAR
) RETURN SYS_REFCURSOR
IS
    student_cursor SYS_REFCURSOR;
BEGIN
    OPEN student_cursor FOR
        SELECT e.STUD_ID, 
               NVL(SUM(e.MARK), 0) AS TOTAL_MARKS
        FROM STUDENT s
        JOIN EXAMS e ON s.STUD_ID = e.STUD_ID
        JOIN SUBJECT subj ON e.SUBJ_ID = subj.SUBJ_ID
        WHERE s.SURNAME = p_surname
          AND subj.SUBJ_NAME = p_subj_name
        GROUP BY e.STUD_ID;
    
    RETURN student_cursor;
END;
/
