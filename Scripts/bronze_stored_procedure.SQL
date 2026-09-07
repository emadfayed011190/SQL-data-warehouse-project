create or alter procedure Bronze.load_bronze as 
begin 
	declare @start_time as datetime , @end_time as datetime , @batch_start_time as datetime , @batch_end_time as datetime;
	begin try
		set @batch_start_time = getdate();
		print '========================================='
		print 'Loading Bronze Layer';
		print '========================================='
		print '-----------------------------------------'
		print 'Loading_crm_tables'
		print '--------------------------------------------------------------'
		set @start_time = getdate();
		print '>>truncating table: bronze.crm_cust_info'
		truncate table bronze.crm_cust_info
		print '>>inserting table: bronze.crm_cust_info'
		bulk insert bronze.crm_cust_info
		from 'C:\Users\masarat\Downloads\sql_course_material_baraa\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as nvarchar) + 'seconds';
		PRINT '>> -------------';
		--===========================================================
		set @start_time = getdate();
		print '>>truncating table: bronze.crm_prd_info'
		truncate table bronze.crm_prd_info
		print '>>inserting table: bronze.crm_prd_info'
		bulk insert bronze.crm_prd_info
		from 'C:\Users\masarat\Downloads\sql_course_material_baraa\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as nvarchar) + 'seconds';
		PRINT '>> -------------';

		--============================================================
		set @start_time = getdate();
		print '>>truncating table: bronze.crm_sales_details'
		truncate table bronze.crm_sales_details
		print '>>inserting table: bronze.crm_sales_details'
		bulk insert bronze.crm_sales_details
		from 'C:\Users\masarat\Downloads\sql_course_material_baraa\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as nvarchar) + 'seconds';
		PRINT '>> -------------';
		---===========================================================
		print '========================================='
		print 'Loading Bronze Layer';
		print '========================================='
		print '-----------------------------------------'
		print 'Loading_erp_tables'
		print '-----------------------------------------'
		set @start_time = getdate();
		print '>>truncating table: bronze.erp_CUST_AZ12'
		truncate table bronze.erp_CUST_AZ12
		print '>>inserting table: bronze.erp_CUST_AZ12'
		bulk insert bronze.erp_CUST_AZ12
		from 'C:\Users\masarat\Downloads\sql_course_material_baraa\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as nvarchar) + 'seconds';
		PRINT '>> -------------';
		--============================================================
		set @start_time = getdate();
		print 'truncating bronze.erp_LOC_A101'
		truncate table bronze.erp_LOC_A101
		print 'inserting bronze.erp_LOC_A101'
		bulk insert bronze.erp_LOC_A101
		from 'C:\Users\masarat\Downloads\sql_course_material_baraa\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as nvarchar) + 'seconds';
		PRINT '>> -------------';
		--============================================================
		set @start_time = getdate();
		print 'truncating bronze.erp_PX_CAT_G1V2'
		truncate table bronze.erp_PX_CAT_G1V2
		bulk insert bronze.erp_PX_CAT_G1V2
		from 'C:\Users\masarat\Downloads\sql_course_material_baraa\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
	);
		set @end_time = getdate();
		print '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as nvarchar) + 'seconds';
		PRINT '>> -------------';

		set @batch_end_time = getdate();
		print '============================================';
		print 'bronze layer loaded';
		print 'total_load_duration: ' + cast(datediff(second, @batch_start_time, @batch_end_time) as nvarchar) + 'seconds';
	end try
	begin catch
	print '===================================================='
	print 'ERROR OCCURDING DURING LOADING BRONZE LAYER'
	PRINT 'ERROR MESSAGE' + ERROR_message();
	PRINT 'ERROR MESSAGE' + cast (ERROR_number()as nvarchar);
	PRINT 'ERROR MESSAGE' + cast (ERROR_state()as nvarchar);
	print '===================================================='

	end catch
end
