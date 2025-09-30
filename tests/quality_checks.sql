-- check for nulls or duplicates in the primary key 

SELECT 
cst_id,
COUNT(*)
FROM [Datawarehouse].[Bronze].[crm_cust_info]
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id IS NULL

--Check for unwanted spaces:

SELECT cst_firstname 
FROM [Datawarehouse].[Bronze].[crm_cust_info]
WHERE cst_firstname!= TRIM(cst_firstname)


SELECT cst_lastname 
FROM [Datawarehouse].[Bronze].[crm_cust_info]
WHERE cst_lastname!= TRIM(cst_lastname)

SELECT cst_gndr 
FROM [Datawarehouse].[Bronze].[crm_cust_info]
WHERE cst_gndr!= TRIM(cst_gndr)

--Data standardization and consitency
SELECT DISTINCT cst_gndr
FROM [Datawarehouse].[Bronze].[crm_cust_info]

SELECT DISTINCT cst_marital_status
FROM [Datawarehouse].[Bronze].[crm_cust_info]

SELECT*FROM [Datawarehouse].[Silver].[crm_cust_info]




-- check for nulls or duplicates in primary key 
SELECT
prd_id,
COUNT(*)
FROM [Datawarehouse].[Bronze].[crm_prd_info]
GROUP BY prd_id
HAVING COUNT(*)>1 OR prd_id IS NULL

--check for nulls or negative numbers
SELECT
prd_cost
FROM [Datawarehouse].[Bronze].[crm_prd_info]
WHERE prd_cost<0 OR prd_cost IS NULL

--Data standardization and consistency
SELECT DISTINCT prd_line
FROM [Datawarehouse].[Bronze].[crm_prd_info]

--check for invalid dates
SELECT 
NULLIF (sls_order_dt,0) sls_order_dt
FROM [Datawarehouse].[Bronze].[crm_sales_details]
WHERE sls_order_dt<=0 
OR LEN(sls_order_dt)!=8
OR sls_order_dt>20500101
OR sls_order_dt<19000101

--check for invalid date orders
SELECT
*
FROM [Datawarehouse].[Bronze].[crm_sales_details]
WHERE sls_order_dt>sls_ship_dt OR sls_order_dt>sls_due_dt

-- Check Data Consistency: Sales = Quantity * Price
SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM [Datawarehouse].[Bronze].[crm_sales_details]
WHERE sls_sales!= sls_price*sls_quantity
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales <=0
OR sls_quantity <=0
OR sls_price <=0
ORDER BY sls_sales,sls_quantity,sls_price

--Identify out of range dates
SELECT DISTINCT
bdate
FROM [Datawarehouse].[Bronze].[erp_cust_az12]
WHERE bdate < '1924-01-01' OR bdate >GETDATE()


--Data standardization and consistency
SELECT DISTINCT gen
FROM [Datawarehouse].[Bronze].[erp_cust_az12]

--Data standardization and consistency
SELECT DISTINCT cntry
FROM [Datawarehouse].[Bronze].[erp_loc_a101]
ORDER BY cntry

--check for unwanted spaces
SELECT * FROM [Datawarehouse].[Bronze].[erp_px_cat_g1v2]
WHERE cat !=TRIM(cat) OR subcat !=TRIM(subcat) OR maintenance !=TRIM(maintenance)

--Data standardization and consistency
SELECT DISTINCT
maintenance
FROM [Datawarehouse].[Bronze].[erp_px_cat_g1v2]

--foreign key integrity 
SELECT *
FROM Gold.fact sales f
LEFT JOIN Gold.dim_customers c
ON c.customer_key= f.costumer_key
LEFT JOIN Gold.dim_products p
ON p.product_key= f.product_key
WHERE p.product_key IS NULL
