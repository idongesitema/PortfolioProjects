--Cleaning Data in SQL Queries 

SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData


--Standardize Date format

SELECT SalesDate, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousingData

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD SalesDateFixed Date;

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET SalesDateFixed = CONVERT(Date,SaleDate)



--Populate Property Address Data
SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
	

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Breaking out Address into Individual Column (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousingData
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress +1), LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousingData


ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress +1), LEN(PropertyAddress))





SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousingData


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM PortfolioProject..NashvilleHousingData 


ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)


ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD OwnerSplitState nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)



--Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN  SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousingData


UPDATE PortfolioProject..NashvilleHousingData
SET SoldAsVacant = CASE WHEN  SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END


--Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
			ORDER BY
				UniqueID) row_num
FROM PortfolioProject..NashvilleHousingData
)
 SELECT *
 FROM RowNumCTE
 WHERE row_num > 1
 ORDER BY PropertyAddress


 --Delete Unused Columns

 SELECT *
 FROM PortfolioProject.dbo.NashvilleHousingData

 ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
	DROP COLUMN SaleDate, PropertyAddress, OwnerAddress, TaxDistrict