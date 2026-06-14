CREATE DATABASE DECODELABS;

-- BASIC SELECT 
SELECT ï»¿OrderID,Date,CustomerID,Product,Quantity,UnitPrice,TotalPrice,OrderStatus
FROM ecommerce_orders
limit 10;

-- Filter: Delivered Orders 
SELECT ï»¿OrderID,Date,CustomerID,Product,TotalPrice,OrderStatus
FROM ecommerce_orders
WHERE OrderStatus = 'Delivered'
ORDER BY TotalPrice DESC;

-- Filter: High-Value Order > $1,500
SELECT ï»¿OrderID,CustomerID,Product,TotalPrice,PaymentMethod
FROM ecommerce_orders 
WHERE TotalPrice >1500
order by TotalPrice DESC;

-- Sort by Total Price 
SELECT ï»¿OrderID,Product,Quantity,UnitPrice,TotalPrice
FROM ecommerce_orders 
ORDER BY TotalPrice DESC
LIMIT 10;

-- Count Orders by Status
SELECT OrderStatus,
	   COUNT(*) AS OrderCount 
FROM ecommerce_orders
GROUP BY OrderStatus
ORDER BY OrderCount DESC;

-- Revenue by Product 
SELECT Product,
       COUNT(*) AS OrderCount, 
       SUM(TotalPrice) AS TotalRevenue,
       ROUND(AVG(TotalPrice),2) AS AvgOrderValue
FROM ecommerce_orders
GROUP BY Product
ORDER BY TotalRevenue DESC;

-- Average Order Value by Payment Method 
SELECT PaymentMethod,
	   COUNT(*) AS OrderCount,
       ROUND(AVG(TotalPrice),2) AS AvgOrderValue,
       ROUND(SUM(TotalPrice),2) AS TotalRevenue
FROM ecommerce_orders
GROUP BY PaymentMethod
ORDER BY AvgOrderValue DESC;

-- HAVING:Products With Revenue > $190,000
SELECT Product,
       ROUND(SUM(TotalPrice),2) AS TotalRevenue 
FROM ecommerce_orders
GROUP BY Product
HAVING SUM(TotalPrice)>190000
ORDER BY TotalRevenue DESC;

-- Top 5 Highest-Value Orders 
SELECT ï»¿OrderID,CustomerID,Product,Quantity,UnitPrice,TotalPrice
FROM ecommerce_orders
ORDER BY TotalPrice DESC 
LIMIT 5;

-- Orders WITHOUT a Coupon Code 
SELECT ï»¿OrderID,Product,TotalPrice,PaymentMethod,ReferralSource
FROM ecommerce_orders
WHERE CouponCode IS NULL
ORDER BY TotalPrice DESC 
LIMIT 10;

-- Monthly Revenue Trend 
SELECT YEAR(date) AS Year,
	   MONTH(date) AS MonthNum,
	   MONTHNAME(date) AS MonthName,
       COUNT(*) AS OrderCount,
       ROUND(SUM(TotalPrice),2) AS MonthlyRevenue
FROM ecommerce_orders
GROUP BY YEAR(Date), MONTH(Date), MONTHNAME(Date)
ORDER BY Year, MonthNum;

-- Year-Over-Year Order Count 
SELECT YEAR(Date) AS Year,
	   COUNT(*) AS TotalOrders,
	   ROUND(SUM(TotalPrice),2) AS TotalRevenue,
       ROUND(AVG(TotalPrice),2) AS AvgOrderValue
FROM ecommerce_orders
GROUP BY YEAR(Date)
ORDER BY Year;

-- CASE WHEN: Order Size Category
SELECT 
 CASE
  WHEN TotalPrice < 250 THEN 'Small (Under $250)'
  WHEN TotalPrice < 750 THEN 'Medium ($250 - $750)'
  WHEN TotalPrice < 1500 THEN 'Large ($750 - $1500)'
  ELSE                        'Premium (Over $1500)'
END AS OrderSizeCategory,
COUNT(*) AS OrderCount,
ROUND(SUM(TotalPrice),2) AS CategoryRevenue
FROM ecommerce_orders
GROUP BY OrderSizeCategory
ORDER BY CategoryRevenue DESC;

-- Referral Source Performance
 SELECT ReferralSource,
		count(*) AS OrderCount,
		ROUND(SUM(TotalPrice),2) AS TotalRevenue,
		ROUND(AVG(TotalPrice),2) AS AvgOrderValue,
        COUNT(CASE WHEN OrderStatus = 'Delivered' THEN 1 END) AS DeliveredOrders
FROM ecommerce_orders
GROUP BY ReferralSource
ORDER BY TotalRevenue DESC;

-- Coupon Usage Analysis
SELECT COALESCE(CouponCode, 'No Coupon') AS CouponUsed,
	   COUNT(*) AS OrderCount,
       ROUND(SUM(TotalPrice),2) AS TotalRevenue,
       ROUND(AVG(TotalPrice),2) AS AvgOrderValue
FROM ecommerce_orders
GROUP BY COALESCE(CouponCode, 'No Coupon')
ORDER BY OrderCount DESC;

-- Orders Above Average Price(Subquery)
SELECT ï»¿OrderID,Product,TotalPrice,OrderStatus
FROM ecommerce_orders
WHERE TotalPrice > (SELECT AVG(TotalPrice) FROM ecommerce_orders)
ORDER BY TotalPrice DESC 
LIMIT 10;

-- Revenue share % per Product (Subquery)
SELECT Product,
	   ROUND(SUM(TotalPrice),2) AS ProductRevenue,
       ROUND(SUM(TotalPrice) * 100.0/
		    (SELECT SUM(TotalPrice) FROM ecommerce_orders),2) AS RevenuePct
FROM ecommerce_orders
GROUP BY Product
ORDER BY ProductRevenue DESC;

-- RepeatCustomers 
SELECT CustomerID,
       COUNT(*) AS OrderCount,
       ROUND(SUM(TotalPrice),2) AS TotalSpent,
       ROUND(AVG(TotalPrice),2) AS AvgOrderValue
FROM ecommerce_orders
GROUP BY CustomerID
HAVING COUNT(*) > 1
ORDER BY OrderCount DESC, TotalSpent DESC
LIMIT 10;

-- RANK:Top Product by Revenue 
SELECT 
  RANK() OVER ( ORDER BY SUM(TotalPrice) DESC) AS RevenueRank,
  ROUND(SUM(TotalPrice),2) AS TotalRevenue 
FROM ecommerce_orders
GROUP BY Product
ORDER BY RevenueRank;

-- Cancellation Rate by Product
SELECT Product,
       COUNT(*) AS TotalOrders,
       COUNT(CASE WHEN OrderStatus = 'Cancelled' THEN 1 END) AS CancelledOrders,
       COUNT(CASE WHEN OrderStatus = 'Returned' THEN 1 END) AS ReturnedOrders,
       ROUND(
	     COUNT(CASE WHEN OrderStatus IN ('Cancelled', 'Returned') THEN 1 END) * 100.0 / COUNT(*), 2) AS AttritionRatePct
FROM ecommerce_orders
GROUP BY Product
ORDER BY AttritionRatePct DESC;