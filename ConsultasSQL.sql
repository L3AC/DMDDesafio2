
/*PREGUNTA A*/


SELECT 
    pc.EnglishProductCategoryName AS Categoria,
    psc.EnglishProductSubcategoryName AS Subcategoria,
    d.CalendarYear AS Anio,
    d.CalendarQuarter AS Trimestre,
    SUM(v.OrderQuantity) AS VolumenTotalVentas
FROM (
    SELECT ProductKey, OrderDateKey, OrderQuantity FROM FactInternetSales
    UNION ALL
    SELECT ProductKey, OrderDateKey, OrderQuantity FROM FactResellerSales
) v
INNER JOIN DimProduct p ON v.ProductKey = p.ProductKey
INNER JOIN DimProductSubcategory psc ON p.ProductSubcategoryKey = psc.ProductSubcategoryKey
INNER JOIN DimProductCategory pc ON psc.ProductCategoryKey = pc.ProductCategoryKey
INNER JOIN DimDate d ON v.OrderDateKey = d.DateKey
GROUP BY 
    pc.EnglishProductCategoryName,
    psc.EnglishProductSubcategoryName,
    d.CalendarYear,
    d.CalendarQuarter
ORDER BY 
    Anio, Trimestre, VolumenTotalVentas DESC;


/*PREGUNTA B*/

WITH VentasInternet AS (
    SELECT 
        SalesTerritoryKey,
        SUM(SalesAmount) AS Ventas_Internet,
        SUM(SalesAmount - TotalProductCost) AS Rentabilidad_Internet
    FROM FactInternetSales
    GROUP BY SalesTerritoryKey
),
VentasReseller AS (
    SELECT 
        SalesTerritoryKey,
        SUM(SalesAmount) AS Ventas_Reseller,
        SUM(SalesAmount - TotalProductCost) AS Rentabilidad_Reseller
    FROM FactResellerSales
    GROUP BY SalesTerritoryKey
)
SELECT 
    st.SalesTerritoryCountry AS Pais,
    st.SalesTerritoryRegion AS Region,
    ISNULL(vi.Ventas_Internet, 0) AS Ventas_Internet,
    ISNULL(vr.Ventas_Reseller, 0) AS Ventas_Reseller,
    ISNULL(vi.Rentabilidad_Internet, 0) AS Rentabilidad_Internet,
    ISNULL(vr.Rentabilidad_Reseller, 0) AS Rentabilidad_Reseller,
    (ISNULL(vi.Rentabilidad_Internet, 0) + ISNULL(vr.Rentabilidad_Reseller, 0)) AS Rentabilidad_Total
FROM DimSalesTerritory st
LEFT JOIN VentasInternet vi ON st.SalesTerritoryKey = vi.SalesTerritoryKey
LEFT JOIN VentasReseller vr ON st.SalesTerritoryKey = vr.SalesTerritoryKey
ORDER BY 
    Rentabilidad_Total DESC;


/*PREGUNTA C*/

WITH RentabilidadGeneral AS (
    SELECT 
        v.ProductKey,
        SUM(v.SalesAmount - v.TotalProductCost) AS MargenAcumulado
    FROM (
        SELECT ProductKey, SalesAmount, TotalProductCost FROM FactInternetSales
        UNION ALL
        SELECT ProductKey, SalesAmount, TotalProductCost FROM FactResellerSales
    ) v
    GROUP BY v.ProductKey
),
Top10Articulos AS (
    SELECT TOP 10 
        ProductKey, 
        MargenAcumulado
    FROM RentabilidadGeneral
    ORDER BY MargenAcumulado DESC
)
SELECT 
    p.EnglishProductName AS Producto,
    d.CalendarYear AS Anio,
    d.CalendarQuarter AS Trimestre,
    SUM(v.SalesAmount - v.TotalProductCost) AS RentabilidadTrimestre
FROM (
    SELECT ProductKey, OrderDateKey, SalesAmount, TotalProductCost FROM FactInternetSales
    UNION ALL
    SELECT ProductKey, OrderDateKey, SalesAmount, TotalProductCost FROM FactResellerSales
) v
INNER JOIN Top10Articulos top10 ON v.ProductKey = top10.ProductKey
INNER JOIN DimProduct p ON v.ProductKey = p.ProductKey
INNER JOIN DimDate d ON v.OrderDateKey = d.DateKey
GROUP BY 
    p.EnglishProductName,
    d.CalendarYear,
    d.CalendarQuarter
ORDER BY 
    p.EnglishProductName, Anio, Trimestre;
