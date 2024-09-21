
SET SERVEROUTPUT ON;

DECLARE
   v_univ_id UNIVERSITY.UNIV_ID%TYPE;
   v_univ_name UNIVERSITY.UNIV_NAME%TYPE;
   v_rating UNIVERSITY.RATING%TYPE;
   v_city UNIVERSITY.CITY%TYPE;

   CURSOR university_cursor IS
      SELECT *
      FROM UNIVERSITY
      WHERE RATING > 400;

   e_voronezh_exception EXCEPTION;

BEGIN
  OPEN university_cursor;

  FETCH university_cursor INTO v_univ_id, v_univ_name, v_rating, v_city;

  WHILE university_cursor%FOUND LOOP
    BEGIN
      IF v_city <> 'ВОРОНЕЖ' THEN
        RAISE e_voronezh_exception;
      END IF;

      FETCH university_cursor INTO v_univ_id, v_univ_name, v_rating, v_city;
    EXCEPTION
      WHEN e_voronezh_exception THEN
        DBMS_OUTPUT.PUT_LINE(
         v_univ_name
         ||' '
         ||v_rating
         ||' '
         ||v_city
      );
        FETCH university_cursor INTO v_univ_id, v_univ_name, v_rating, v_city;
    END;
  END LOOP;
END;
/