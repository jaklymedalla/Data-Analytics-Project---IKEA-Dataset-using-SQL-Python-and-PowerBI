
-- Combine the two tables of data

select 
	Invoice, StockCode, Description, Quantity,

	coalesce(
		TRY_CONVERT(datetime2, InvoiceDate, 120),
		try_convert(datetime2, InvoiceDate, 105)
	) as InvoiceDate,

	TRY_CONVERT(decimal(10,2), Price) as Price,
	Customer_ID, Country, '2009-2010' as SourceSheet
into dbo.RetailCombined
from dbo.[Year 2009-2010]

Union All

select 
	Invoice, StockCode, Description, Quantity,

	coalesce(
		TRY_CONVERT(datetime2, InvoiceDate, 120),
		try_convert(datetime2, InVoiceDate, 105)
	) as InvoiceDate,

	TRY_CONVERT(decimal(10,2), Price) as Price,
	Customer_ID, Country, '2010-2011' as SourceSheet
from dbo.[Year 2010-2011]


-- Comfirm the conversion worked correctly
select count(*) as total_rows from RetailCombined
select count(*) as failed_dates from RetailCombined where InvoiceDate is null;
select count(*) as failed_prices from RetailCombined where Price is null;

-- Exploratory Data Analysis

-- Check 1 - Missing Customer ID
select count(*) as missing_values_customerID 
from RetailCombined where Customer_ID is null;

-- Check 2 - Negative or Zero Quantity
select count(*) as Negative_qnty
from RetailCombined where Quantity <= 0;

-- Check 3- Missing Description
select count(*) as missing_description
from RetailCombined where Description is null;

-- Check 4 - Check Exact Duplicates
select Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country,
	count(*) as ExactDupCount
from RetailCombined
group by Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country
having count(*) > 1;

-- Remove Duplicates of the Data and Create  the Cleaned Table.
with Deduped as (
	select *, 
	row_number() over(
	 partition by  Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country
	 order by (select null)
	) as Row_num
	from RetailCombined
)
select Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country, SourceSheet
into dbo.RetailCleaned
from Deduped
where Row_num = 1

-- Cleaned Table
select *
from RetailCleaned

-- Duplicate Checking
select Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country,
	count(*) as ExactDupCount
from RetailCleaned
group by Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country
having count(*) > 1;
-- 