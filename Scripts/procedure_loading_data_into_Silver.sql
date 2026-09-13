create or alter procedure silver.load_silver as
begin
	declare @start_time as datetime , @end_time as datetime, @batch_start_time as datetime, @batch_end_time as datetime;
	begin try
		set @batch_start_time = getdate();
		print '========================================='
		print 'Loading Silver Layer';
		print '========================================='
		print '-----------------------------------------'
		print 'Loading_crm_tables'
		print '--------------------------------------------------------------'
		-----insert crm_cust_info from bronze to silver ------------------

		set @start_time = getdate();
		print '>>truncating table Silver.crm_cust_info'
		truncate table Silver.crm_cust_info;
		print '>>inserting table Silver.crm_cust_info'
		insert into Silver.crm_cust_info ( cst_id,cst_key, cst_firstname,
											cst_lastname,cst_marital_status,
											cst_gndr,cst_create_date)

		select cst_id,cst_key, trim(cst_firstname),trim(cst_lastname),
 
		case when upper(trim(cst_marital_status )) = 'S' then 'Single'
			 when upper(trim(cst_marital_status)) = 'M' then 'Married'
			 else 'n/a'
		end as cst_marital_status,
		case when upper(trim(cst_gndr )) = 'M' then 'Male'
			 when upper(trim(cst_gndr)) = 'F' then 'Femal'
			 else 'n/a'
		end as cst_gndr
		,cst_create_date
		from
		(select * , ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last
		from Bronze.crm_cust_info where cst_id is not null) t where flag_last = 1
		set @end_time = getdate();
		print '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as nvarchar) + 'seconds';
		PRINT '>> -------------';
	
		-----insert crm_prd_info from bronze to silver ------------------
		set @start_time = getdate();
		print '>>truncating table Silver.crm_prd_info'
		truncate table Silver.crm_prd_info;
		print '>>inserting table Silver.crm_prd_info'
		insert into Silver.crm_prd_info(
			prd_id  ,
			cat_id  ,
			prd_key ,
			prd_nm  ,
			prd_cost,
			prd_line ,
			prd_start_dt ,
			prd_end_dt   )

		select 
				prd_id,
				REPLACE (SUBSTRING(prd_key,1,5),'-','_') as cat_id,
        
				SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
				prd_nm,
				isnull (prd_cost,0) as prd_cost ,
				case upper(trim(prd_line ))
					 when  'M' then 'Mountain'
					 when  'S' then 'Other Sales'
					 when  'R' then 'Road'
					 when  'T' then 'Touring'
					 else 'n/a'
				end as prd_line ,
				cast(prd_start_dt as date) as prd_start_dt ,
				cast(LEAD (prd_start_dt) over (partition by prd_key order by prd_start_dt) - 1 as date) as prd_end_dt
		from Bronze.crm_prd_info
		set @end_time = getdate();
		print '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as nvarchar) + 'seconds';
		PRINT '>> -------------';

		-----insert crm_sales_details from bronze to silver ------------------
		set @start_time = GETDATE();
		print '>>truncating table Silver.crm_sales_details'
		truncate table Silver.crm_sales_details;
		print '>>inserting table Silver.crm_sales_details'
		insert into Silver.crm_sales_details (
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
		)
		select sls_ord_num,
		sls_prd_key, 
		sls_cust_id, 
		case when sls_order_dt = 0 or LEN(sls_order_dt) != 8 then null
				else cast(cast(sls_order_dt as varchar) as date)
		end as sls_order_dt,
		case when sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 then null
				else cast(cast(sls_ship_dt as varchar) as date)
		end as sls_ship_dt, 
		case when sls_due_dt = 0 or LEN(sls_due_dt) != 8 then null
				else cast(cast(sls_due_dt as varchar) as date)
		end as sls_due_dt, 
		case when sls_sales <= 0 or sls_sales is null or sls_sales != sls_quantity * abs(sls_price)
				then sls_quantity * abs(sls_price)
				else sls_sales
		end as sls_sales, 
		sls_quantity, 
		case when sls_price is null or sls_price <= 0 
				then sls_sales / nullif(sls_quantity,0)
				else sls_price
		end as sls_price

		from Bronze.crm_sales_details
		set @end_time = getdate();
		print '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as nvarchar) + 'seconds';
		PRINT '>> -------------';

		---------insert erp_cust_az12 from bronze to silver wiht transformation --------------------------------------
		set @start_time = GETDATE();
		print '>>truncating table Silver.erp_cust_az12'
		truncate table Silver.erp_cust_az12;
		print '>>inserting table Silver.erp_cust_az12'
		insert into Silver.erp_cust_az12 (cid,bdate,gen)
		select 
		case when cid like 'NAS%' then SUBSTRING (cid, 4, LEN(cid))
				else cid
		end as cid ,
		case when bdate > getdate() then null
				else bdate
		end as bdate,
			case when upper(trim(gen)) in ('F','FEMALE') then 'Female'
				 when upper(trim(gen)) in ('M','MALE') then 'Male'
				 else 'n/a'
		end as gen
		from Bronze.erp_cust_az12
		set @end_time = getdate();
		print '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as nvarchar) + 'seconds';
		PRINT '>> -------------';

		-----insert erp_loc_a101 from bronze to silver ------------------
		set @start_time = GETDATE();
		print '>>truncating table Silver.erp_loc_a101'
		truncate table Silver.erp_loc_a101;
		print '>>inserting table Silver.erp_loc_a101'
		insert into Silver.erp_loc_a101(cid, cntry)
		select 
		replace(cid,'-','') cid ,
		case when trim(cntry) = 'DE' then 'Germany'
				when trim(cntry) in ('US', 'USA') then 'United States'
				when trim(cntry) = '' or cntry is null then 'n/a'
				else trim(cntry)
		end as cntry
		from Bronze.erp_loc_a101
		set @end_time = getdate();
		print '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as nvarchar) + 'seconds';
		PRINT '>> -------------';

		-----insert erp_px_cat_g1v2 from bronze to silver ------------------
		set @start_time = GETDATE();
		print '>>truncating table Silver.erp_px_cat_g1v2'
		truncate table Silver.erp_px_cat_g1v2;
		print '>>inserting table Silver.erp_px_cat_g1v2'
		insert into Silver.erp_px_cat_g1v2 (id,cat,subcat, maintenance)
		select 
		id,
		cat,
		subcat,
		maintenance
		from Bronze.erp_px_cat_g1v2
		set @end_time = getdate();
		print '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as nvarchar) + 'seconds';
		PRINT '>> -------------';
		print '============================================';
		print 'bronze layer loaded';

		set @batch_end_time = getdate();
		print '============================================';
		print 'silver layer loaded';
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
