# PropDeal

Property listings with accounts, buyer and seller pages, meeting scheduling and 3D visuals.
Plain HTML, CSS and JS. No install and no server needed.

## Files (keep them all in one folder)

| File | What it is |
|---|---|
| `index.html` | Login and Create account. Sends you to the right page by role. |
| `seller.html` | Seller page: add and delete listings, see meeting requests, accept or decline. |
| `property.html` | Full property page: photo gallery, asking price (negotiable or fixed), rent terms, long description, features and meeting request. |
| `buyer.html` | Buyer page: browse, open full property details, save favourites, schedule a meeting. |
| `style.css`, `app.js` | Shared design and logic. |
| `login.html` | Redirects to `index.html` (kept for old links). |

## How to use

Open `index.html`. Use "Use Seller / Buyer / Admin" for demo accounts, or create your own buyer or seller account.

| Role | Email | Password |
|---|---|---|
| Seller | seller@example.com | Seller@1234 |
| Buyer | buyer@example.com | Buyer@1234 |
| Admin | admin@example.com | Admin@1234 |

Try it: sign in as Buyer, open a property, schedule a meeting. Then sign in as Seller (demo seller owns the sample listings) and accept the request under "Meeting requests". The buyer sees the new status under "My meetings".

## Features

- 28 sample listings (houses, apartments, shops, plots) with 3 to 4 photos each. Filters: type, For Sale, For Rent, favourites.
- Sellers can list for sale or for rent, mark the price negotiable or fixed, set a minimum rental period and upload up to 4 photos.
- Buyers choose how many months they need when they ask to rent. The seller sees it in the meeting request.
- Click any card to open its full page.

## Buyer home: slideshow and limited-time deal

- The hero behind "Find your next deal" is a slideshow of featured property photos (auto-plays, dots to jump, pauses on hover).
- A countdown shows when the current deal ends. While it runs, 6 selected sale properties show a 10% OFF badge and the discounted price. When it reaches zero, a new set of deals goes live.
- Change the length, percentage and number of deals in `OFFER` near the top of the deals section in `app.js` (`hours`, `pct`, `count`).
- A red scrolling line runs along the very top of the page ("10% off on your first purchase" and more; edit the messages in `ticker()` in `app.js`). The hero photos change every 3 seconds.
- Sellers do not see the discount, slideshow or offers line.

## Database (MySQL / MariaDB)

`database/propdeal.sql` creates the `propdeal` database and fills it with everything the site shows: 3 demo accounts (bcrypt-hashed passwords), 28 listings, 100 photos, 122 features, sample favourites, sample meetings, a sample 10% deal and the red-line messages. `database/schema.sql` is the same structure without any data.

Import with phpMyAdmin (Import tab, choose `propdeal.sql`) or `mysql -u root -p < database/propdeal.sql`. Importing again resets the PropDeal tables.

Tables: `users`, `properties`, `property_images`, `property_features`, `favorites`, `meetings`, `deals`, `deal_properties`, `announcements`, and the view `v_property_cards`.

Note: the website itself still saves data in the browser. It does not read from MySQL until a backend (for example Node.js) is connected to this database.

## Accounts

The username is your **email**. Create your own buyer or seller account with "Create account" (no demo account needed). The three demo accounts are optional and can be edited in the `USERS` list at the top of `app.js`.

## Validation

- Email must contain `@` and be a valid address. Password: 6+ characters (sign-up also needs upper, lower, number and special character).
- Age and all numeric fields (age, price, bedrooms, bathrooms) accept digits only. Required fields cannot be empty.

## Look and feel

- Hero and login use a property photo, with a subtle particle background that reacts to the mouse or touch.
- Cards tilt in 3D, and the detail window flips open.

## Notes

- Accounts, listings, favourites and meetings are stored in the browser (localStorage), so they are shared between accounts in the same browser only.
- Passwords are stored as plain text in localStorage. This is for demo use only.
- Photos load from Unsplash. Without internet, built-in illustrations are shown.

## Put it online

Upload all files to a GitHub repo, then Settings → Pages → Branch `main`.
