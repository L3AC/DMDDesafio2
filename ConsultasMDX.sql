
/*PREGUNTA A*/


SELECT 
    NON EMPTY 
    (
        [Due Date].[Calendar Year].[Calendar Year].Members * 
        [Due Date].[Calendar Quarter].[Calendar Quarter].Members
    ) ON COLUMNS,
    NON EMPTY 
    (
        [Dim Product].[English Product Category Name].[English Product Category Name].Members * 
        [Dim Product].[English Product Subcategory Name].[English Product Subcategory Name].Members
    ) ON ROWS
FROM [Adventure Works DW2019]
WHERE 
(
    [Measures].[Order Quantity]
);


/*PREGUNTA B*/

WITH MEMBER [Measures].[Rentabilidad Internet] AS 
    [Measures].[Sales Amount - Fact Internet Sales] - [Measures].[Total Product Cost - Fact Internet Sales]
MEMBER [Measures].[Rentabilidad Reseller] AS 
    [Measures].[Sales Amount] - [Measures].[Total Product Cost]
MEMBER [Measures].[Rentabilidad Total] AS 
    [Measures].[Rentabilidad Internet] + [Measures].[Rentabilidad Reseller]
SELECT 
    {
        [Measures].[Sales Amount - Fact Internet Sales],
        [Measures].[Sales Amount],
        [Measures].[Rentabilidad Internet],
        [Measures].[Rentabilidad Reseller],
        [Measures].[Rentabilidad Total]
    } ON COLUMNS,
    NON EMPTY 
    (
        [Dim Sales Territory].[Sales Territory Country].[Sales Territory Country].Members * 
        [Dim Sales Territory].[Sales Territory Region].[Sales Territory Region].Members
    ) ON ROWS
FROM [Adventure Works DW2019];


/*PREGUNTA C*/

WITH 
MEMBER [Measures].[Rentabilidad Total] AS 
    ([Measures].[Sales Amount - Fact Internet Sales] - [Measures].[Total Product Cost - Fact Internet Sales]) +
    ([Measures].[Sales Amount] - [Measures].[Total Product Cost])

SELECT 
    NON EMPTY 
    (
        [Due Date].[Calendar Year].[Calendar Year].Members * 
        [Due Date].[Calendar Quarter].[Calendar Quarter].Members
    ) ON COLUMNS,
    TOPCOUNT(
        [Dim Product].[English Product Name].[English Product Name].Members, 
        10, 
        [Measures].[Rentabilidad Total]
    ) ON ROWS
FROM [Adventure Works DW2019]
WHERE 
(
    [Measures].[Rentabilidad Total]
);

