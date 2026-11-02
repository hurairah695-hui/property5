-- =====================================================================
-- PropDeal database: structure only (no data)
-- Works on MySQL 5.7+ / 8.x and MariaDB 10.3+ (XAMPP, WAMP, MAMP).
-- WARNING: running this file drops and recreates the PropDeal tables.
-- =====================================================================
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS propdeal CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE propdeal;

DROP VIEW  IF EXISTS v_property_cards;
DROP TABLE IF EXISTS deal_properties;
DROP TABLE IF EXISTS deals;
DROP TABLE IF EXISTS announcements;
DROP TABLE IF EXISTS meetings;
DROP TABLE IF EXISTS favorites;
DROP TABLE IF EXISTS property_features;
DROP TABLE IF EXISTS property_images;
DROP TABLE IF EXISTS properties;
DROP TABLE IF EXISTS users;

-- People who can sign in: buyers, sellers and admins.
CREATE TABLE users (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  full_name     VARCHAR(50)  NOT NULL,
  email         VARCHAR(150) NOT NULL,
  password_hash VARCHAR(100) NOT NULL COMMENT 'bcrypt hash, never the plain password',
  role          ENUM('admin','buyer','seller') NOT NULL,
  age           TINYINT UNSIGNED NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  CONSTRAINT chk_users_age CHECK (age IS NULL OR (age >= 18 AND age <= 100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- One row per listing (for sale or for rent).
CREATE TABLE properties (
  id                INT UNSIGNED NOT NULL AUTO_INCREMENT,
  seller_id         INT UNSIGNED NOT NULL,
  title             VARCHAR(150) NOT NULL,
  property_type     ENUM('house','apartment','shop','plot') NOT NULL,
  listing_mode      ENUM('sale','rent') NOT NULL DEFAULT 'sale',
  price             BIGINT UNSIGNED NOT NULL COMMENT 'PKR. Monthly rent when listing_mode = rent',
  is_negotiable     TINYINT(1) NULL COMMENT '1 = negotiable, 0 = fixed price, NULL = ask the seller',
  min_rental_months TINYINT UNSIGNED NULL COMMENT 'Only for rent listings',
  city              VARCHAR(80)  NOT NULL,
  locality          VARCHAR(80)  NULL,
  area_size         VARCHAR(40)  NULL,
  bedrooms          TINYINT UNSIGNED NULL,
  bathrooms         TINYINT UNSIGNED NULL,
  short_description VARCHAR(160) NOT NULL,
  full_description  TEXT NULL,
  created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_properties_filter (property_type, listing_mode, city),
  KEY idx_properties_seller (seller_id),
  CONSTRAINT fk_properties_seller FOREIGN KEY (seller_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT chk_properties_price CHECK (price > 0),
  CONSTRAINT chk_properties_rent  CHECK (listing_mode <> 'rent' OR min_rental_months IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Photos of a listing. sort_order 1 is the cover photo.
CREATE TABLE property_images (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  property_id INT UNSIGNED NOT NULL,
  image_url   VARCHAR(500) NOT NULL,
  sort_order  TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_images_order (property_id, sort_order),
  CONSTRAINT fk_images_property FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Feature chips such as "Balcony" or "Car porch".
CREATE TABLE property_features (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  property_id INT UNSIGNED NOT NULL,
  feature     VARCHAR(80) NOT NULL,
  PRIMARY KEY (id),
  KEY idx_features_property (property_id),
  CONSTRAINT fk_features_property FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- The heart button.
CREATE TABLE favorites (
  user_id     INT UNSIGNED NOT NULL,
  property_id INT UNSIGNED NOT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, property_id),
  CONSTRAINT fk_fav_user     FOREIGN KEY (user_id)     REFERENCES users (id)      ON DELETE CASCADE,
  CONSTRAINT fk_fav_property FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Meeting / viewing requests from buyers to sellers.
CREATE TABLE meetings (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  property_id   INT UNSIGNED NOT NULL,
  buyer_id      INT UNSIGNED NOT NULL,
  seller_id     INT UNSIGNED NOT NULL,
  meeting_date  DATE NOT NULL,
  meeting_time  VARCHAR(10) NOT NULL,
  note          VARCHAR(300) NULL,
  rental_months TINYINT UNSIGNED NULL COMMENT 'Months the buyer wants to rent for (rent listings only)',
  status        ENUM('pending','confirmed','declined','cancelled') NOT NULL DEFAULT 'pending',
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_meetings_buyer  (buyer_id, status),
  KEY idx_meetings_seller (seller_id, status),
  CONSTRAINT fk_meet_property FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE,
  CONSTRAINT fk_meet_buyer    FOREIGN KEY (buyer_id)    REFERENCES users (id)      ON DELETE CASCADE,
  CONSTRAINT fk_meet_seller   FOREIGN KEY (seller_id)   REFERENCES users (id)      ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Limited-time discounts (the countdown on the buyer home page).
CREATE TABLE deals (
  id               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  title            VARCHAR(100) NOT NULL,
  discount_percent TINYINT UNSIGNED NOT NULL,
  starts_at        DATETIME NOT NULL,
  ends_at          DATETIME NOT NULL,
  is_active        TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  CONSTRAINT chk_deals_percent CHECK (discount_percent BETWEEN 1 AND 90)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE deal_properties (
  deal_id     INT UNSIGNED NOT NULL,
  property_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (deal_id, property_id),
  CONSTRAINT fk_dealp_deal     FOREIGN KEY (deal_id)     REFERENCES deals (id)      ON DELETE CASCADE,
  CONSTRAINT fk_dealp_property FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Messages in the red scrolling line at the top of the buyer home page.
CREATE TABLE announcements (
  id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  message    VARCHAR(160) NOT NULL,
  sort_order TINYINT UNSIGNED NOT NULL DEFAULT 1,
  is_active  TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ready-made list for the home page cards (cover photo + seller name).
CREATE VIEW v_property_cards AS
SELECT p.id, p.title, p.property_type, p.listing_mode, p.price, p.is_negotiable, p.min_rental_months,
       p.city, p.locality, p.area_size, p.bedrooms, p.bathrooms, p.short_description,
       (SELECT i.image_url FROM property_images i WHERE i.property_id = p.id ORDER BY i.sort_order LIMIT 1) AS cover_image,
       u.full_name AS seller_name
FROM properties p
JOIN users u ON u.id = p.seller_id;

SET FOREIGN_KEY_CHECKS = 1;
