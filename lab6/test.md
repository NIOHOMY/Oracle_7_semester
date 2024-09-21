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