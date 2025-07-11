# MP Custom CSS Framework

A lightweight, self-contained CSS framework for MP Custom Widgets, designed to replace Bootstrap dependencies.

## Features

- **No External Dependencies**: Self-contained CSS with no external libraries required
- **CSS Variables**: Easy customization through CSS custom properties
- **Bootstrap-Compatible Classes**: Familiar class names with `mp-` prefix to avoid conflicts
- **Responsive Design**: Built-in responsive utilities and breakpoints
- **Lightweight**: Minimal file size focused on essential components

## CSS Variables

### Colors
```css
:root {
  --mp-primary: #007bff;
  --mp-secondary: #6c757d;
  --mp-success: #28a745;
  --mp-info: #17a2b8;
  --mp-warning: #ffc107;
  --mp-danger: #dc3545;
  --mp-light: #f8f9fa;
  --mp-dark: #343a40;
}
```

### Typography
```css
:root {
  --mp-font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  --mp-font-size-base: 1rem;
  --mp-font-size-sm: 0.875rem;
  --mp-font-size-lg: 1.125rem;
}
```

### Spacing
```css
:root {
  --mp-spacer: 1rem;
  --mp-spacer-sm: 0.5rem;
  --mp-spacer-lg: 1.5rem;
  --mp-spacer-xl: 3rem;
}
```

## Class Reference

### Layout
- `.mp-container` - Responsive container with max-width breakpoints
- `.mp-d-flex` - Display flex
- `.mp-align-items-center` - Align items center
- `.mp-justify-content-center` - Justify content center

### Grid System
- `.mp-row` - Flex container for columns
- `.mp-col` - Auto-sized column
- `.mp-col-{1-12}` - Fixed-width columns (1-12)
- `.mp-col-xs-{1-12}` - Extra small screen columns (always applied)
- `.mp-col-sm-{1-12}` - Small screen columns (576px+)
- `.mp-col-md-{1-12}` - Medium screen columns (768px+)
- `.mp-col-lg-{1-12}` - Large screen columns (992px+)
- `.mp-offset-{1-11}` - Column offset utilities
- `.mp-offset-md-{1-11}` - Medium screen column offsets

### Typography
- `.mp-text-muted` - Muted text color
- `.mp-text-dark` - Dark text color
- `.mp-text-end` - Right-aligned text
- `.mp-text-center` - Center-aligned text
- `.mp-small` - Small font size

### Spacing
- `.mp-m-{0-5}` - Margin utilities
- `.mp-my-{0-5}` - Margin top and bottom
- `.mp-mt-{0-4}` - Margin top
- `.mp-mb-{0-4}` - Margin bottom
- `.mp-me-{0-3}` - Margin right
- `.mp-ms-{0-3}` - Margin left
- `.mp-ps-{0-5}` - Padding left
- `.mp-mt-auto` - Margin top auto
- `.mp-mb-auto` - Margin bottom auto
- `.mp-m-auto` - Margin auto
- `.mp-mx-auto` - Margin left and right auto

### Flexbox & Layout
- `.mp-d-flex` - Display flex
- `.mp-align-items-center` - Align items center
- `.mp-flex-column` - Flex direction column
- `.mp-flex-row` - Flex direction row
- `.mp-flex-wrap` - Flex wrap
- `.mp-flex-nowrap` - Flex nowrap

### Tables
- `.mp-table` - Basic table styling
- `.mp-table-bordered` - Table with borders
- `.mp-align-middle` - Vertical align middle

### Components
- `.mp-badge` - Badge component
- `.mp-badge-primary` - Primary badge
- `.mp-badge-secondary` - Secondary badge
- `.mp-avatar` - Avatar component
- `.mp-avatar-initial` - Avatar with initials
- `.mp-avatar-img` - Avatar with image

### Alerts
- `.mp-alert` - Base alert component
- `.mp-alert-primary` - Primary alert
- `.mp-alert-secondary` - Secondary alert
- `.mp-alert-success` - Success alert
- `.mp-alert-info` - Info alert
- `.mp-alert-warning` - Warning alert
- `.mp-alert-danger` - Danger alert
- `.mp-alert-light` - Light alert
- `.mp-alert-dark` - Dark alert

### Buttons
- `.mp-btn` - Base button component
- `.mp-btn-primary` - Primary button
- `.mp-btn-secondary` - Secondary button
- `.mp-btn-close` - Close button with X icon
- `.mp-btn-outline-primary` - Primary outline button
- `.mp-btn-outline-success` - Success outline button

### Modals
- `.mp-modal` - Base modal component
- `.mp-modal-dialog` - Modal dialog container
- `.mp-modal-content` - Modal content wrapper
- `.mp-modal-header` - Modal header
- `.mp-modal-title` - Modal title
- `.mp-modal-body` - Modal body content
- `.mp-modal-footer` - Modal footer

### Cards
- `.mp-card` - Base card component
- `.mp-card-body` - Card body content
- `.mp-card-title` - Card title
- `.mp-card-text` - Card text content
- `.mp-card-header` - Card header
- `.mp-card-footer` - Card footer

### Forms
- `.mp-form-control` - Form input styling
- `.mp-form-select` - Form select dropdown styling

