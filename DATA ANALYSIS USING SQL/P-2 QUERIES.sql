-- LIBRARY MANAGEMENT SYSTEM PROJECT 2


--CREATING BRANCH TABLE

DROP TABLE IF EXISTS branch;

CREATE TABLE BRANCH(
branch_id VARCHAR(20) PRIMARY KEY,
manager_id VARCHAR(20),
branch_address VARCHAR(60),
contact_no VARCHAR(20)
);


--CREATING EMPLOYEES TABLE

DROP TABLE IF EXISTS EMPLOYEES;
CREATE TABLE EMPLOYEES(
emp_id VARCHAR(20) PRIMARY KEY,
emp_name VARCHAR (25),
position VARCHAR(100),	
salary INT,
branch_id VARCHAR(20) --FK 
);

-- CREATING TABLE BOOKS

DROP TABLE IF EXISTS BOOKS;
CREATE TABLE BOOKS(
isbn VARCHAR(20) PRIMARY KEY,
book_title VARCHAR(75),
category VARCHAR(20),
rental_price FLOAT,
status VARCHAR(15),
author VARCHAR(35),	
publisher VARCHAR(55)
);


--CREATING TABLE MEMBERS

DROP TABLE IF EXISTS MEMBERS;
CREATE TABLE MEMBERS(
member_id VARCHAR(30) PRIMARY KEY,
member_name	VARCHAR(35),
member_address VARCHAR(40),	
reg_date DATE 
);

--CREATING TABLE ISSUED_STATUS

 DROP TABLE IF EXISTS ISSUED_STATUS;
CREATE TABLE ISSUED_STATUS(
issued_id VARCHAR(10) PRIMARY KEY,
issued_member_id VARCHAR(20),  -- FK
issued_book_name VARCHAR(20),
issued_date DATE,
issued_book_isbn VARCHAR(25), -- FK ,
issued_emp_id VARCHAR(10) -- FK
);

ALTER TABLE ISSUED_STATUS
ALTER COLUMN issued_book_isbn TYPE VARCHAR(50);

ALTER TABLE ISSUED_STATUS
ALTER COLUMN issued_book_name TYPE VARCHAR(50);


ALTER TABLE ISSUED_STATUS
ALTER COLUMN issued_book_name TYPE VARCHAR(1000);


--CREATING TABLE RETURN_STATUS

 DROP TABLE IF EXISTS RETURN_STATUS;
CREATE TABLE RETURN_STATUS(
return_id VARCHAR(20) PRIMARY KEY,
issued_id VARCHAR(20),
return_book_name VARCHAR (75),	
return_date	DATE,
return_book_isbn VARCHAR(20),
book_quality varchar(20)
);

--FOREIGN KEY

ALTER TABLE ISSUED_STATUS
ADD CONSTRAINT FK_MEMBERS
FOREIGN KEY(issued_member_id)
REFERENCES MEMBERS(member_id);

ALTER TABLE ISSUED_STATUS
ADD CONSTRAINT FK_BOOKS
FOREIGN KEY(issued_book_isbn)
REFERENCES BOOKS(isbn);

ALTER TABLE ISSUED_STATUS
ADD CONSTRAINT FK_EMPLOYEES
FOREIGN KEY(issued_emp_id)
REFERENCES EMPLOYEES(emp_id);

ALTER TABLE EMPLOYEES
ADD CONSTRAINT FK_branch
FOREIGN KEY(branch_id)
REFERENCES BRANCH(branch_id);

ALTER TABLE RETURN_STATUS
ADD CONSTRAINT FK_ISSUED_STATUS
FOREIGN KEY(issued_id)
REFERENCES ISSUED_STATUS(issued_id);

select * from BOOKS;
select * from BRANCH;
select * from EMPLOYEES;
select * from MEMBERS;
select * from RETURN_STATUS;
select * from ISSUED_STATUS;




-- Project Task

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
           INSERT INTO BOOKS(isbn,book_title,category,rental_price,status,author,publisher) values
		   ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic','6.00', 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address
            update members
			set  member_address ='897 3rd street'
			where member_id='C102';
			
            select * from members order by member_id asc;
 
