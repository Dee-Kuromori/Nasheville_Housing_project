/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM Portfolio_Project.dbo.[Nasheville Housing Data];


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate,SaleDateConverted, CONVERT(DATE,SaleDate) AS SaleDateOnly
FROM Portfolio_Project.dbo.[Nasheville Housing Data];


-- This does not always work
UPDATE Portfolio_Project.dbo.[Nasheville Housing Data]
SET SaleDate = CONVERT(DATE,SaleDate);


-- This is another solution
-- Add new column with date data type and then update it-
-- with date part of SaleDate
ALTER TABLE Portfolio_Project.dbo.[Nasheville Housing Data]
ADD SaleDateConverted DATE;

UPDATE Portfolio_Project.dbo.[Nasheville Housing Data]
SET SaleDateConverted = CONVERT(DATE,SaleDate);


--Another way to do it-
--Alter the column data type of sale date
ALTER TABLE Portfolio_Project.dbo.[Nasheville Housing Data]
ALTER COLUMN SaleDate DATE;



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM Portfolio_Project.dbo.[Nasheville Housing Data];

SELECT *
FROM Portfolio_Project.dbo.[Nasheville Housing Data]
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT 
	nash1.UniqueID,
	nash1.ParcelID,
	nash1.PropertyAddress,
	nash2.UniqueID,
	nash2.ParcelID,
	nash2.PropertyAddress,
	ISNULL(nash1.PropertyAddress,nash2.PropertyAddress) AS fill_null_adresses
FROM Portfolio_Project.dbo.[Nasheville Housing Data] AS nash1
	JOIN Portfolio_Project.dbo.[Nasheville Housing Data] AS nash2
	ON nash1.ParcelID = nash2.ParcelID
	AND nash1.UniqueID <> nash2.UniqueID
WHERE nash1.PropertyAddress IS NULL;


--have to use allias of table when using JOIN in UPDATE
UPDATE nash1
SET PropertyAddress = ISNULL(nash1.PropertyAddress,nash2.PropertyAddress)
FROM Portfolio_Project.dbo.[Nasheville Housing Data] AS nash1
	JOIN Portfolio_Project.dbo.[Nasheville Housing Data] AS nash2
	ON nash1.ParcelID = nash2.ParcelID
	AND nash1.UniqueID <> nash2.UniqueID
WHERE nash1.PropertyAddress IS NULL;



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Portfolio_Project.dbo.[Nasheville Housing Data];


SELECT 
	SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Adress,
	CHARINDEX(',',PropertyAddress),
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM Portfolio_Project.dbo.[Nasheville Housing Data];

ALTER TABLE Portfolio_Project.dbo.[Nasheville Housing Data]
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Portfolio_Project.dbo.[Nasheville Housing Data]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE Portfolio_Project.dbo.[Nasheville Housing Data]
ADD PropertySplitCity NVARCHAR(255);

UPDATE Portfolio_Project.dbo.[Nasheville Housing Data]
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

SELECT 
	PropertySplitAddress,
	PropertySplitCity
FROM Portfolio_Project.dbo.[Nasheville Housing Data];

SELECT 
	OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress,',','.'),1),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),3)
FROM Portfolio_Project.dbo.[Nasheville Housing Data];

ALTER TABLE Portfolio_Project.dbo.[Nasheville Housing Data]
Add OwnerSplitAddress Nvarchar(255);

Update Portfolio_Project.dbo.[Nasheville Housing Data]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


ALTER TABLE Portfolio_Project.dbo.[Nasheville Housing Data]
Add OwnerSplitCity Nvarchar(255);

Update Portfolio_Project.dbo.[Nasheville Housing Data]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE Portfolio_Project.dbo.[Nasheville Housing Data]
Add OwnerSplitState Nvarchar(255);

Update Portfolio_Project.dbo.[Nasheville Housing Data]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

SELECT 
	OwnerSplitAddress,
	OwnerSplitCity,
	OwnerSplitState
FROM Portfolio_Project.dbo.[Nasheville Housing Data];




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT 
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM Portfolio_Project.dbo.[Nasheville Housing Data]
GROUP BY SoldAsVacant;


SELECT 
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 1 THEN 'Yes'
		WHEN SoldAsVacant = 0 THEN 'No'
	END
FROM Portfolio_Project.dbo.[Nasheville Housing Data];

ALTER TABLE Portfolio_Project.dbo.[Nasheville Housing Data]
ALTER COLUMN SoldAsVacant NVARCHAR(10);

UPDATE Portfolio_Project.dbo.[Nasheville Housing Data]
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 1 THEN 'Yes'
		WHEN SoldAsVacant = 0 THEN 'No'
	END;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH duplicates AS(
SELECT *,
	 ROW_NUMBER() OVER(PARTITION BY ParcelID,
									PropertySplitAddress,
									SalePrice,
									SaleDateConverted,
									LegalReference
									ORDER BY
									uniqueID) AS row_num
FROM Portfolio_Project.dbo.[Nasheville Housing Data])

--run this first to remove duplicates, 
--then comment it out and run SELECT statement below
--DELETE
--FROM duplicates
--WHERE row_num > 1;

SELECT *
FROM duplicates
WHeRE row_num >1;





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From Portfolio_Project.dbo.[Nasheville Housing Data];

ALTER TABLE Portfolio_Project.dbo.[Nasheville Housing Data]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;