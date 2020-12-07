# DDL, DML, DCL, and TCL Commands in SQL Server

## 1.Data Manipulation Language (DML)

Is used to edit the data in the database: change the data by retrieve, store, modify, delete, insert and update.

*SELECT* Retrieve data according to a specified condition in the query.  
*INSERT* Enter the data into the table.  
*UPDATE* Update the records in the table.  
*DELETE* Delete the existing records in the table.  

## 2.Data Definition Language (DDL)

Is used to edit object of database

*CREATE*   Create a table and database.  
*ALTER*    Alter the objects.  
*DROP*     Deletes the whole object or database at once with data (for table).  
*TRUNCATE* Deletes all data in the table bypassing the transaction log (faster than delete).  

## 3.Data Control Language (DCL)

Is used to give rights and permission to the user.  
It is used to control access to the database by securing it.  

*GRANT*  This command is used to give user access privileges to the database.  
*REVOKE* It is used to withdraw a user’s access privileges to the database that is given to a user using the GRANT command.  

## 4.Transactional Control Language (TCL)

Transactional Control Language is used to create and manage transactions within the database.

*COMMIT*     It is used to commit a transaction that is to apply the changes in the database made by the transaction.  
*SAVEPOINT*  It is to save changes made by transaction temporarily till a certain point in the database.  
*ROLLBACK*   This command is used to restore the database to the last committed point.  