-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
          delete from issued_status where issued_id='IS121';
         

-- Task 4: Retrieve All Books Issued by a Specific Employee 
--Objective: Select all books issued by the employee with emp_id = 'E101'.
           SELECT * FROM ISSUED_STATUS WHERE issued_emp_id='E101';

		   
-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.
             SELECT issued_emp_id,
			 count(issued_id) as total_books_issued from ISSUED_STATUS
			 group by 1 having count(issued_id)>1;


-- CTAS(CREATE TABLE AS SELECT)
-- Task 6: Create Summary Tables:
-- Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

             create table book_counts
             as
             select 
                b.isbn,
                b.book_title,
                count(ist.issued_id) as no_issued
                from books as b 
                   join 
                issued_status as ist 
                   on ist.issued_book_isbn=b.isbn
                      group by 1,2;

 --NOW WE CAN SEE THE TABLE WE HAVE CREATED
 select * from book_counts;


-- Task 7. Retrieve All Books in a Specific Category:
  select * from books where category='Classic';


-- Task 8: Find Total Rental Income by Category:

select 
b.category,
sum(b.rental_price),
count(*)
from books as b 
join 
issued_status as ist 
on ist.issued_book_isbn=b.isbn
group by 1;


-- Task 9: List Members Who Registered in the Last 180 Days
 select * from members where reg_date>=current_date-interval '180 days';

 
 -- HOW TO SEE THE CURRENT_DATE IN SQL
 select current_date;


-- Task 10 List Employees with Their Branch Manager's Name and their branch details:

select 
e1.*,
e2.emp_name as manager ,
b.manager_id
from employees as e1
join 
branch as b
on e1.branch_id=b.branch_id
join 
employees as e2
on b.manager_id=e2.emp_id


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
 create table expensive_books as
 select * from books where rental_price>7.00;
 select * from expensive_books;

-- Task 12: Retrieve the List of Books Not Yet Returned:

select * from issued_status as ist 
left join
return_status as rs
on rs.issued_id=ist.issued_id
where rs.return_id IS NULL;

/* Task 13: Identify Members with Overdue Books**  
 Write a query to identify members who have overdue books (assume a 30-day return period).
 Display the member's_id, member's name, book title, issue date, and days overdue.*/

--STEPS TO BE TAKEN WHILE ATTEMPTING THS TASK
-- issued_status==members==books==return_status
--filter books which is returned 
-- overdue>30 days


select * from issued_status;


select 
   ist.issued_member_id,
   m.member_name,
   bk.book_title,
   ist.issued_date,
  
   CURRENT_DATE - ist.issued_date as over_dues_days
    from issued_status as ist 
join 
     members as m
       on m.member_id=ist.issued_member_id
join 
     books as bk
         on ist.issued_book_isbn=bk.isbn

 left join 
     return_status as rst
	       on rst.issued_id=ist.issued_id

	where rst.return_date IS NULL
    AND ( CURRENT_DATE - ist.issued_date)>30

ORDER BY 1;	

/*  Task 14: Update Book Status on Return**  
    Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).*/

select * from issued_status
where issued_book_isbn='978-0-451-52994-2';

SELECT * FROM books where isbn='978-0-451-52994-2';

update  books
set status='no'
where isbn='978-0-451-52994-2';


select * from return_status where issued_id='IS130';

insert into return_status(return_id,issued_id,return_date,book_quality)
values
('RS125','IS130',CURRENT_DATE,'GOOD');

select * from return_status where issued_id='IS130';


--THIS IS THE AUTOMATIC PROCEDURE WE HAVE TO DONE WHEN WE HAVE TO  MAKE OUR TABLES REGULARLY UPDATED!!
--TO SOLVE THIS WE USE 
		 --  SYNTAX OF STORE PROCEDURES

CREATE OR REPLACE PROCEDURE add_return_records()
LANGUAGE PLPGSQL 
AS $$


DECLARE 


