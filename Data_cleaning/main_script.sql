-- 1. Just to see the whole data
SELECT * FROM na shvillehousingdata;
DESCRIBE nashvillehousingdata;


-- 2. Change the format SaleDate 
ALTER TABLE nashvillehousingdata
MODIFY COLUMN SaleDate date;


SELECT SaleDate FROM nashvillehousingdata;

-- 3. Populate Property Adress data
-- change empty data to NULL
SET SQL_SAFE_UPDATES = 0;
UPDATE nashvillehousingdata
SET PropertyAddress = NULL
WHERE PropertyAddress='';
SET SQL_SAFE_UPDATES = 1;

-- see the null data
SELECT * FROM nashvillehousingdata
WHERE PropertyAddress IS NULL;

-- look at the rows UniquiID and ParcelID with similar propertyAdress
-- Using JOIN DISTINCT
SELECT DISTINCT a.UniqueID, a.ParcelID, a.PropertyAddress
FROM nashvillehousingdata AS a
INNER JOIN nashvillehousingdata AS b
	ON a.UniqueID <> b.UniqueID AND a.PropertyAddress=b.PropertyAddress;

-- Using Join subqueries 
SELECT UniqueID, ParcelID, a.PropertyAddress
FROM nashvillehousingdata AS a
INNER JOIN (
SELECT PropertyAddress
FROM nashvillehousingdata
GROUP BY PropertyAddress
HAVING COUNT(UniqueID)>1
)AS b
	ON a.PropertyAddress= b.PropertyAddress;

-- From the queary above, we know same parcelID have the same propertyadress. Looking for duplicate parcelID
-- to make sure our Hypothesis
SELECT DISTINCT a.UniqueID, a.ParcelID, a.PropertyAddress
FROM nashvillehousingdata as a
INNER JOIN nashvillehousingdata as b
	ON a.UniqueID <> b.UniqueID AND a.ParcelID = b.ParcelID;

-- fill the null value with the same value based on the value on ParcelID
SELECT DISTINCT a.UniqueID, a.ParcelID, a.PropertyAddress, b.PropertyAddress,
				IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashvillehousingdata as a
INNER JOIN nashvillehousingdata as b
	ON a.UniqueID <> b.UniqueID AND a.ParcelID = b.ParcelID
WHERE a.PropertyAddress IS NULL;

-- Update the data
SET SQL_SAFE_UPDATES = 0;
UPDATE nashvillehousingdata AS a
INNER JOIN nashvillehousingdata AS b
	ON a.UniqueID <> b.UniqueID AND a.ParcelID = b.ParcelID
SET a.PropertyAddress =IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;
SET SQL_SAFE_UPDATES = 1;


-- 3. Breaking out PropertyAddress into individual column (Adress, City) 
-- see the data
SELECT PropertyAddress FROM nashvillehousingdata;
-- Break the position
SELECT
PropertyAddress,
SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1 ) as Address, #-1 remove comma
SUBSTRING(PropertyAddress, POSITION(','IN PropertyAddress) + 2 , CHAR_LENGTH(PropertyAddress)) as City #+2 remove comma and space
FROM nashvillehousingdata;

-- Update the data
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE nashvillehousingdata
ADD PropertySplitAdress NVARCHAR(255);
UPDATE nashvillehousingdata
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1 );

ALTER TABLE nashvillehousingdata
ADD PropertySplitCity NVARCHAR(255);
UPDATE nashvillehousingdata
SET PropertySplitCity =  SUBSTRING(PropertyAddress, POSITION(','IN PropertyAddress) + 2 , CHAR_LENGTH(PropertyAddress));

SET SQL_SAFE_UPDATES=1;

-- see the change
SELECT PropertyAddress, PropertySplitAdress, PropertySplitCity FROM nashvillehousingdata;


-- 4. Breakthrough the owneradress
-- see the data
SELECT 
	OwnerAddress,
	SUBSTRING_INDEX(OwnerAddress,',',1),
    LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1)),
    LTRIM(SUBSTRING_INDEX(OwnerAddress,',',-1))
FROM nashvillehousingdata;

-- update the data
SET SQL_SAFE_UPDATES=0;

ALTER TABLE nashvillehousingdata
ADD SplitOwnerAdress NVARCHAR(255);
UPDATE nashvillehousingdata
SET SplitOwnerAdress=SUBSTRING_INDEX(OwnerAddress,',',1);

ALTER TABLE nashvillehousingdata
ADD SplitOwnerCity NVARCHAR(255);
UPDATE nashvillehousingdata
SET SplitOwnerCity = LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1));

ALTER TABLE nashvillehousingdata
ADD SplitOwnerState NVARCHAR(255);
UPDATE nashvillehousingdata
SET SplitOwnerState = LTRIM(SUBSTRING_INDEX(OwnerAddress,',',-1));

-- See the change
SELECT OwnerAddress, SplitOwnerAdress, SplitOwnerCity, SplitOwnerState FROM nashvillehousingdata;

-- Rename the column in order to consistent with query befor
ALTER TABLE nashvillehousingdata
RENAME COLUMN SplitOwnerAdress TO OwnerSplitAddress;
ALTER TABLE nashvillehousingdata
RENAME COLUMN SplitOwnerCity TO OwnerSplitCity;
ALTER TABLE nashvillehousingdata
RENAME COLUMN SplitOwnerState TO OwnerSplitState;

SET SQL_SAFE_UPDATES=1;

-- 5.Change Y and N into Yes and N in "Sold As Vacant" Field
-- See the data
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousingdata
GROUP BY 1
ORDER BY 2;

-- check non desirable data
SELECT * FROM nashvillehousingdata
WHERE SoldAsVacant NOT IN ('Y', 'Yes', 'N', 'No');

-- Delete non desirable data
SET SQL_SAFE_UPDATES=0;
DELETE FROM nashvillehousingdata
WHERE SoldAsVacant NOT IN ('Y', 'Yes', 'N', 'No');

SELECT 	SoldAsVacant ,
		CASE 	WHEN SoldAsVacant = 'Y' THEN 'Yes'
				WHEN SOldAsVacant = 'N' THEN 'NO'
				ELSE SoldAsVacant
		END
FROM nashvillehousingdata;


-- update the data
UPDATE nashvillehousingdata
SET SoldAsVacant= CASE 	WHEN SoldAsVacant = 'Y' THEN 'Yes'
				WHEN SOldAsVacant = 'N' THEN 'NO'
				ELSE SoldAsVacant
		END;

SET SQL_SAFE_UPDATES=1;
-- 6. Delete Duplicate data
-- see duplicate data
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() over (
	PARTITION BY 	ParcelID,
					PropertyAddress,
                    SalePrice,
                    SaleDate, 
                    LegalReference
	ORDER BY UniqueID
	) row_num
FROM nashvillehousingdata
)
SELECT *
FROM RowNumCTE
WHERE row_num>1;

-- insert unique data int temp table
DROP TEMPORARY TABLE IF EXISTS uniqueTable;
CREATE TEMPORARY TABLE uniqueTable LIKE nashvillehousingdata;
ALTER TABLE uniqueTable
ADD column row_num INT;
INSERT INTO uniqueTable
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() over (
	PARTITION BY 	ParcelID,
					PropertyAddress,
                    SalePrice,
                    SaleDate, 
                    LegalReference
	ORDER BY UniqueID
	) row_num
FROM nashvillehousingdata
)
SELECT *
FROM RowNumCTE
WHERE row_num=1;

-- see the data
SELECT * FROM uniqueTable;


