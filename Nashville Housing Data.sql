Select Top 1000
    *
From Nashville

--Standardize Date Format

Select 
    SaleDate
    ,CONVERT(DATE, SaleDate) as New_Date_Format
From Nashville

-- Update Nashville
-- Set SaleDate = CONVERT(DATE, SaleDate)
--Code didn't update SaleDate column to YYYY-MM-DD

Alter Table Nashville
Add SaleDateConverted Date;
Update Nashville
Set SaleDateConverted = CONVERT(Date, SaleDate)

Select 
    SaleDateConverted
From Nashville

--Populate Property Address Data

Select
    *
From Nashville
--Where PropertyAddress is NULL
Order by ParcelID

Select 
    a.ParcelID
    ,a.PropertyAddress
    ,b.ParcelID
    ,b.PropertyAddress
    ,ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashville a
JOIN Nashville b ON
    a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashville a
JOIN Nashville b ON
    a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
--Where a.PropertyAddress is NULL
--Didn't add WHERE statement, updated correctly though


--Breaking out Address into Individual columns


--Property Address

Select 
    PropertyAddress
From Nashville

Select
Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
,Substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
From Nashville


Alter Table Nashville
Add Property_St nvarchar(255);
Update Nashville
Set Property_St = Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter Table Nashville
Add City nvarchar(255);
Update Nashville
Set City = Substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

Select 
    Property_St
    ,City
From Nashville

--Owner Address

SELECT
    OwnerAddress
From Nashville

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From Nashville

Alter Table Nashville
Add ownerProperty_St nvarchar(255);
Alter Table Nashville
Add ownerCity nvarchar(255);
Alter Table Nashville
Add ownerState nvarchar(255);

Update Nashville
Set ownerProperty_St = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Update Nashville
Set ownerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Update Nashville
Set ownerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select 
    ownerProperty_St
    ,ownerCity
    ,ownerState
From Nashville

--Changing Y and N 

Select Distinct
    SoldAsVacant
    ,Count(SoldAsVacant)
From Nashville
Group by SoldAsVacant
Order by 2

Select
    SoldAsVacant
    ,CASE When SoldAsVacant = 'Y' Then 'Yes'
          When SoldAsVacant = 'N' Then 'No'
    Else SoldAsVacant
    END
From Nashville
Where SoldAsVacant in ('Y','N')

Update Nashville
Set SoldAsVacant = 
CASE When SoldAsVacant = 'Y' Then 'Yes'
          When SoldAsVacant = 'N' Then 'No'
    Else SoldAsVacant
END

--Remove Duplicates


WITH rowNumCTE AS (
Select 
    *
    ,ROW_NUMBER() OVER (
        Partition by ParcelID
        ,PropertyAddress
        ,SalePrice
        ,SaleDate
        ,LegalReference
        Order by
            UniqueID
    ) row_num
From Nashville
--Order by ParcelID
)
Select *
From rowNumCTE
Where row_num > 1

--Delete Unused Columns

Alter Table Nashville
Drop Column
    OwnerAddress
    ,TaxDistrict
    ,PropertyAddress

Alter Table Nashville
Drop Column
    SaleDate

Select *
From Nashville
