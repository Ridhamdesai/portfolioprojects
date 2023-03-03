--Cleaning Data in SQL Queries


--View full dataset
select * from NashvilleHousing$

--Selecting Sales Date

select SaleDate, Convert(Date,SaleDate)
from NashvilleHousing$

-- Changing the date format (Adding the column and insterting the new date format in the column)
 Alter Table NashvilleHousing$
 Add SaleDateConverted Date;

 Update NashvilleHousing$
 Set SaleDateConverted = COnvert(Date,SaleDate)

 --Populate Property Address Date
 -- There are certain Property Address that is empty
 --As the Parcel ID corresponds to Property Address, let's populate Property Address with Parcel ID


select a.ParcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing$ a
Join NashvilleHousing$ b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing$ a
Join NashvilleHousing$ b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null

-- Breaking down PropertyAddress into Individual COlumns (Address, city State)

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as PropertySplitAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as PropertySplitCity
from NashvilleHousing$

Alter Table NashvilleHousing$
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing$
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing$
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing$
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

-- Breaking down OwnerAddress into Individual COlumns (Address, city State)

Select OwnerAddress
from NashvilleHousing$
Where OwnerAddress is not null

Select
PARSENAME(Replace(OwnerAddress, ',','.') ,3) as OwnerSplitAddress,
PARSENAME(Replace(OwnerAddress, ',','.') ,2 ) as OwnerSplitCity,
PARSENAME(Replace(OwnerAddress, ',','.') ,1 ) as OwnerSplitState
from NashvilleHousing$
Where OwnerAddress is not null

Alter Table NashvilleHousing$
Add OwnerSplitState Nvarchar(255);

Alter Table NashvilleHousing$
Add OwnerSplitCity Nvarchar(255);

Alter Table NashvilleHousing$
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing$
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.') ,3)

Update NashvilleHousing$
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.') ,2)

Update NashvilleHousing$
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.') ,1)


--As there are Y, N, Yes and No in Sold as Vacant Field, let's change Y and N to Yes and No in Sold as Vacant field

Select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing$
Group By SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant End
from NashvilleHousing$

Update NashvilleHousing$
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant End


--Let's remove duplicates
With RowNumCTE AS (

Select * ,
	ROW_NUMBER() Over (
	Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order By UniqueID) row_num

from NashvilleHousing$
)

Delete
from RowNumCTE
where row_num > 1

-- Delete Unused Columns

Select * from portfolio..NashvilleHousing$

ALter Table NashvilleHousing$
Drop COlumn OwnerAddress, PropertyAddress

ALter Table NashvilleHousing$
Drop COlumn SaleDate



