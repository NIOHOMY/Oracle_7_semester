# Oracle_7_semester

Иструкцию по установке и созданию OracleDB с VScode смотреть [тут](https://github.com/Niapollab/Relational-databases_7-semester/blob/master/README.md)

### Лаболаторная 1

Сделать выборку из таблицы UNIVERSITY с использованием курсора и <br/>
цикла с методом %FOUND или %NOTFOUND для получения данных об <br/>
университетах с рейтингом большим 400 и с помощью пользовательской <br/>
исключительной ситуации исключить из вывода данные об университетах, <br/>
расположенных в Воронеже.

<details>
<summary>Смотреть решение</summary>
  
```sql
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
```
</details>

### Лаболаторная 2

Описать и вызвать функцию, которая определяет для студентов  <br/>
с заданной фамилией сумму баллов по заданному предмету в таблице EXAM_MARKS

<details>
<summary>Смотреть решение</summary>
  
```sql
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
```
</details>

### Лаболаторная 3

Создать пакет, состоящий из функции с параметрами, процедуры без   <br/>
параметров. Функция подсчитывает количество студентов, учащихся в  <br/>
университете, заданным параметром.  <br/> 
Процедура подсчитывает количество обращений к функции и заносит: 
- это количество
- номер университета
- количество студентов
в новую таблицу, созданную заранее.

<details>
<summary>Смотреть решение</summary>
  
```sql
SET SERVEROUTPUT ON;

ACCEPT PROMT_UNIVERSITY_ID NUMBER PROMPT 'Введите ID нужного университета: ';

CREATE TABLE LAB_3_RESULT_TABLE (
  UNIV_ID INTEGER PRIMARY KEY,
  STUDENTS_COUNT INTEGER,
  CALL_COUNT INTEGER
);

CREATE OR REPLACE PACKAGE UNIVERSITY_PACKAGE AS
  FUNCTION STUDENTS_COUNT(
    UNIVERSITY_ID IN NUMBER
  ) RETURN NUMBER;

  PROCEDURE INSERT_TO_TABLE;
END;
/

CREATE OR REPLACE PACKAGE BODY UNIVERSITY_PACKAGE AS
  CALL_COUNT          INTEGER := 0;
  LAST_UNIVERSITY_ID  NUMBER;
  LAST_STUDENTS_COUNT NUMBER;

  FUNCTION STUDENTS_COUNT(
    UNIVERSITY_ID IN NUMBER
  ) RETURN NUMBER IS
    RES NUMBER;
  BEGIN
    CALL_COUNT := CALL_COUNT + 1;
    LAST_UNIVERSITY_ID := UNIVERSITY_ID;

    SELECT
      COUNT(*) INTO RES
    FROM
      STUDENT
    WHERE
      STUDENT.UNIV_ID = UNIVERSITY_ID;

    LAST_STUDENTS_COUNT := RES;
    RETURN RES;
  END;

  PROCEDURE INSERT_TO_TABLE IS
  BEGIN
    INSERT INTO LAB_3_RESULT_TABLE VALUES (
      LAST_UNIVERSITY_ID,
      LAST_STUDENTS_COUNT,
      CALL_COUNT
    );
  END;
END;
/

DECLARE
  STUDENTS_COUNT NUMBER;

BEGIN
  STUDENTS_COUNT := UNIVERSITY_PACKAGE.STUDENTS_COUNT(&PROMT_UNIVERSITY_ID);
  UNIVERSITY_PACKAGE.INSERT_TO_TABLE();
END;
/
```
</details>

### Лаболаторная 4

Создать триггер, который считает средний балл заданного студента и <br/>
выдает диагностическое сообщение при превышении заданного порога <br/>
уклонения вводимого значения атрибута в зависимости от среднего <br/>
балла, при этом происходит заполнение некоторой таблицы <br/>

<details>
<summary>Смотреть решение</summary>
  
```sql
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
```
</details>

### Лаболаторная 5

Создать таблицу и заполнить ее с использованием последовательностей.

<details>
<summary>Смотреть решение</summary>
  
```sql
SET SERVEROUTPUT ON;

ACCEPT PROMT_UNIVERSITY_NAME CHAR PROMPT 'Введите название университета: ';
ACCEPT PROMT_UNIVERSITY_RATING NUMBER PROMPT 'Введите рейтинг университета: ';
ACCEPT PROMT_UNIVERSITY_CITY CHAR PROMPT 'Введите город, где находится универтитет: ';

CREATE TABLE UNIVERSITY_LAB_5 (
    UNIV_ID INTEGER PRIMARY KEY,
    UNIV_NAME CHAR(140) NOT NULL UNIQUE,
    RATING INTEGER,
    CITY CHAR(30) NOT NULL
);

-- DROP SEQUENCE UNIV_ID_SEQUENCE
-- CREATE SEQUENCE UNIV_ID_SEQUENCE START WITH 1;

-- DELETE FROM UNIVERSITY_LAB_5 WHERE UNIV_ID > 0;

BEGIN
    INSERT INTO UNIVERSITY_LAB_5 VALUES (
        UNIV_ID_SEQUENCE.NEXTVAL,
        '&PROMT_UNIVERSITY_NAME',
        &PROMT_UNIVERSITY_RATING,
        '&PROMT_UNIVERSITY_CITY'
    );
    DBMS_OUTPUT.PUT_LINE('Запись успешно добавлена.');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: Уникальное значение нарушено. Проверьте название университета.');
END;
/
```
</details>

### Лаболаторная 6

База данных библиотеки.
Разработать информационную систему обслуживания библиотеки,  <br/>
которая содержит следующую информацию: 
- названия книг
- ФИО авторов
- наименования издательств
- год издания
- количество страниц
- количество иллюстраций
- стоимость
- название филиала библиотеки или книгохранилища, в которых находится книга
- количество имеющихся в библиотеке экземпляров конкретной книги
- количество студентов, которым выдавалась конкретная книга
- названия факультетов, в учебном процессе которых используется указанная книга.

Написать пакет, состоящий из процедур и функций, которые позволили выполнить следующие действия с базой данных:
1. Для указанного филиала посчитать количество экземпляров указанной книги, находящихся в нем.
2. Для указанной книги посчитать количество факультетов, на которых она используется.
3. Предоставить возможность добавления и изменения информации о книгах в библиотеке.
4.Предоставить возможность добавления и изменения информации офилиалах.

Предусмотреть разработку триггеров, обеспечивающие каскадные из менения в связанных таблицах.

<details>
<summary>Смотреть решение</summary>
  <details>
  <summary>Создание</summary>
    
  ```sql
  
  ### Структура базы данных
  
  ```sql
  CREATE TABLE AUTHORS (
      AUTHOR_ID INTEGER PRIMARY KEY,
      FULL_NAME CHAR(100) NOT NULL
  );
  
  CREATE TABLE PUBLISHERS (
      PUBLISHER_ID INTEGER PRIMARY KEY,
      NAME CHAR(100) NOT NULL
  );
  
  CREATE TABLE BRANCHES (
      BRANCH_ID INTEGER PRIMARY KEY,
      NAME CHAR(100) NOT NULL
  );
  
  CREATE TABLE BOOKS (
      BOOK_ID INTEGER PRIMARY KEY,
      TITLE CHAR(150) NOT NULL,
      AUTHOR_ID INTEGER,
      PUBLISHER_ID INTEGER,
      YEAR_PUBLISHED INTEGER,
      PAGE_COUNT INTEGER,
      ILLUSTRATION_COUNT INTEGER,
      COST DECIMAL(10, 2),
      BRANCH_ID INTEGER,
      COPIES_AVAILABLE INTEGER,
      STUDENTS_BORROWED INTEGER,
      FOREIGN KEY (AUTHOR_ID) REFERENCES AUTHORS(AUTHOR_ID),
      FOREIGN KEY (PUBLISHER_ID) REFERENCES PUBLISHERS(PUBLISHER_ID),
      FOREIGN KEY (BRANCH_ID) REFERENCES BRANCHES(BRANCH_ID)
  );
  
  CREATE TABLE FACULTIES (
      FACULTY_ID INTEGER PRIMARY KEY,
      NAME CHAR(100) NOT NULL
  );
  
  CREATE TABLE BOOK_FACULTY (
      BOOK_ID INTEGER,
      FACULTY_ID INTEGER,
      PRIMARY KEY (BOOK_ID, FACULTY_ID),
      FOREIGN KEY (BOOK_ID) REFERENCES BOOKS(BOOK_ID),
      FOREIGN KEY (FACULTY_ID) REFERENCES FACULTIES(FACULTY_ID)
  );
  
  ### Пакет PL/SQL
  
  SET SERVEROUTPUT ON;
  
  CREATE OR REPLACE PACKAGE library_management AS
      FUNCTION count_copies_in_branch(book_id INTEGER, branch_id INTEGER) RETURN INTEGER;
      FUNCTION count_faculties_using_book(book_id INTEGER) RETURN INTEGER;
      PROCEDURE add_or_update_book(
          book_id IN OUT INTEGER,
          title IN CHAR,
          author_id IN INTEGER,
          publisher_id IN INTEGER,
          year_published IN INTEGER,
          page_count IN INTEGER,
          illustration_count IN INTEGER,
          cost IN DECIMAL,
          branch_id IN INTEGER,
          copies_available IN INTEGER,
          students_borrowed IN INTEGER);
      PROCEDURE add_or_update_branch(
          branch_id IN OUT INTEGER,
          name IN CHAR);
  END library_management;
  /
  
  CREATE OR REPLACE PACKAGE BODY library_management AS
      FUNCTION count_copies_in_branch(book_id INTEGER, branch_id INTEGER) RETURN INTEGER IS
          copies_count INTEGER;
      BEGIN
          SELECT SUM(COPIES_AVAILABLE) INTO copies_count
          FROM BOOKS
          WHERE BOOK_ID = book_id AND BRANCH_ID = branch_id;
    
          RETURN NVL(copies_count, 0);
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              RETURN 0;
      END count_copies_in_branch;
  
      FUNCTION count_faculties_using_book(book_id INTEGER) RETURN INTEGER IS
          faculties_count INTEGER;
      BEGIN
          SELECT COUNT(DISTINCT FACULTY_ID) INTO faculties_count
          FROM BOOK_FACULTY
          WHERE BOOK_ID = book_id;
          RETURN faculties_count;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              RETURN 0;
      END count_faculties_using_book;
  
      PROCEDURE add_or_update_book(
          book_id IN OUT INTEGER,
          title IN CHAR,
          author_id IN INTEGER,
          publisher_id IN INTEGER,
          year_published IN INTEGER,
          page_count IN INTEGER,
          illustration_count IN INTEGER,
          cost IN DECIMAL,
          branch_id IN INTEGER,
          copies_available IN INTEGER,
          students_borrowed IN INTEGER) IS
      BEGIN
          IF book_id IS NULL THEN
              INSERT INTO BOOKS (TITLE, AUTHOR_ID, PUBLISHER_ID, YEAR_PUBLISHED, PAGE_COUNT,
                  ILLUSTRATION_COUNT, COST, BRANCH_ID, COPIES_AVAILABLE, STUDENTS_BORROWED)
              VALUES (title, author_id, publisher_id, year_published, page_count,
                  illustration_count, cost, branch_id, copies_available, students_borrowed)
              RETURNING BOOK_ID INTO book_id;
          ELSE
              UPDATE BOOKS SET
                  TITLE = title,
                  AUTHOR_ID = author_id,
                  PUBLISHER_ID = publisher_id,
                  YEAR_PUBLISHED = year_published,
                  PAGE_COUNT = page_count,
                  ILLUSTRATION_COUNT = illustration_count,
                  COST = cost,
                  BRANCH_ID = branch_id,
                  COPIES_AVAILABLE = copies_available,
                  STUDENTS_BORROWED = students_borrowed
              WHERE BOOK_ID = book_id;
          END IF;
      END add_or_update_book;
  
      PROCEDURE add_or_update_branch(
          branch_id IN OUT INTEGER,
          name IN CHAR) IS
      BEGIN
          IF branch_id IS NULL THEN
              INSERT INTO BRANCHES (NAME) VALUES (name)
              RETURNING BRANCH_ID INTO branch_id;
          ELSE
              UPDATE BRANCHES SET NAME = name WHERE BRANCH_ID = branch_id;
          END IF;
      END add_or_update_branch;
  END library_management;
  /
  
  ### Триггеры
  
  
    CREATE OR REPLACE TRIGGER trg_update_copies
    AFTER INSERT OR UPDATE ON BOOKS
    FOR EACH ROW
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Книга ' || :NEW.title || ' (ID: ' || :NEW.book_id || ') успешно добавлена или обновлена.');
        DBMS_OUTPUT.PUT_LINE('Автор: ' || :NEW.author_id || ', Издатель: ' || :NEW.publisher_id || ', Год издания: ' || :NEW.year_published || ', Количество страниц: ' || :NEW.page_count);
        DBMS_OUTPUT.PUT_LINE('Стоимость: ' || :NEW.cost || ', Доступные копии: ' || :NEW.copies_available);
    END;
    /
    
    CREATE OR REPLACE TRIGGER trg_update_copies_available
    BEFORE UPDATE OF students_borrowed ON BOOKS
    FOR EACH ROW
    BEGIN
        :NEW.copies_available := :OLD.copies_available - (:NEW.students_borrowed - :OLD.students_borrowed);
    END;
    /
  ```
  </details>
  <details>
  <summary>Заполнение данными</summary>
    
  ```sql
  -- Populate AUTHORS
  INSERT INTO AUTHORS (AUTHOR_ID, FULL_NAME) VALUES (1, 'George Orwell');
  INSERT INTO AUTHORS (AUTHOR_ID, FULL_NAME) VALUES (2, 'J.K. Rowling');
  INSERT INTO AUTHORS (AUTHOR_ID, FULL_NAME) VALUES (3, 'J.R.R. Tolkien');
  
  -- Populate PUBLISHERS
  INSERT INTO PUBLISHERS (PUBLISHER_ID, NAME) VALUES (1, 'Harvill Secker');
  INSERT INTO PUBLISHERS (PUBLISHER_ID, NAME) VALUES (2, 'Bloomsbury');
  INSERT INTO PUBLISHERS (PUBLISHER_ID, NAME) VALUES (3, 'HarperCollins');
  
  -- Populate BRANCHES
  INSERT INTO BRANCHES (BRANCH_ID, NAME) VALUES (1, 'Main Branch');
  INSERT INTO BRANCHES (BRANCH_ID, NAME) VALUES (2, 'West Branch');
  INSERT INTO BRANCHES (BRANCH_ID, NAME) VALUES (3, 'East Branch');
  
  -- Populate BOOKS
  INSERT INTO BOOKS (BOOK_ID, TITLE, AUTHOR_ID, PUBLISHER_ID, YEAR_PUBLISHED, PAGE_COUNT, ILLUSTRATION_COUNT, COST, BRANCH_ID, COPIES_AVAILABLE, STUDENTS_BORROWED)
  VALUES (2, 'Harry Potter and the Philosopher''s Stone', 2, 2, 1997, 223, 8, 20.99, 2, 8, 5);
  
  INSERT INTO BOOKS (BOOK_ID, TITLE, AUTHOR_ID, PUBLISHER_ID, YEAR_PUBLISHED, PAGE_COUNT, ILLUSTRATION_COUNT, COST, BRANCH_ID, COPIES_AVAILABLE, STUDENTS_BORROWED)
  VALUES (3, 'The Hobbit', 3, 3, 1937, 310, 3, 12.50, 3, 2, 1);
  
  -- Populate FACULTIES
  INSERT INTO FACULTIES (FACULTY_ID, NAME) VALUES (1, 'Literature');
  INSERT INTO FACULTIES (FACULTY_ID, NAME) VALUES (2, 'Science');
  INSERT INTO FACULTIES (FACULTY_ID, NAME) VALUES (3, 'Arts');
  
  -- Populate BOOK_FACULTY
  INSERT INTO BOOK_FACULTY (BOOK_ID, FACULTY_ID) VALUES (1, 1);
  INSERT INTO BOOK_FACULTY (BOOK_ID, FACULTY_ID) VALUES (2, 1);
  INSERT INTO BOOK_FACULTY (BOOK_ID, FACULTY_ID) VALUES (2, 2);
  INSERT INTO BOOK_FACULTY (BOOK_ID, FACULTY_ID) VALUES (3, 3);
  ```
  </details>

  <details>
  <summary>Тестирование</summary>
    
  ```sql
SET SERVEROUTPUT ON;


DECLARE
    copies_count INTEGER;
BEGIN
    copies_count := library_management.count_copies_in_branch(book_id => 1, branch_id => 2);
    DBMS_OUTPUT.PUT_LINE('Количество экземпляров книги в филиале: ' || copies_count);
END;
/

DECLARE
    faculties_count INTEGER;
BEGIN
    faculties_count := library_management.count_faculties_using_book(book_id => 1);
    DBMS_OUTPUT.PUT_LINE('Количество факультетов, использующих книгу: ' || faculties_count);

    UPDATE BOOKS 
    SET students_borrowed = 4 
    WHERE BOOK_ID = 1;
END;
/

DECLARE
    copies_count INTEGER;
BEGIN
    copies_count := library_management.count_copies_in_branch(book_id => 1, branch_id => 2);
    DBMS_OUTPUT.PUT_LINE('Количество экземпляров книги в филиале: ' || copies_count);

    UPDATE BOOKS 
    SET students_borrowed = 3
    WHERE BOOK_ID = 1;
END;
/
  ```
  </details>

</details>
