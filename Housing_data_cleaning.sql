select SaleDate, CONVERT(date,Saledate)
from Portfolioproject2.dbo.Housing

update Portfolioproject2.dbo.Housing
SET SaleDate = CONVERT(Date,SaleDate)


select SaleDateREC
from Portfolioproject2.dbo.Housing
-- CONVERT ISINT WORKING SO TRYING A DIFFERENT METHOD
ALTER TABLE Portfolioproject2.dbo.Housing
ADD SaleDateREC Date

update Portfolioproject2.dbo.Housing
SET SaleDateREC = CONVERT(Date,SaleDate)


-- Populate Property Address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolioproject2.dbo.Housing a
JOIN Portfolioproject2.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolioproject2.dbo.Housing a
JOIN Portfolioproject2.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out adresses into individual columns


Select PropertyAddress
From Portfolioproject2.dbo.housing


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From Portfolioproject2.dbo.housing

ALTER TABLE Housing
Add PropertySplitAddress Nvarchar(255);

Update Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Housing
Add PropertySplitCity Nvarchar(255);

Update Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select OwnerAddress
From Portfolioproject2.dbo.Housing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject2.dbo.Housing

ALTER TABLE Housing
Add Owneradress1 Nvarchar(255);
Update Housing
SET Owneradress1 =PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Housing
Add OwneradressCity Nvarchar(255);
Update Housing
SET OwneradressCity =PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Housing
Add OwneradressState Nvarchar(255);
Update Housing
SET OwneradressState =PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject2.dbo.Housing
Group by SoldAsVacant


Select SoldAsVacant
,  CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject2.dbo.Housing

Update Housing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


	   -- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) 
				 as row_num

From PortfolioProject2.dbo.Housing)

--Delete 
--From RowNumCTE
--Where row_num > 1

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From PortfolioProject2.dbo.Housing