### Background Colors
- `.mp-bg-primary` - Primary background
- `.mp-bg-secondary` - Secondary background
- `.mp-bg-success` - Success background
- `.mp-bg-info` - Info background
- `.mp-bg-warning` - Warning background
- `.mp-bg-danger` - Danger background

### Sacrament-Specific Badges
- `.mp-badge-baptism` - Baptism badge (soft blue)
- `.mp-badge-confirmation` - Confirmation badge (emerald green)
- `.mp-badge-first-communion` - First Communion badge (deep teal)
- `.mp-badge-reconcilliation` - Reconciliation badge (gray-blue)
- `.mp-badge-marriage` - Marriage badge (royal purple)
- `.mp-badge-holy-orders` - Holy Orders badge (golden amber)
- `.mp-badge-anointing` - Anointing badge (deep rose)
- `.mp-badge-death` - Death badge (charcoal gray)

## Usage

Include the CSS file in your HTML:

```html
<link href="/src/css/mp-custom.css" rel="stylesheet">
```

For modal functionality, also include the JavaScript:

```html
<script src="/src/js/mp-modal.js"></script>
```

Use the classes in your templates:

```html
<div class="mp-container">
  <h2>Family Sacraments</h2>
  
  <!-- Alert Example -->
  <div class="mp-alert mp-alert-success">
    User is logged in!
  </div>
  
  <!-- Button Example -->
  <button class="mp-btn mp-btn-primary">Click Me</button>
  
  <!-- Modal Example -->
  <div class="mp-modal" id="myModal">
    <div class="mp-modal-dialog">
      <div class="mp-modal-content">
        <div class="mp-modal-header">
          <h5 class="mp-modal-title">Modal Title</h5>
          <button class="mp-btn-close" data-mp-dismiss="modal"></button>
        </div>
        <div class="mp-modal-body">
          Modal content goes here...
        </div>
        <div class="mp-modal-footer">
          <button class="mp-btn mp-btn-secondary" data-mp-dismiss="modal">Close</button>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Grid Example -->
  <div class="mp-row">
    <div class="mp-col-md-6">
      <div class="mp-card">
        <div class="mp-card-body">
          <h5 class="mp-card-title">Card Title</h5>
          <p class="mp-card-text">Card content goes here...</p>
        </div>
      </div>
    </div>
    <div class="mp-col-md-6">
      <div class="mp-card">
        <div class="mp-card-body">
          <h5 class="mp-card-title">Another Card</h5>
          <p class="mp-card-text">More card content...</p>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Table Example -->
  <table class="mp-table mp-table-bordered">
    <tr>
      <td>
        <div class="mp-d-flex mp-align-items-center">
          <div class="mp-avatar mp-avatar-initial mp-me-3">J</div>
          <strong>John Doe</strong>
        </div>
      </td>
    </tr>
  </table>
</div>
```

## Customization

To customize colors, fonts, or spacing, override the CSS variables:

```css
:root {
  --mp-primary: #your-primary-color;
  --mp-font-family: "Your Font", sans-serif;
  --mp-spacer: 1.2rem;
}
```

## Migration from Bootstrap

Bootstrap classes are mapped to MP custom classes with the `mp-` prefix:

| Bootstrap | MP Custom |
|-----------|-----------|
| `container` | `mp-container` |
| `d-flex` | `mp-d-flex` |
| `text-muted` | `mp-text-muted` |
| `badge` | `mp-badge` |
| `table` | `mp-table` |
| `me-3` | `mp-me-3` |
| `ps-5` | `mp-ps-5` |
| `alert` | `mp-alert` |
| `alert-success` | `mp-alert-success` |
| `alert-warning` | `mp-alert-warning` |
| `mt-3` | `mp-mt-3` |
| `btn` | `mp-btn` |
| `btn-primary` | `mp-btn-primary` |
| `btn-secondary` | `mp-btn-secondary` |
| `btn-close` | `mp-btn-close` |
| `modal` | `mp-modal` |
| `modal-dialog` | `mp-modal-dialog` |
| `modal-content` | `mp-modal-content` |
| `modal-header` | `mp-modal-header` |
| `modal-title` | `mp-modal-title` |
| `modal-body` | `mp-modal-body` |
| `modal-footer` | `mp-modal-footer` |
| `data-bs-dismiss="modal"` | `data-mp-dismiss="modal"` |
| `container` | `mp-container` |
| `row` | `mp-row` |
| `col-md-6` | `mp-col-md-6` |
| `card` | `mp-card` |
| `card-body` | `mp-card-body` |
| `card-title` | `mp-card-title` |
| `card-text` | `mp-card-text` |
| `my-4` | `mp-my-4` |
| `mb-3` | `mp-mb-3` |
| `form-control` | `mp-form-control` |
| `form-select` | `mp-form-select` |
| `btn-outline-primary` | `mp-btn-outline-primary` |
| `btn-outline-success` | `mp-btn-outline-success` |
| `col-xs-12` | `mp-col-xs-12` |
| `col-sm-6` | `mp-col-sm-6` |
| `col-lg-4` | `mp-col-lg-4` |
| `offset-md-3` | `mp-offset-md-3` |
| `d-flex` | `mp-d-flex` |
| `flex-column` | `mp-flex-column` |
| `mt-auto` | `mp-mt-auto` |
| `h-100` | `mp-h-100` |
| `shadow` | `mp-shadow` |
| `bg-secondary` | `mp-bg-secondary` |
