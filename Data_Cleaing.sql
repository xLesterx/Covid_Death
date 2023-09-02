
--CLEANING DATA IN SQL QUERIES

SELECT *
FROM PortfolioProject2.dbo.Nashville_Housing


--STANDARIZE DATA FORMAT

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject2.dbo.Nashville_Housing

UPDATE [Nashville_Housing ]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Nashville_Housing
ADD SalesDateConverted Date;

UPDATE [Nashville_Housing ]
SET SalesDateConverted = CONVERT(Date,SaleDate)

SELECT SalesDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject2.dbo.Nashville_Housing


--POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM PortfolioProject2.dbo.Nashville_Housing
ORDER BY ParcelID


SELECT PropertyAddress
FROM PortfolioProject2.dbo.Nashville_Housing
WHERE PropertyAddress is Null

SELECT A.ParcelID, A.UniqueID, A.PropertyAddress , B.ParcelID, B.UniqueID, B.PropertyAddress,
		ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject2.dbo.Nashville_Housing AS A
JOIN PortfolioProject2.dbo.Nashville_Housing AS B
	ON A.ParcelID =  B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress is Null


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject2.dbo.Nashville_Housing AS A
JOIN PortfolioProject2.dbo.Nashville_Housing AS B
	ON A.ParcelID =  B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress is Null


--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMN (ADDRESSM CITY, STATE)(PUTTING DELIMITERS)
SELECT PropertyAddress
FROM PortfolioProject2.dbo.Nashville_Housing

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)  AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))  AS Address
FROM PortfolioProject2.dbo.Nashville_Housing


ALTER TABLE Nashville_Housing
ADD Property_Split_Address nvarchar(255);

UPDATE [Nashville_Housing ]
SET Property_Split_Address = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE Nashville_Housing
ADD Property_Split_City nvarchar(255);

UPDATE [Nashville_Housing ]
SET Property_Split_City = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


SELECT * 
FROM PortfolioProject2.dbo.Nashville_Housing



SELECT OwnerAddress
FROM PortfolioProject2.dbo.Nashville_Housing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject2.dbo.Nashville_Housing

ALTER TABLE Nashville_Housing
ADD Owner_Split_Address nvarchar(255);

UPDATE [Nashville_Housing ]
SET Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER TABLE Nashville_Housing
ADD Property_Split_City nvarchar(255);

UPDATE [Nashville_Housing ]
SET Property_Split_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE Nashville_Housing
ADD Owner_Split_State nvarchar(255);

UPDATE [Nashville_Housing ]
SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * 
FROM PortfolioProject2.dbo.Nashville_Housing


--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject2.dbo.Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM PortfolioProject2.dbo.Nashville_Housing

UPDATE  [Nashville_Housing ]
SET SoldAsVacant =  CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

SELECT SoldAsVacant
FROM PortfolioProject2.dbo.Nashville_Housing


--REMOVE DUPLICATES 

WITH RowNumCTE AS (
SELECT*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num

FROM PortfolioProject2.dbo.Nashville_Housing
)

DELETE
FROM RowNumCTE 
WHERE row_num > 1




-- DELETE UNUSED COLUMNS

SELECT *
FROM PortfolioProject2.dbo.Nashville_Housing

ALTER TABLE PortfolioProject2.dbo.Nashville_Housing
DROP COLUMN  OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
