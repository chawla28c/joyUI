# JoyUi

Original, dependency-free, mobile-first admin UI starter. Version 0.3.

Open `index.html` directly in your browser. No installation or build step is required.

## Files

- `index.html`: sample dashboard and reusable markup
- `assets/css/joyui.css`: layout, components, responsive rules and theme tokens
- `assets/js/joyui.js`: mobile navigation, record filtering and in-memory sample form

## Customize

Edit CSS variables in `:root` to change colors, typography, radii and sidebar width. Reuse the sidebar/header as shared CodeIgniter view partials when integrating with JoyERP, Super or Account47. The UI currently has no PHP dependencies.

## Scope

This is a UI foundation, not a functioning ERP or accounting application. All figures are illustrative. The sample form adds records only to the current page; it does not save data. Authentication, permissions, database storage and backend integration are future work. Browser and real-device visual QA remain to be completed before production use.

## Usage

The CSS, JavaScript and HTML in this starter were newly written for this project. No third-party templates, fonts, icons, scripts or styles are bundled. No attribution footer is required by this project. You may use, modify and integrate these project files in your applications.

## Navigation

The header menu button hides or shows the sidebar on desktop and opens a drawer on mobile. The desktop content expands when the sidebar is hidden. On mobile, tap the backdrop or press Escape to close the drawer. Hidden navigation is removed from keyboard focus.

Click Sales, Purchase, Inventory or Accounts to expand its submodules. Clicking the same module closes it; opening another module closes the previous one. Submodule links display labeled placeholders for future integration, with the selected item highlighted. Add another module using a button with `aria-controls` pointing to a unique submenu ID and links with unique hash targets and a `data-module` label.

## Compact and mobile layout

Compact desktop defaults use a 220px sidebar, 58px header, tighter cards and table rows, and 34px form controls. Below 761px, controls and navigation use 44px touch targets and 16px input text; the form stacks into one column, summary cards use two columns, and wide tables scroll within their own region.
