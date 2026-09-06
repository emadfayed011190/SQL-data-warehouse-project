/*
======================================================
Create database and schemas
=========================================
Script purpose:
	this script create a new database named 'Datawarehouse' after checking if it is already exist.
	if the database exist droped and recreated. Additionalyly, the script set up 3 schemas 
	with in the database Bronze,Silver and Gold.

Warning:
	Running this script will drop the entire 'DataWarehouse' database if it exists. All data in the database
	will be permanently deleted.
	Proceed with caution and ensure you have proper backups before running this script.

*/

-- create Database 'Datawarehouse'
use master ;
GO
-- drope and recreate the 'datawarehouse' Database
if exists (select 1 from sys.databases where name = 'Datawarehouse')
begin
	Alter database Datawarehouse SET single_user with rollback immediate;
	drop database Datawarehouse;
end;
go

CREATE DATABASE Datawarehouse;
use Datawarehouse;

create schema Bronze;
GO
CREATE SCHEMA Silver;
GO
CREATE SCHEMA Gold;
GO
