/*
	Cleaning Data in SQL Queries
*/

SELECT *
From NashvilleHousing


-- Standardizing date format

SELECT SaleDateConverted
From NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;
Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)


--Populate Property Address Data

Select *	
From NashvilleHousing
--where PropertyAddress is not null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is Null

Update a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is Null


--Breaking address into individual columns [Address, City, State]
 

SELECT PropertyAddress
From NashvilleHousing

SELECT Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) as Address,
Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
From NashvilleHousing

SELECT OwnerAddress
From NashvilleHousing

SELECT
ParseName(Replace(OwnerAddress, ',', '.'), 3),
ParseName(Replace(OwnerAddress, ',', '.'), 2),
ParseName(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = ParseName(Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = ParseName(Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = ParseName(Replace(OwnerAddress, ',', '.'), 1)

SELECT *
From NashvilleHousing


-- Change Y and N to Yes and No in SoldAsVaccant

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 When SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 When SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END


--Removing Duplicates

WITH RowNumCTE AS(
Select *, 
	   ROW_NUMBER() OVER (
	   Partition By ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					ORDER BY
						UniqueID
						) row_num
From NashvilleHousing
)
--DELETE
SELECT *
From RowNumCTE
Where row_num > 1



-- DELETE UNUSED COLUMNS

SELECT *
From NashvilleHousing

Alter Table NashvilleHousing
DROP Column PropertyAddress, OwnerAddress, TaxDistrict
Alter Table NashvilleHousing
DROP Column SaleDate



SELECT *
FROM NashvilleHousing