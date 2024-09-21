
SET SERVEROUTPUT ON;

DECLARE
   CURSOR university_cursor IS
      SELECT UNIV_ID, UNIV_NAME, RATING, CITY
      FROM UNIVERSITY;

   v_univ_id UNIVERSITY.UNIV_ID%TYPE;
   v_univ_name UNIVERSITY.UNIV_NAME%TYPE;
   v_rating UNIVERSITY.RATING%TYPE;
   v_city UNIVERSITY.CITY%TYPE;
BEGIN
   OPEN university_cursor;

   LOOP
      FETCH university_cursor INTO v_univ_id, v_univ_name, v_rating, v_city;
      EXIT WHEN university_cursor%NOTFOUND;

      DBMS_OUTPUT.PUT_LINE('ID: ' || v_univ_id || ', Name: ' || v_univ_name || ', Rating: ' || v_rating || ', City: ' || v_city);
   END LOOP;

   CLOSE university_cursor;
END;
/
