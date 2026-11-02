-- =====================================================================
-- PropDeal database: structure + all sample data (import this one)
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

-- =====================================================================
-- DATA
-- =====================================================================
USE propdeal;
SET NAMES utf8mb4;

-- Demo accounts (email is the username). Passwords: Admin@1234 / Buyer@1234 / Seller@1234
INSERT INTO users (id, full_name, email, password_hash, role, age) VALUES
  (1, 'Demo Admin', 'admin@example.com', '$2b$12$yXWV5wtAWlkZbq8pvlp7CuEzFUrAeSfbY1yr44InbCujmRVMP.oGy', 'admin', 35),
  (2, 'Demo Buyer', 'buyer@example.com', '$2b$12$EJMxBfmQStIxgtb9Uyk6Q.uR9lQFDYTYJuT59VFNre/CRiPivxx4C', 'buyer', 28),
  (3, 'Demo Seller', 'seller@example.com', '$2b$12$HRkZVF5G6wyGxdvf0BGKiecPzhlpO1bMziGiRNuYu6uf97kgTetXC', 'seller', 40);

-- 28 sample listings, all owned by the demo seller (id 3)
INSERT INTO properties (id, seller_id, title, property_type, listing_mode, price, is_negotiable, min_rental_months, city, locality, area_size, bedrooms, bathrooms, short_description, full_description) VALUES
  (1, 3, 'Modern 10 Marla House, Bahria Town', 'house', 'sale', 38500000, 1, NULL, 'Rawalpindi', 'Bahria Town Phase 7', '10 Marla', 5, 4, 'Double-storey home with a front lawn, modular kitchen and covered parking.', 'Double-storey home with a front lawn, modular kitchen and covered parking.

This well-maintained house offers comfortable family living with bright rooms, good ventilation and a practical layout. The neighbourhood is quiet and secure, close to schools, markets and mosques, with easy access to the main road.

Highlights include modular kitchen, front lawn, car porch for 2 cars, servant quarter and 24/7 security.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (2, 3, 'Corner Shop on Main Boulevard', 'shop', 'sale', 12500000, 1, NULL, 'Lahore', 'Gulberg Main Boulevard', '450 sq ft', NULL, NULL, 'Ground-floor corner shop with high footfall and a wide frontage.', 'Ground-floor corner shop with high footfall and a wide frontage.

This commercial unit has a visible position with steady walk-in traffic, which makes it a good fit for retail, a showroom, a clinic or a small office. Parking is nearby and the road is easy to reach.

Highlights include corner position, wide frontage, shutter and glass front and parking nearby.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (3, 3, 'Residential Plot, DHA Phase 2', 'plot', 'sale', 9500000, 0, NULL, 'Islamabad', 'DHA Phase 2', '1 Kanal', NULL, NULL, 'Ready-to-build plot on a 60 ft road with all utilities nearby.', 'Ready-to-build plot on a 60 ft road with all utilities nearby.

This plot is clearly demarcated and ready for construction or use, with utilities close by. The area is well developed with metalled roads and a good mix of existing buildings, so it keeps growing steadily.

Highlights include possession available, 60 ft road, gas and electricity nearby and close to park.

It is offered for sale. The price is fixed by the owner. Documents are ready for a quick and smooth transfer.'),
  (4, 3, '2-Bed Apartment, F-11 Markaz', 'apartment', 'sale', 21000000, 1, NULL, 'Islamabad', 'F-11 Markaz', '1,150 sq ft', 2, 2, 'Bright apartment with a balcony, lift and 24/7 security.', 'Bright apartment with a balcony, lift and 24/7 security.

This apartment makes good use of its space with a smart layout and large windows. The building has security, a lift and dedicated parking, and daily needs such as shops, cafés and clinics are within a short walk.

Highlights include balcony, lift, covered parking, backup power and tiled floors.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (5, 3, '5 Marla Family Home, Johar Town', 'house', 'sale', 17500000, 1, NULL, 'Lahore', 'Johar Town Block C', '5 Marla', 3, 3, 'Neat family home in a quiet gated society close to schools.', 'Neat family home in a quiet gated society close to schools.

This well-maintained house offers comfortable family living with bright rooms, good ventilation and a practical layout. The neighbourhood is quiet and secure, close to schools, markets and mosques, with easy access to the main road.

Highlights include gated society, tiled flooring, marble kitchen counters and close to schools.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (6, 3, 'Commercial Plot near Motorway', 'plot', 'sale', 28000000, 1, NULL, 'Rawalpindi', 'Near M-2 Interchange', '8 Marla', NULL, NULL, 'Corner commercial plot with easy motorway access.', 'Corner commercial plot with easy motorway access.

This plot is clearly demarcated and ready for construction or use, with utilities close by. The area is well developed with metalled roads and a good mix of existing buildings, so it keeps growing steadily.

Highlights include corner plot, commercial zone, easy motorway access and possession available.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (7, 3, 'Luxury 1 Kanal Villa, F-7', 'house', 'sale', 120000000, 1, NULL, 'Islamabad', 'F-7/2', '1 Kanal', 6, 6, 'Spacious villa with a home theatre, garden and servant quarters.', 'Spacious villa with a home theatre, garden and servant quarters.

This well-maintained house offers comfortable family living with bright rooms, good ventilation and a practical layout. The neighbourhood is quiet and secure, close to schools, markets and mosques, with easy access to the main road.

Highlights include home theatre, landscaped garden, servant quarters, imported fittings and smart security.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (8, 3, 'Furnished Studio Apartment, Gulberg', 'apartment', 'rent', 65000, 1, 6, 'Lahore', 'Gulberg III', '520 sq ft', 1, 1, 'Compact, fully furnished studio close to offices and cafés.', 'Compact, fully furnished studio close to offices and cafés.

This apartment makes good use of its space with a smart layout and large windows. The building has security, a lift and dedicated parking, and daily needs such as shops, cafés and clinics are within a short walk.

Highlights include fully furnished, air conditioning, internet ready and gated building.

It is offered for rent at PKR 65,000 per month with a minimum stay of 6 months. The owner is happy to discuss a longer term, so tell us how many months you need when you request a meeting.'),
  (9, 3, 'Shop in Saddar Bazaar', 'shop', 'sale', 7200000, 1, NULL, 'Rawalpindi', 'Saddar Bazaar', '220 sq ft', NULL, NULL, 'Busy bazaar location, ideal for clothing or electronics.', 'Busy bazaar location, ideal for clothing or electronics.

This commercial unit has a visible position with steady walk-in traffic, which makes it a good fit for retail, a showroom, a clinic or a small office. Parking is nearby and the road is easy to reach.

Highlights include busy bazaar, steel shutter, electricity meter and near metro station.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (10, 3, 'Corner Plot, Gulberg Greens', 'plot', 'sale', 6500000, 1, NULL, 'Islamabad', 'Gulberg Greens', '5 Marla', NULL, NULL, 'Park-facing corner plot in a developed block.', 'Park-facing corner plot in a developed block.

This plot is clearly demarcated and ready for construction or use, with utilities close by. The area is well developed with metalled roads and a good mix of existing buildings, so it keeps growing steadily.

Highlights include park facing, corner plot, developed block and clear title.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (11, 3, 'Modern Home with Front Lawn, Bahria Enclave', 'house', 'sale', 28500000, 1, NULL, 'Islamabad', 'Bahria Enclave Sector A', '8 Marla', 4, 4, 'Contemporary design with a large front lawn and a double-height lounge.', 'Contemporary design with a large front lawn and a double-height lounge.

This well-maintained house offers comfortable family living with bright rooms, good ventilation and a practical layout. The neighbourhood is quiet and secure, close to schools, markets and mosques, with easy access to the main road.

Highlights include double-height lounge, front lawn, wooden doors, modular kitchen and solar-ready roof.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (12, 3, 'Apartment with Balcony for Rent, DHA', 'apartment', 'rent', 120000, 1, 12, 'Lahore', 'DHA Phase 5', '950 sq ft', 2, 2, 'Modern apartment with a balcony, parking and gated security.', 'Modern apartment with a balcony, parking and gated security.

This apartment makes good use of its space with a smart layout and large windows. The building has security, a lift and dedicated parking, and daily needs such as shops, cafés and clinics are within a short walk.

Highlights include balcony, reserved parking, gated security, lift and backup power.

It is offered for rent at PKR 1.2 Lakh per month with a minimum stay of 12 months. The owner is happy to discuss a longer term, so tell us how many months you need when you request a meeting.'),
  (13, 3, '4-Bed House for Rent, Bahria Town', 'house', 'rent', 180000, 1, 12, 'Rawalpindi', 'Bahria Town Phase 4', '10 Marla', 4, 4, 'Spacious family house with a lawn and car porch, ready to move in.', 'Spacious family house with a lawn and car porch, ready to move in.

This well-maintained house offers comfortable family living with bright rooms, good ventilation and a practical layout. The neighbourhood is quiet and secure, close to schools, markets and mosques, with easy access to the main road.

Highlights include lawn, car porch, bright rooms, separate drawing room and gas available.

It is offered for rent at PKR 1.8 Lakh per month with a minimum stay of 12 months. The owner is happy to discuss a longer term, so tell us how many months you need when you request a meeting.'),
  (14, 3, '3-Bed Luxury Apartment, Clifton', 'apartment', 'sale', 58000000, 1, NULL, 'Karachi', 'Clifton Block 5', '2,100 sq ft', 3, 3, 'High-floor apartment with sea breeze, gym and covered parking.', 'High-floor apartment with sea breeze, gym and covered parking.

This apartment makes good use of its space with a smart layout and large windows. The building has security, a lift and dedicated parking, and daily needs such as shops, cafés and clinics are within a short walk.

Highlights include sea breeze, gym and lobby, covered parking, backup generator and 24/7 security.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (15, 3, 'Ground Floor Shop for Rent, Blue Area', 'shop', 'rent', 250000, 1, 24, 'Islamabad', 'Jinnah Avenue, Blue Area', '600 sq ft', NULL, NULL, 'Prime ground-floor shop on the main avenue, ready for retail or a showroom.', 'Prime ground-floor shop on the main avenue, ready for retail or a showroom.

This commercial unit has a visible position with steady walk-in traffic, which makes it a good fit for retail, a showroom, a clinic or a small office. Parking is nearby and the road is easy to reach.

Highlights include prime avenue, glass frontage, air conditioned and loading access.

It is offered for rent at PKR 2.5 Lakh per month with a minimum stay of 24 months. The owner is happy to discuss a longer term, so tell us how many months you need when you request a meeting.'),
  (16, 3, 'Residential Plot, Bahria Town Phase 8', 'plot', 'sale', 7200000, 1, NULL, 'Rawalpindi', 'Bahria Town Phase 8', '10 Marla', NULL, NULL, 'Level plot in a developed sector with parks and mosques nearby.', 'Level plot in a developed sector with parks and mosques nearby.

This plot is clearly demarcated and ready for construction or use, with utilities close by. The area is well developed with metalled roads and a good mix of existing buildings, so it keeps growing steadily.

Highlights include developed sector, possession available, near park and near mosque.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (17, 3, '7 Marla Modern House, Wapda Town', 'house', 'sale', 32000000, 1, NULL, 'Lahore', 'Wapda Town Phase 1', '7 Marla', 5, 5, 'Brand-new modern house with imported tiles and a stylish elevation.', 'Brand-new modern house with imported tiles and a stylish elevation.

This well-maintained house offers comfortable family living with bright rooms, good ventilation and a practical layout. The neighbourhood is quiet and secure, close to schools, markets and mosques, with easy access to the main road.

Highlights include brand new, imported tiles, stylish elevation, modular kitchen and car porch.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (18, 3, '1-Bed Furnished Apartment for Rent, Gulberg III', 'apartment', 'rent', 85000, 0, 6, 'Lahore', 'Gulberg III', '700 sq ft', 1, 1, 'Fully furnished one-bedroom with a city view, available immediately.', 'Fully furnished one-bedroom with a city view, available immediately.

This apartment makes good use of its space with a smart layout and large windows. The building has security, a lift and dedicated parking, and daily needs such as shops, cafés and clinics are within a short walk.

Highlights include fully furnished, city view, lift and covered parking.

It is offered for rent at PKR 85,000 per month with a minimum stay of 6 months. The owner is happy to discuss a longer term, so tell us how many months you need when you request a meeting.'),
  (19, 3, 'Showroom on Canal Road', 'shop', 'sale', 45000000, 1, NULL, 'Faisalabad', 'Canal Road', '1,200 sq ft', NULL, NULL, 'Large showroom with a double-height ceiling on a busy road.', 'Large showroom with a double-height ceiling on a busy road.

This commercial unit has a visible position with steady walk-in traffic, which makes it a good fit for retail, a showroom, a clinic or a small office. Parking is nearby and the road is easy to reach.

Highlights include double-height ceiling, main road, basement storage and ample parking.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (20, 3, 'Corner Plot, DHA Phase 6', 'plot', 'sale', 38000000, 1, NULL, 'Lahore', 'DHA Phase 6', '1 Kanal', NULL, NULL, 'Corner plot on a wide road, ideal for a custom-built home.', 'Corner plot on a wide road, ideal for a custom-built home.

This plot is clearly demarcated and ready for construction or use, with utilities close by. The area is well developed with metalled roads and a good mix of existing buildings, so it keeps growing steadily.

Highlights include corner plot, wide road, developed block and possession available.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (21, 3, 'Double-Storey Home, Hayatabad', 'house', 'sale', 24000000, 0, NULL, 'Peshawar', 'Hayatabad Phase 3', '6 Marla', 4, 3, 'Well-kept double-storey home in a calm, popular neighbourhood.', 'Well-kept double-storey home in a calm, popular neighbourhood.

This well-maintained house offers comfortable family living with bright rooms, good ventilation and a practical layout. The neighbourhood is quiet and secure, close to schools, markets and mosques, with easy access to the main road.

Highlights include well maintained, near market, gas available and marble flooring.

It is offered for sale. The price is fixed by the owner. Documents are ready for a quick and smooth transfer.'),
  (22, 3, 'Sea-View Apartment, Bahria Town Karachi', 'apartment', 'sale', 36000000, 1, NULL, 'Karachi', 'Bahria Town Precinct 10', '1,650 sq ft', 3, 3, 'Spacious apartment with a sea-facing balcony and resort-style amenities.', 'Spacious apartment with a sea-facing balcony and resort-style amenities.

This apartment makes good use of its space with a smart layout and large windows. The building has security, a lift and dedicated parking, and daily needs such as shops, cafés and clinics are within a short walk.

Highlights include sea-facing balcony, clubhouse access, swimming pool and covered parking.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (23, 3, 'Furnished Villa for Rent, F-10', 'house', 'rent', 350000, 1, 12, 'Islamabad', 'F-10/3', '1 Kanal', 5, 5, 'Fully furnished villa with a garden, ideal for families or diplomats.', 'Fully furnished villa with a garden, ideal for families or diplomats.

This well-maintained house offers comfortable family living with bright rooms, good ventilation and a practical layout. The neighbourhood is quiet and secure, close to schools, markets and mosques, with easy access to the main road.

Highlights include fully furnished, garden, servant quarter, central heating and car porch.

It is offered for rent at PKR 3.5 Lakh per month with a minimum stay of 12 months. The owner is happy to discuss a longer term, so tell us how many months you need when you request a meeting.'),
  (24, 3, 'Farmhouse Plot, Sheikhupura Road', 'plot', 'sale', 22000000, 1, NULL, 'Lahore', 'Sheikhupura Road', '4 Kanal', NULL, NULL, 'Open farmhouse plot with green surroundings, a short drive from the city.', 'Open farmhouse plot with green surroundings, a short drive from the city.

This plot is clearly demarcated and ready for construction or use, with utilities close by. The area is well developed with metalled roads and a good mix of existing buildings, so it keeps growing steadily.

Highlights include green surroundings, farmhouse zone, tube-well possible and clear title.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (25, 3, 'Corner Shop for Rent, Johar Town Market', 'shop', 'rent', 95000, 1, 12, 'Lahore', 'Johar Town Commercial', '300 sq ft', NULL, NULL, 'Corner shop in a busy commercial market with steady customers.', 'Corner shop in a busy commercial market with steady customers.

This commercial unit has a visible position with steady walk-in traffic, which makes it a good fit for retail, a showroom, a clinic or a small office. Parking is nearby and the road is easy to reach.

Highlights include corner shop, busy market, shutter front and electricity meter.

It is offered for rent at PKR 95,000 per month with a minimum stay of 12 months. The owner is happy to discuss a longer term, so tell us how many months you need when you request a meeting.'),
  (26, 3, 'Penthouse with Terrace, E-11', 'apartment', 'sale', 78000000, 1, NULL, 'Islamabad', 'E-11/2', '3,400 sq ft', 4, 4, 'Top-floor penthouse with a private terrace and mountain views.', 'Top-floor penthouse with a private terrace and mountain views.

This apartment makes good use of its space with a smart layout and large windows. The building has security, a lift and dedicated parking, and daily needs such as shops, cafés and clinics are within a short walk.

Highlights include private terrace, mountain view, two parking spots, lift access and smart home wiring.

It is offered for sale. The asking price is negotiable for serious buyers after a viewing. Documents are ready for a quick and smooth transfer.'),
  (27, 3, 'Open Plot for Rent, I-9 Industrial Area', 'plot', 'rent', 120000, 1, 12, 'Islamabad', 'I-9 Industrial Area', '1 Kanal', NULL, NULL, 'Fenced open plot suitable for parking, storage or a workshop.', 'Fenced open plot suitable for parking, storage or a workshop.

This plot is clearly demarcated and ready for construction or use, with utilities close by. The area is well developed with metalled roads and a good mix of existing buildings, so it keeps growing steadily.

Highlights include fenced boundary, heavy vehicle access, electricity nearby and flexible use.

It is offered for rent at PKR 1.2 Lakh per month with a minimum stay of 12 months. The owner is happy to discuss a longer term, so tell us how many months you need when you request a meeting.'),
  (28, 3, 'Brand-New 3-Bed House, Citi Housing', 'house', 'sale', 19500000, 0, NULL, 'Faisalabad', 'Citi Housing', '5 Marla', 3, 3, 'Newly built house with a modern design in a gated housing society.', 'Newly built house with a modern design in a gated housing society.

This well-maintained house offers comfortable family living with bright rooms, good ventilation and a practical layout. The neighbourhood is quiet and secure, close to schools, markets and mosques, with easy access to the main road.

Highlights include newly built, gated society, modern design and tiled flooring.

It is offered for sale. The price is fixed by the owner. Documents are ready for a quick and smooth transfer.');

-- Photos (3 to 4 per listing, from Unsplash)
INSERT INTO property_images (property_id, image_url, sort_order) VALUES
  (1, 'https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=1280&q=80', 1),
  (1, 'https://images.unsplash.com/photo-1759691555105-17e609a3e46f?auto=format&fit=crop&w=1280&q=80', 2),
  (1, 'https://images.unsplash.com/photo-1759691554646-8155da2172ee?auto=format&fit=crop&w=1280&q=80', 3),
  (1, 'https://images.unsplash.com/photo-1759691554836-81ba129a75b7?auto=format&fit=crop&w=1280&q=80', 4),
  (2, 'https://images.unsplash.com/photo-1764395294670-22fc367f3119?auto=format&fit=crop&w=1280&q=80', 1),
  (2, 'https://images.unsplash.com/photo-1761850648640-2ee5870ee883?auto=format&fit=crop&w=1280&q=80', 2),
  (2, 'https://images.unsplash.com/photo-1759691555407-3c5834e6991e?auto=format&fit=crop&w=1280&q=80', 3),
  (3, 'https://images.unsplash.com/photo-1747854805840-9be7d5e360e6?auto=format&fit=crop&w=1280&q=80', 1),
  (3, 'https://images.unsplash.com/photo-1587745890135-20db8c79b027?auto=format&fit=crop&w=1280&q=80', 2),
  (3, 'https://images.unsplash.com/photo-1769258958976-8852440011b8?auto=format&fit=crop&w=1280&q=80', 3),
  (4, 'https://images.unsplash.com/photo-1525953776754-6c4b7ee655ab?auto=format&fit=crop&w=1280&q=80', 1),
  (4, 'https://images.unsplash.com/photo-1759691555285-74005fcf3ddf?auto=format&fit=crop&w=1280&q=80', 2),
  (4, 'https://images.unsplash.com/photo-1759691554884-914bd85837c8?auto=format&fit=crop&w=1280&q=80', 3),
  (4, 'https://images.unsplash.com/photo-1759691337936-ef702afd0714?auto=format&fit=crop&w=1280&q=80', 4),
  (5, 'https://images.unsplash.com/photo-1513584684374-8bab748fbf90?auto=format&fit=crop&w=1280&q=80', 1),
  (5, 'https://images.unsplash.com/photo-1759691554705-8a791e8f0875?auto=format&fit=crop&w=1280&q=80', 2),
  (5, 'https://images.unsplash.com/photo-1759691337940-057d9cfce74c?auto=format&fit=crop&w=1280&q=80', 3),
  (5, 'https://images.unsplash.com/photo-1759691554884-914bd85837c8?auto=format&fit=crop&w=1280&q=80', 4),
  (6, 'https://images.unsplash.com/photo-1587745890135-20db8c79b027?auto=format&fit=crop&w=1280&q=80', 1),
  (6, 'https://images.unsplash.com/photo-1769258958976-8852440011b8?auto=format&fit=crop&w=1280&q=80', 2),
  (6, 'https://images.unsplash.com/photo-1629460455571-c943339c4f23?auto=format&fit=crop&w=1280&q=80', 3),
  (7, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1280&q=80', 1),
  (7, 'https://images.unsplash.com/photo-1759691555285-74005fcf3ddf?auto=format&fit=crop&w=1280&q=80', 2),
  (7, 'https://images.unsplash.com/photo-1759691337936-ef702afd0714?auto=format&fit=crop&w=1280&q=80', 3),
  (7, 'https://images.unsplash.com/photo-1759691337809-0ddaa66818de?auto=format&fit=crop&w=1280&q=80', 4),
  (8, 'https://images.unsplash.com/photo-1512845296467-183ccf124347?auto=format&fit=crop&w=1280&q=80', 1),
  (8, 'https://images.unsplash.com/photo-1759691555010-7f3f8674d2f2?auto=format&fit=crop&w=1280&q=80', 2),
  (8, 'https://images.unsplash.com/photo-1759691337809-0ddaa66818de?auto=format&fit=crop&w=1280&q=80', 3),
  (8, 'https://images.unsplash.com/photo-1759691337957-ebc9ed54dc44?auto=format&fit=crop&w=1280&q=80', 4),
  (9, 'https://images.unsplash.com/photo-1772331274672-a5eecb4c6498?auto=format&fit=crop&w=1280&q=80', 1),
  (9, 'https://images.unsplash.com/photo-1580554430120-94cfcb3adf25?auto=format&fit=crop&w=1280&q=80', 2),
  (9, 'https://images.unsplash.com/photo-1759691554837-be93ac47760b?auto=format&fit=crop&w=1280&q=80', 3),
  (10, 'https://images.unsplash.com/photo-1769258958976-8852440011b8?auto=format&fit=crop&w=1280&q=80', 1),
  (10, 'https://images.unsplash.com/photo-1629460455571-c943339c4f23?auto=format&fit=crop&w=1280&q=80', 2),
  (10, 'https://images.unsplash.com/photo-1747854805840-9be7d5e360e6?auto=format&fit=crop&w=1280&q=80', 3),
  (11, 'https://images.unsplash.com/photo-1706808849777-96e0d7be3bb7?auto=format&fit=crop&w=1280&q=80', 1),
  (11, 'https://images.unsplash.com/photo-1759691555010-7f3f8674d2f2?auto=format&fit=crop&w=1280&q=80', 2),
  (11, 'https://images.unsplash.com/photo-1759691337957-ebc9ed54dc44?auto=format&fit=crop&w=1280&q=80', 3),
  (11, 'https://images.unsplash.com/photo-1759691321555-94fed84288fa?auto=format&fit=crop&w=1280&q=80', 4),
  (12, 'https://images.unsplash.com/photo-1764722870653-e59e737d1d30?auto=format&fit=crop&w=1280&q=80', 1),
  (12, 'https://images.unsplash.com/photo-1759691555393-60cd5355d840?auto=format&fit=crop&w=1280&q=80', 2),
  (12, 'https://images.unsplash.com/photo-1759691321555-94fed84288fa?auto=format&fit=crop&w=1280&q=80', 3),
  (12, 'https://images.unsplash.com/photo-1759691554646-8155da2172ee?auto=format&fit=crop&w=1280&q=80', 4),
  (13, 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=1280&q=80', 1),
  (13, 'https://images.unsplash.com/photo-1759691555393-60cd5355d840?auto=format&fit=crop&w=1280&q=80', 2),
  (13, 'https://images.unsplash.com/photo-1759691554646-8155da2172ee?auto=format&fit=crop&w=1280&q=80', 3),
  (13, 'https://images.unsplash.com/photo-1759691554836-81ba129a75b7?auto=format&fit=crop&w=1280&q=80', 4),
  (14, 'https://images.unsplash.com/photo-1521208059781-bcf3fd4d1245?auto=format&fit=crop&w=1280&q=80', 1),
  (14, 'https://images.unsplash.com/photo-1759691555105-17e609a3e46f?auto=format&fit=crop&w=1280&q=80', 2),
  (14, 'https://images.unsplash.com/photo-1759691554836-81ba129a75b7?auto=format&fit=crop&w=1280&q=80', 3),
  (14, 'https://images.unsplash.com/photo-1759691337940-057d9cfce74c?auto=format&fit=crop&w=1280&q=80', 4),
  (15, 'https://images.unsplash.com/photo-1761850648640-2ee5870ee883?auto=format&fit=crop&w=1280&q=80', 1),
  (15, 'https://images.unsplash.com/photo-1528698827591-e19ccd7bc23d?auto=format&fit=crop&w=1280&q=80', 2),
  (15, 'https://images.unsplash.com/photo-1759691555407-3c5834e6991e?auto=format&fit=crop&w=1280&q=80', 3),
  (16, 'https://images.unsplash.com/photo-1629460455571-c943339c4f23?auto=format&fit=crop&w=1280&q=80', 1),
  (16, 'https://images.unsplash.com/photo-1747854805840-9be7d5e360e6?auto=format&fit=crop&w=1280&q=80', 2),
  (16, 'https://images.unsplash.com/photo-1587745890135-20db8c79b027?auto=format&fit=crop&w=1280&q=80', 3),
  (17, 'https://images.unsplash.com/photo-1721815693498-cc28507c0ba2?auto=format&fit=crop&w=1280&q=80', 1),
  (17, 'https://images.unsplash.com/photo-1759691555105-17e609a3e46f?auto=format&fit=crop&w=1280&q=80', 2),
  (17, 'https://images.unsplash.com/photo-1759691337940-057d9cfce74c?auto=format&fit=crop&w=1280&q=80', 3),
  (17, 'https://images.unsplash.com/photo-1759691554884-914bd85837c8?auto=format&fit=crop&w=1280&q=80', 4),
  (18, 'https://images.unsplash.com/photo-1672508061327-6efaa65896e9?auto=format&fit=crop&w=1280&q=80', 1),
  (18, 'https://images.unsplash.com/photo-1759691554705-8a791e8f0875?auto=format&fit=crop&w=1280&q=80', 2),
  (18, 'https://images.unsplash.com/photo-1759691554884-914bd85837c8?auto=format&fit=crop&w=1280&q=80', 3),
  (18, 'https://images.unsplash.com/photo-1759691337936-ef702afd0714?auto=format&fit=crop&w=1280&q=80', 4),
  (19, 'https://images.unsplash.com/photo-1580554430120-94cfcb3adf25?auto=format&fit=crop&w=1280&q=80', 1),
  (19, 'https://images.unsplash.com/photo-1764395294670-22fc367f3119?auto=format&fit=crop&w=1280&q=80', 2),
  (19, 'https://images.unsplash.com/photo-1759691554837-be93ac47760b?auto=format&fit=crop&w=1280&q=80', 3),
  (20, 'https://images.unsplash.com/photo-1747854805840-9be7d5e360e6?auto=format&fit=crop&w=1280&q=80', 1),
  (20, 'https://images.unsplash.com/photo-1587745890135-20db8c79b027?auto=format&fit=crop&w=1280&q=80', 2),
  (20, 'https://images.unsplash.com/photo-1769258958976-8852440011b8?auto=format&fit=crop&w=1280&q=80', 3),
  (21, 'https://images.unsplash.com/photo-1628012209120-d9db7abf7eab?auto=format&fit=crop&w=1280&q=80', 1),
  (21, 'https://images.unsplash.com/photo-1759691554705-8a791e8f0875?auto=format&fit=crop&w=1280&q=80', 2),
  (21, 'https://images.unsplash.com/photo-1759691337936-ef702afd0714?auto=format&fit=crop&w=1280&q=80', 3),
  (21, 'https://images.unsplash.com/photo-1759691337809-0ddaa66818de?auto=format&fit=crop&w=1280&q=80', 4),
  (22, 'https://images.unsplash.com/photo-1525953776754-6c4b7ee655ab?auto=format&fit=crop&w=1280&q=80', 1),
  (22, 'https://images.unsplash.com/photo-1759691555285-74005fcf3ddf?auto=format&fit=crop&w=1280&q=80', 2),
  (22, 'https://images.unsplash.com/photo-1759691337809-0ddaa66818de?auto=format&fit=crop&w=1280&q=80', 3),
  (22, 'https://images.unsplash.com/photo-1759691337957-ebc9ed54dc44?auto=format&fit=crop&w=1280&q=80', 4),
  (23, 'https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=1280&q=80', 1),
  (23, 'https://images.unsplash.com/photo-1759691555285-74005fcf3ddf?auto=format&fit=crop&w=1280&q=80', 2),
  (23, 'https://images.unsplash.com/photo-1759691337957-ebc9ed54dc44?auto=format&fit=crop&w=1280&q=80', 3),
  (23, 'https://images.unsplash.com/photo-1759691321555-94fed84288fa?auto=format&fit=crop&w=1280&q=80', 4),
  (24, 'https://images.unsplash.com/photo-1587745890135-20db8c79b027?auto=format&fit=crop&w=1280&q=80', 1),
  (24, 'https://images.unsplash.com/photo-1769258958976-8852440011b8?auto=format&fit=crop&w=1280&q=80', 2),
  (24, 'https://images.unsplash.com/photo-1629460455571-c943339c4f23?auto=format&fit=crop&w=1280&q=80', 3),
  (25, 'https://images.unsplash.com/photo-1528698827591-e19ccd7bc23d?auto=format&fit=crop&w=1280&q=80', 1),
  (25, 'https://images.unsplash.com/photo-1772331274672-a5eecb4c6498?auto=format&fit=crop&w=1280&q=80', 2),
  (25, 'https://images.unsplash.com/photo-1759691555407-3c5834e6991e?auto=format&fit=crop&w=1280&q=80', 3),
  (26, 'https://images.unsplash.com/photo-1512845296467-183ccf124347?auto=format&fit=crop&w=1280&q=80', 1),
  (26, 'https://images.unsplash.com/photo-1759691555010-7f3f8674d2f2?auto=format&fit=crop&w=1280&q=80', 2),
  (26, 'https://images.unsplash.com/photo-1759691321555-94fed84288fa?auto=format&fit=crop&w=1280&q=80', 3),
  (26, 'https://images.unsplash.com/photo-1759691554646-8155da2172ee?auto=format&fit=crop&w=1280&q=80', 4),
  (27, 'https://images.unsplash.com/photo-1769258958976-8852440011b8?auto=format&fit=crop&w=1280&q=80', 1),
  (27, 'https://images.unsplash.com/photo-1629460455571-c943339c4f23?auto=format&fit=crop&w=1280&q=80', 2),
  (27, 'https://images.unsplash.com/photo-1747854805840-9be7d5e360e6?auto=format&fit=crop&w=1280&q=80', 3),
  (28, 'https://images.unsplash.com/photo-1513584684374-8bab748fbf90?auto=format&fit=crop&w=1280&q=80', 1),
  (28, 'https://images.unsplash.com/photo-1759691555010-7f3f8674d2f2?auto=format&fit=crop&w=1280&q=80', 2),
  (28, 'https://images.unsplash.com/photo-1759691554646-8155da2172ee?auto=format&fit=crop&w=1280&q=80', 3),
  (28, 'https://images.unsplash.com/photo-1759691554836-81ba129a75b7?auto=format&fit=crop&w=1280&q=80', 4);

-- Features
INSERT INTO property_features (property_id, feature) VALUES
  (1, 'Modular kitchen'),
  (1, 'Front lawn'),
  (1, 'Car porch for 2 cars'),
  (1, 'Servant quarter'),
  (1, '24/7 security'),
  (2, 'Corner position'),
  (2, 'Wide frontage'),
  (2, 'Shutter and glass front'),
  (2, 'Parking nearby'),
  (3, 'Possession available'),
  (3, '60 ft road'),
  (3, 'Gas and electricity nearby'),
  (3, 'Close to park'),
  (4, 'Balcony'),
  (4, 'Lift'),
  (4, 'Covered parking'),
  (4, 'Backup power'),
  (4, 'Tiled floors'),
  (5, 'Gated society'),
  (5, 'Tiled flooring'),
  (5, 'Marble kitchen counters'),
  (5, 'Close to schools'),
  (6, 'Corner plot'),
  (6, 'Commercial zone'),
  (6, 'Easy motorway access'),
  (6, 'Possession available'),
  (7, 'Home theatre'),
  (7, 'Landscaped garden'),
  (7, 'Servant quarters'),
  (7, 'Imported fittings'),
  (7, 'Smart security'),
  (8, 'Fully furnished'),
  (8, 'Air conditioning'),
  (8, 'Internet ready'),
  (8, 'Gated building'),
  (9, 'Busy bazaar'),
  (9, 'Steel shutter'),
  (9, 'Electricity meter'),
  (9, 'Near metro station'),
  (10, 'Park facing'),
  (10, 'Corner plot'),
  (10, 'Developed block'),
  (10, 'Clear title'),
  (11, 'Double-height lounge'),
  (11, 'Front lawn'),
  (11, 'Wooden doors'),
  (11, 'Modular kitchen'),
  (11, 'Solar-ready roof'),
  (12, 'Balcony'),
  (12, 'Reserved parking'),
  (12, 'Gated security'),
  (12, 'Lift'),
  (12, 'Backup power'),
  (13, 'Lawn'),
  (13, 'Car porch'),
  (13, 'Bright rooms'),
  (13, 'Separate drawing room'),
  (13, 'Gas available'),
  (14, 'Sea breeze'),
  (14, 'Gym and lobby'),
  (14, 'Covered parking'),
  (14, 'Backup generator'),
  (14, '24/7 security'),
  (15, 'Prime avenue'),
  (15, 'Glass frontage'),
  (15, 'Air conditioned'),
  (15, 'Loading access'),
  (16, 'Developed sector'),
  (16, 'Possession available'),
  (16, 'Near park'),
  (16, 'Near mosque'),
  (17, 'Brand new'),
  (17, 'Imported tiles'),
  (17, 'Stylish elevation'),
  (17, 'Modular kitchen'),
  (17, 'Car porch'),
  (18, 'Fully furnished'),
  (18, 'City view'),
  (18, 'Lift'),
  (18, 'Covered parking'),
  (19, 'Double-height ceiling'),
  (19, 'Main road'),
  (19, 'Basement storage'),
  (19, 'Ample parking'),
  (20, 'Corner plot'),
  (20, 'Wide road'),
  (20, 'Developed block'),
  (20, 'Possession available'),
  (21, 'Well maintained'),
  (21, 'Near market'),
  (21, 'Gas available'),
  (21, 'Marble flooring'),
  (22, 'Sea-facing balcony'),
  (22, 'Clubhouse access'),
  (22, 'Swimming pool'),
  (22, 'Covered parking'),
  (23, 'Fully furnished'),
  (23, 'Garden'),
  (23, 'Servant quarter'),
  (23, 'Central heating'),
  (23, 'Car porch'),
  (24, 'Green surroundings'),
  (24, 'Farmhouse zone'),
  (24, 'Tube-well possible'),
  (24, 'Clear title'),
  (25, 'Corner shop'),
  (25, 'Busy market'),
  (25, 'Shutter front'),
  (25, 'Electricity meter'),
  (26, 'Private terrace'),
  (26, 'Mountain view'),
  (26, 'Two parking spots'),
  (26, 'Lift access'),
  (26, 'Smart home wiring'),
  (27, 'Fenced boundary'),
  (27, 'Heavy vehicle access'),
  (27, 'Electricity nearby'),
  (27, 'Flexible use'),
  (28, 'Newly built'),
  (28, 'Gated society'),
  (28, 'Modern design'),
  (28, 'Tiled flooring');

-- Sample favourites for the demo buyer
INSERT INTO favorites (user_id, property_id) VALUES
  (2, 1),
  (2, 7),
  (2, 11);

-- Sample meeting requests (demo buyer to demo seller)
INSERT INTO meetings (property_id, buyer_id, seller_id, meeting_date, meeting_time, note, rental_months, status) VALUES
  (1, 2, 3, '2026-11-12', '11:00 AM', 'I would like to visit on this day.', NULL, 'confirmed'),
  (8, 2, 3, '2026-11-14', '03:00 PM', 'Looking to move in next month.', 6, 'pending');

-- Sample deal: 10% off on first purchase, running for 6 hours after you import this file
INSERT INTO deals (id, title, discount_percent, starts_at, ends_at, is_active) VALUES
  (1, '10% off on first purchase', 10, NOW(), NOW() + INTERVAL 6 HOUR, 1);
INSERT INTO deal_properties (deal_id, property_id) VALUES
  (1, 1), (1, 4), (1, 11), (1, 14), (1, 17), (1, 22);

-- Red scrolling line messages
INSERT INTO announcements (message, sort_order) VALUES
  ('🎉 10% off on your first purchase', 1),
  ('⚡ Exclusive offer: limited-time deals on selected properties', 2),
  ('🏡 New listings added every day', 3),
  ('🔑 Buy or rent: houses, apartments, shops and plots', 4),
  ('📅 Request a meeting with the seller in one tap', 5),
  ('💬 Many prices are negotiable', 6);

-- =====================================================================
-- Handy queries
--   SELECT * FROM v_property_cards WHERE listing_mode = 'rent';
--   SELECT * FROM v_property_cards WHERE city = 'Lahore' AND property_type = 'apartment';
--   SELECT p.title, f.feature FROM properties p JOIN property_features f ON f.property_id = p.id WHERE p.id = 1;
--   SELECT m.*, p.title FROM meetings m JOIN properties p ON p.id = m.property_id WHERE m.seller_id = 3 AND m.status = 'pending';
-- =====================================================================
