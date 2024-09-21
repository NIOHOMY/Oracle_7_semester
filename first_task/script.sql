SET SERVEROUTPUT ON;

DECLARE 
  ARG1 subj_lect.lecturer_id%TYPE;
  ARG2 subj_lect.subj_id%TYPE;
  CURSOR cur1 IS SELECT * FROM subj_lect;
  special_case EXCEPTION;
BEGIN
  OPEN cur1;
  FETCH cur1 INTO arg1, arg2;
  WHILE cur1%FOUND LOOP
    dbms_output.put_line(cur1%ROWCOUNT||' '||arg1||arg2);
  IF arg1 >= 100
    THEN RAISE special_case;
  END IF;
  FETCH cur1 INTO arg1, arg2;
  END LOOP;

EXCEPTION
  WHEN special_case THEN dbms_output.put_line('исключение системы');
  WHEN OTHERS THEN dbms_output.put_line('ошибка приложения');
END;
/
