-- 🛒 SUPERMART INVENTORY MANAGEMENT SYSTEM
-- Advanced Grocery Items Table with Complex Features

CREATE DATABASE IF NOT EXISTS supermart_db;
USE supermart_db;

-- 🎯 MAIN GROCERY ITEMS TABLE
CREATE TABLE IF NOT EXISTS grocery_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    sku_code VARCHAR(20) UNIQUE NOT NULL COMMENT 'Stock Keeping Unit',
    product_name VARCHAR(150) NOT NULL,
    brand_name VARCHAR(100),
    category_id INT,
    subcategory VARCHAR(75),
    
    -- 💰 PRICING INFORMATION
    cost_price DECIMAL(10,2) NOT NULL COMMENT 'Supplier cost',
    selling_price DECIMAL(10,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0.00,
    discount_price DECIMAL(10,2) GENERATED ALWAYS AS (selling_price * (1 - discount_percent/100)) STORED,
    profit_margin DECIMAL(8,2) GENERATED ALWAYS AS (selling_price - cost_price) STORED,
    margin_percent DECIMAL(5,2) GENERATED ALWAYS AS (((selling_price - cost_price) / cost_price) * 100) STORED,
    
    -- 📦 INVENTORY MANAGEMENT
    current_stock INT NOT NULL DEFAULT 0,
    min_stock_level INT DEFAULT 5,
    max_stock_level INT DEFAULT 100,
    reorder_quantity INT DEFAULT 25,
    stock_status ENUM('in_stock', 'low_stock', 'out_of_stock', 'discontinued') DEFAULT 'in_stock',
    
    -- 🏷️ PRODUCT DETAILS
    unit_type ENUM('piece', 'kg', 'gram', 'liter', 'ml', 'pack', 'bottle', 'can', 'box'),
    weight DECIMAL(8,3),
    weight_unit VARCHAR(10),
    size VARCHAR(50),
    
    -- 🏢 SUPPLIER INFORMATION
    supplier_id INT,
    manufacturer VARCHAR(100),
    country_of_origin VARCHAR(50),
    
    -- ⏰ SHELF LIFE MANAGEMENT
    is_perishable BOOLEAN DEFAULT FALSE,
    expiry_date DATE,
    manufacture_date DATE,
    shelf_life_days INT,
    days_until_expiry INT GENERATED ALWAYS AS (DATEDIFF(expiry_date, CURDATE())) VIRTUAL,
    expiry_status ENUM('fresh', 'warning', 'urgent', 'expired') GENERATED ALWAYS AS (
        CASE 
            WHEN expiry_date IS NULL THEN 'fresh'
            WHEN DATEDIFF(expiry_date, CURDATE()) > 30 THEN 'fresh'
            WHEN DATEDIFF(expiry_date, CURDATE()) BETWEEN 8 AND 30 THEN 'warning'
            WHEN DATEDIFF(expiry_date, CURDATE()) BETWEEN 1 AND 7 THEN 'urgent'
            ELSE 'expired'
        END
    ) VIRTUAL,
    
    -- 🏷️ TAGS & CLASSIFICATIONS
    tags SET('organic', 'gluten_free', 'vegan', 'vegetarian', 'local', 'imported', 'bestseller', 'new', 'sale', 'eco_friendly'),
    dietary_info JSON,
    
    -- 📊 ANALYTICS & TRACKING
    total_sold INT DEFAULT 0,
    last_restocked DATE,
    times_restocked INT DEFAULT 0,
    popularity_score INT DEFAULT 0,
    
    -- 🖼️ MEDIA & DESCRIPTIONS
    image_url VARCHAR(255),
    product_description TEXT,
    ingredients JSON,
    nutritional_info JSON,
    
    -- ⚙️ SYSTEM FIELDS
    date_added DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    added_by_user INT,
    is_active BOOLEAN DEFAULT TRUE,
    version INT DEFAULT 1,
    
    -- 🔍 INDEXES FOR PERFORMANCE
    INDEX idx_category (category_id),
    INDEX idx_supplier (supplier_id),
    INDEX idx_price_range (selling_price),
    INDEX idx_stock_status (stock_status),
    INDEX idx_expiry (expiry_date),
    INDEX idx_sku (sku_code),
    INDEX idx_brand (brand_name),
    FULLTEXT idx_search (product_name, brand_name, tags),
    
    -- ⚠️ CONSTRAINTS
    CHECK (selling_price > 0),
    CHECK (cost_price >= 0),
    CHECK (current_stock >= 0),
    CHECK (discount_percent BETWEEN 0 AND 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 🗂️ SUPPORTING TABLES
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    parent_category_id INT NULL,
    category_description TEXT,
    category_image VARCHAR(255),
    tax_percent DECIMAL(5,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_code VARCHAR(15) UNIQUE NOT NULL,
    company_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    rating DECIMAL(3,2) DEFAULT 5.00,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE inventory_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    item_id INT,
    action_type ENUM('stock_in', 'stock_out', 'adjustment', 'return', 'damage', 'expiry'),
    quantity_change INT NOT NULL,
    previous_quantity INT,
    new_quantity INT,
    reason VARCHAR(255),
    reference_number VARCHAR(50),
    logged_by INT,
    log_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (item_id) REFERENCES grocery_items(item_id)
);
