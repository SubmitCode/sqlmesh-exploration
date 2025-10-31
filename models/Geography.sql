MODEL (
  name dbo.Geography,
  kind FULL,
  grain GeographyID,
);

SELECT
  GeographyID,
  ZipCodeBKey,
  County,
  City,
  State,
  Country,
  ZipCode
FROM [wh_sample].[dbo].[Geography]
