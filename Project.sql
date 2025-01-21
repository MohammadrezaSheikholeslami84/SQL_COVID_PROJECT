-- Cleaning Data is SQL Queries

SELECT * FROM NashvilleHousing


-- Standardize Date Format

SELECT SaleDate,CONVERT(date,SaleDate) FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


-- Populate Property Address data

SELECT NH1.ParcelID , NH1.PropertyAddress , NH2.ParcelID , NH2.PropertyAddress , ISNULL(NH1.PropertyAddress,NH2.PropertyAddress) ,  
                               ISNULL(NH2.PropertyAddress,NH1.PropertyAddress)
FROM NashvilleHousing AS NH1
JOIN NashvilleHousing AS NH2
ON NH1.ParcelID = NH2.ParcelID AND NH1.[UniqueID ] <> NH2.[UniqueID ]
WHERE NH1.PropertyAddress IS NULL OR NH2.PropertyAddress IS NULL

UPDATE NH1
SET PropertyAddress = ISNULL(NH1.PropertyAddress,NH2.PropertyAddress)
FROM NashvilleHousing AS NH1
JOIN NashvilleHousing AS NH2
ON NH1.ParcelID = NH2.ParcelID AND NH1.[UniqueID ] <> NH2.[UniqueID ]

-- Breaking out Address ito Individual Columns ( Address , City , State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT PropertyAddress , SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) - 1) AS  Address1,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress)) AS Address2
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD ProppertSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET ProppertSplitAddress =  SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD ProppertSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET ProppertSplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress))


SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) , PARSENAME(REPLACE(OwnerAddress,',','.'),2) , PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-- Change Y and N to Yes and NO in "Sold as Vacant" Field

SELECT SoldAsVacant FROM NashvilleHousing
WHERE SoldAsVacant = 'Y' or SoldAsVacant = 'N'


SELECT SoldAsVacant ,ISNULL( (CASE 
                      WHEN SoldAsVacant = 'Y' THEN 'Yes'
					  WHEN SoldAsVacant = 'N' THEN 'No'
					  END),SoldAsVacant)
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = ISNULL( (CASE 
                      WHEN SoldAsVacant = 'Y' THEN 'Yes'
					  WHEN SoldAsVacant = 'N' THEN 'No'
					  END),SoldAsVacant)


-- Remove Duplicates
WITH CTE1 AS (
SELECT  ROW_NUMBER() Over ( PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY [UniqueID ]) AS row_num , *
FROM NashvilleHousing
)
DELETE CTE1
WHERE row_num > 1


SELECT * FROM NashvilleHousing

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict , PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

