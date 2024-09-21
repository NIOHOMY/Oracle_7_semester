SET SERVEROUTPUT ON;

DECLARE
   student_marks_cursor SYS_REFCURSOR;
   v_student_id STUDENT.STUD_ID%TYPE;
   v_total_marks NUMBER;
BEGIN
   student_marks_cursor := get_total_marks_by_surname('СОКОЛОВ', 'ДИФ_УРАВНЕНИЯ');

   LOOP
      FETCH student_marks_cursor INTO v_student_id, v_total_marks;
      EXIT WHEN student_marks_cursor%NOTFOUND;

      DBMS_OUTPUT.PUT_LINE('Student ID: ' || v_student_id || ', Total Marks: ' || v_total_marks);
   END LOOP;

   CLOSE student_marks_cursor; 
END;
/
