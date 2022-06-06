
/*
Cleaning Data in SQL Queries
*/
-- delete from houses where uniqueid != '01'

select *from houses 

select count(*) from houses where OwnerSplitAddress is null
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

update houses set saledate = to_date(saledate, 'YYYY-MM-DD');

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select propertyaddress from houses where propertyaddress is null

select a.uniqueid, a.parcelid, a.propertyaddress, b.uniqueid, b.parcelid, b.propertyaddress, COALESCE(a.propertyaddress, b.propertyaddress)
from houses a join houses b on a.parcelid = b.parcelid
and a.uniqueid != b.uniqueid
where a.propertyaddress is null

update houses set propertyaddress = COALESCE(houses.propertyaddress, b.propertyaddress) 
from houses b 
where houses.parcelid = b.parcelid and houses.uniqueid != b.uniqueid and houses.propertyaddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From houses
--Where PropertyAddress is null
--order by ParcelID

SELECT
substring(PropertyAddress, 1, position(',' in PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, position(',' in PropertyAddress) + 2 , length(PropertyAddress)) as Address

From houses


ALTER TABLE houses
Add column PropertySplitAddress text;

Update houses
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, position(',' in PropertyAddress) -1 )


ALTER TABLE houses
Add column PropertySplitCity text;

Update houses
SET PropertySplitCity = SUBSTRING(PropertyAddress, position(',' in PropertyAddress) + 2 , length(PropertyAddress))

Select *
From houses



Select OwnerAddress
From houses


Select
split_part(OwnerAddress, ', ', 1)
,split_part(OwnerAddress, ', ', 2)
,split_part(OwnerAddress, ', ', 3)
From houses



ALTER TABLE houses
Add column OwnerSplitAddress text;

Update houses
SET OwnerSplitAddress = split_part(OwnerAddress, ', ', 1)


ALTER TABLE houses
Add column OwnerSplitCity text;

Update houses
SET OwnerSplitCity = split_part(OwnerAddress, ', ', 2)


ALTER TABLE houses
Add column OwnerSplitState text;

Update houses
SET OwnerSplitState = split_part(OwnerAddress, ', ', 3)


Select *
From houses

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From houses
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From houses


Update houses
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

select *, row_number() over (partition by parcelid, propertyaddress, saleprice , saledate, legalreference 
							 order by uniqueid) row_num
							 from houses
order by parcelid

with RowNumCTE AS(
select *, row_number() over (partition by parcelid, propertyaddress, saleprice , saledate, legalreference 
							 order by uniqueid) row_num
							 from houses
order by parcelid
)

select *from RowNumCTE where row_num>1
order by propertyaddress



delete from houses hs using (select uniqueid, row_number() over (partition by parcelid, propertyaddress, saleprice , saledate, legalreference 
							 order by uniqueid) as row_num
							 from houses) sub where sub.uniqueid = hs.uniqueid and row_num>1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

alter table houses drop column OwnerAddress

alter table houses drop column PropertyAddress 

alter table houses drop column TaxDistrict
