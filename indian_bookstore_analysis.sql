CREATE TABLE bookstore_schema.books_inventory (
    store_id VARCHAR(50) NOT NULL,
    book_id VARCHAR(50) PRIMARY KEY,
    book_title TEXT NOT NULL,
    author VARCHAR(150) NOT NULL,
    genre VARCHAR(100) NOT NULL,
    language VARCHAR(50) NOT NULL,
    publisher VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    city_tier VARCHAR(50) NOT NULL,
    sales_channel VARCHAR(50) NOT NULL,
    mrp_inr NUMERIC(10, 2) NOT NULL,
    discount_percent INT NOT NULL,
    selling_price_inr NUMERIC(10, 2) NOT NULL,
    units_sold INT NOT NULL,
    total_revenue_inr NUMERIC(12, 2) NOT NULL,
    average_rating NUMERIC(3, 2) NOT NULL,
    ratings_count INT NOT NULL,
    stock_quantity INT NOT NULL
);

/* 1. Top 5 Book Genres by Total Revenue */

SELECT 
    genre,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(total_revenue_inr), 2) AS total_revenue
FROM bookstore_schema.books_inventory
GROUP BY genre
ORDER BY total_revenue DESC
LIMIT 5;

/* 2. Revenue and Sales Performance by City Tier */

SELECT 
    city_tier,
    COUNT(DISTINCT store_id) AS store_count,
    SUM(units_sold) AS units_sold,
    ROUND(SUM(total_revenue_inr), 2) AS total_revenue,
    ROUND(AVG(selling_price_inr), 2) AS avg_selling_price
FROM bookstore_schema.books_inventory
GROUP BY city_tier
ORDER BY total_revenue DESC;

/* 3. Top 10 Bestselling Books */

SELECT 
    book_title,
    author,
    genre,
    units_sold,
    total_revenue_inr,
    average_rating
FROM bookstore_schema.books_inventory
ORDER BY units_sold DESC
LIMIT 10;

/*4. Sales Channel Comparison (Online vs. Physical Bookstore) */

SELECT 
    sales_channel,
    COUNT(book_id) AS total_books_listed,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(total_revenue_inr), 2) AS total_revenue,
    ROUND(AVG(discount_percent), 2) AS avg_discount_offered
FROM bookstore_schema.books_inventory
GROUP BY sales_channel;

/* 5. Top-Rated Authors with High Reader Engagement */

SELECT 
    author,
    book_title,
    average_rating,
    ratings_count,
    total_revenue_inr
FROM bookstore_schema.books_inventory
WHERE average_rating >= 4.0
ORDER BY ratings_count DESC, average_rating DESC
LIMIT 10;

/* 6. Ranking Top Books Within Each Genre (DENSE_RANK()) */

SELECT 
    genre,
    book_title,
    author,
    total_revenue_inr,
    DENSE_RANK() OVER (PARTITION BY genre ORDER BY total_revenue_inr DESC) AS revenue_rank_in_genre
FROM bookstore_schema.books_inventory;

/* 7. Running Total of Revenue by City Tier (SUM() OVER) */
SELECT 
    city_tier,
    book_title,
    total_revenue_inr,
    SUM(total_revenue_inr) OVER (
        PARTITION BY city_tier 
        ORDER BY total_revenue_inr DESC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_revenue
FROM bookstore_schema.books_inventory;

/* 8. Inventory Stock Alerts & Status (CASE WHEN) */
SELECT 
    store_id,
    book_title,
    stock_quantity,
    units_sold,
    CASE 
        WHEN stock_quantity < 100 THEN '🚨 Critical Restock Needed'
        WHEN stock_quantity BETWEEN 100 AND 200 THEN '⚠️ Low Stock Alert'
        ELSE '✅ Healthy Stock'
    END AS inventory_status
FROM bookstore_schema.books_inventory
ORDER BY stock_quantity ASC;

/* 9. Difference from Category Average (AVG() OVER) */
SELECT 
    genre,
    book_title,
    selling_price_inr,
    ROUND(AVG(selling_price_inr) OVER (PARTITION BY genre), 2) AS avg_genre_price,
    ROUND(selling_price_inr - AVG(selling_price_inr) OVER (PARTITION BY genre), 2) AS price_diff_from_genre_avg
FROM bookstore_schema.books_inventory
ORDER BY genre, price_diff_from_genre_avg DESC;

/* 10. Analytics Challenge: "Technology & Data Genre Performance" */
SELECT book_title,author,
    COUNT(DISTINCT store_id) AS total_stores_stocked,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(total_revenue_inr), 2) AS total_revenue_inr,
    ROUND(AVG(selling_price_inr), 2) AS avg_selling_price_inr,
    ROUND(AVG(average_rating), 2) AS overall_avg_rating
FROM bookstore_schema.books_inventory
WHERE genre = 'Technology & Data'
GROUP BY book_title, author
ORDER BY total_revenue_inr DESC;