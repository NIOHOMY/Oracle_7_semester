SET SERVEROUTPUT ON;

DROP TRIGGER TRG_AVERAGE_MARK;
DELETE FROM EXAMS WHERE EXAM_ID > 100;

CREATE OR REPLACE TRIGGER TRG_AVERAGE_MARK
BEFORE INSERT OR UPDATE ON EXAMS
FOR EACH ROW
DECLARE
  v_old_average_mark NUMBER;
  v_new_average_mark NUMBER;
  v_count NUMBER;
BEGIN
  SELECT AVG(MARK), COUNT(MARK) INTO v_old_average_mark, v_count
  FROM EXAMS
  WHERE STUD_ID = :NEW.STUD_ID;

  IF v_count > 0 THEN

    v_new_average_mark := (v_old_average_mark * v_count + :NEW.MARK) / (v_count + 1);

    v_old_average_mark := ROUND(v_old_average_mark, 2);
    v_new_average_mark := ROUND(v_new_average_mark, 2);

    IF ABS(v_new_average_mark - v_old_average_mark) > 1.0 THEN
      DBMS_OUTPUT.PUT_LINE('Предупреждение: Значение нового среднего ' || v_new_average_mark ||
                           ' превышает заданный порог уклонения');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Новое среднее значение ' || v_new_average_mark || ' в пределах нормы.');
    END IF;

  ELSE
    DBMS_OUTPUT.PUT_LINE('Нет оценок для студента с ID ' || :NEW.STUD_ID);
  END IF;
END;
/

INSERT INTO EXAMS (EXAM_ID, STUD_ID, SUBJ_ID, MARK, EXAM_DATE) VALUES (101, 1, 5, 21, CURRENT_DATE);
INSERT INTO EXAMS (EXAM_ID, STUD_ID, SUBJ_ID, MARK, EXAM_DATE) VALUES (102, 1, 7, 3, CURRENT_DATE);
INSERT INTO EXAMS (EXAM_ID, STUD_ID, SUBJ_ID, MARK, EXAM_DATE) VALUES (103, 2, 10, 5, CURRENT_DATE);