BEGIN 
 --ALL YOUR LOGIC AND CODE 

END;
$$


--MAKING STORE PROCEDURE
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(20), p_issued_id VARCHAR(20), p_book_quality VARCHAR(20))
LANGUAGE PLPGSQL 
AS $$

DECLARE 
   v_isbn varchar(50);
   v_book_name varchar(80);

BEGIN 
 --ALL YOUR LOGIC AND CODE 
 --inserting into returns based on users input
   insert into return_status(return_id,issued_id,return_date,book_quality)
   values
   (p_return_id,p_issued_id,CURRENT_DATE,p_book_quality); 

   SELECT 
       issued_book_isbn ,
	   issued_book_name
    INTO  
       v_isbn,
	   v_book_name
   FROM issued_status
   WHERE issued_id=p_issued_id;
   
  update  books
  set status='yes'
  where isbn='v_isbn';

  RAISE NOTICE 'THANK YOU FOR RETURNING THE BOOK: %', v_book_name;

END;
$$

call add_return_records()

--TESTING FUNCTIONS add_return_records

issued_id=IS135
ISBN=WHERE isbn='978-0-307-58837-1'

select * from books where isbn='978-0-09-957807-9';

select * from return_status where issued_id='IS112';
delete from return_status where issued_id='IS112';

call add_return_records('R138','IS112','GOOD');


/***Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.*/

select * from branch;

select * from issued_status;
select * from employees; 
select * from books;
select * from return_status;


create table branch_reports
as
select 
    b.branch_id,
	b.manager_id,
	count(ist.issued_id) as no_of_books_issued,
	count(rst.return_id) as no_of_books_returned,
    sum(bk.rental_price) as total_revenue

   from issued_status as ist 
        join 
    employees as e
    on ist.issued_emp_id=e.emp_id
        join 
    branch as b
    on b.branch_id=e.branch_id
        left join 
     return_status as rst
     on rst.issued_id=ist.issued_id
         join 
      books as bk
    on bk.isbn=ist.issued_book_isbn
        group by 1,2;

select * from branch_reports;

/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.*/

create table active_members 
as
select * from members
where member_id in (select 
                        distinct issued_member_id
                    from issued_status 
                    where
					      issued_date >= current_date - INTERVAL '2month'
						  );

select current_date - interval '2 month'

SELECT * FROM active_members;


/*Task 17: Find Employees with the Most Book Issues Processed 
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.*/

select 
e.emp_name,
b.*,
count(ist.issued_id) as no_of_book_issued

from issued_status as ist 
join 
employees as e
on e.emp_id=ist.issued_emp_id
join 
 branch as b
 on b.branch_id =e.branch_id
 group by 1,2;

 /*Task 18: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.*/



select * from books;

select * from issued_status;

create or replace procedure issue_book(p_issued_id varchar(10),p_issued_member_id varchar(20),p_issued_book_isbn varchar(50),p_issued_emp_id varchar(10))
language plpgsql
as $$

declare 
-- all the variable declarence 
   v_status varchar(15);


begin 
--all your logic and code
--checking if the book is availabe 'yes'
select status 
into 
v_status 
from books
where isbn=p_issued_book_isbn;

IF v_status = 'yes' then 

         insert into issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
            values
               (p_issued_id ,p_issued_member_id ,current_date,p_issued_book_isbn ,p_issued_emp_id);

			   update  books
               set status='no'
               where isbn=p_issued_book_isbn;     
 
               
             raise notice 'book records added successfully for book isbn : %',p_issued_book_isbn;

else 
                  raise notice 'Sorry to inform you that book you have requested is unavailable book_isbn  : %',p_issued_book_isbn;

end if;
    
end;
$$


select * from books;
--978-0-553-29698-2--yes
--978-0-307-58837-1--no

select * from issued_status;


call issue_book('IS155','C107','978-0-553-29698-2','E103');


call issue_book('IS156','C107','978-0-307-58837-1','E103');


select * from books where isbn='978-0-553-29698-2';
select * from books where isbn='978-0-307-58837-1';



