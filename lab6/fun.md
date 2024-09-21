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
        
        -- Handle the case where no rows are returned
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