# MP Custom Widgets - Agent Guide

## Build Commands
- `npm run dev` - Build in development mode with watch
- `npm run build` or `npm run prod` - Production build (outputs to dist/)
- `npm run create-widget` - CLI to scaffold a new widget

## Testing
No automated tests are configured in this project.

## Architecture
- **Core Library**: JavaScript library built with Webpack that enables custom widgets for MinistryPlatform
- **Entry Point**: src/index.js (builds to dist/js/customWidgetV1.js)
- **Structure**: src/ contains Modules/ and Services/ for core functionality
- **Widgets**: Individual widgets in Widgets/ directory (GroupFinder, MilestoneGamification, etc.)
- **Templating**: Uses LiquidJS for widget templates
- **Data Source**: Widgets connect to MinistryPlatform via stored procedures (prefixed with api_Custom_)

## Code Style
- JavaScript (ES6+) with Babel transpilation
- No TypeScript except CLI (cli/create-widget.ts)
- Use existing service modules (TemplateService, APIService) found in src/Services/
- Widget HTML uses data attributes (data-component, data-sp, data-template, data-host, etc.)
- Follow existing widget patterns in Widgets/ directory when creating new widgets
- Console logs are preserved (drop_console: false in webpack config)
- Source maps enabled for debugging

## CSS Framework (src/css/mp-custom.css)
- **Custom CSS Framework**: Lightweight, Bootstrap-like framework with `mp-` prefix for all classes
- **CSS Variables**: Customizable color scheme and spacing defined in `:root` (--mp-primary, --mp-secondary, etc.)
- **Components**: Includes badges, buttons, alerts, forms, tables, avatars, and sacrament-specific styling
- **Utility Classes**: Spacing (mp-m-*, mp-p-*), flexbox (mp-d-flex, mp-align-items-*), typography (mp-text-*)
- **Layout**: Responsive container system (.mp-container) with breakpoints at 576px, 768px, 992px, 1200px
- **Special Features**: Sacrament badges/icons, day-of-week badges forced to cobalt blue
- **Responsive Design**: Mobile-first with media queries for responsive adjustments

## Widget Module (src/Modules/WidgetModule.js)
- **Initialization**: WidgetModule.Init() finds all `[data-component="CustomWidget"]` elements and initializes them
- **Authentication**: Checks localStorage for `mpp-widgets_AuthToken` and `mpp-widgets_ExpiresAfter`
- **Data Attributes**: 
  - Required: `data-component`, `data-host`, `data-sp` (or `data-useCalendar`)
  - Optional: `data-template`, `data-templateId`, `data-params`, `data-cache`, `data-requireUser`, `data-debug`, `data-authOverride`
- **Host Configuration**: `data-host` must be church prefix ONLY (no http/https or domain)
- **Parameters**: `data-params` must include `@` character for stored procedure parameters (unless using calendar)
- **Calendar Mode**: Set `data-useCalendar="true"` to use MinistryPlatform Events API instead of stored procedure
- **JSON Stored Procedures**: If stored procedure name ends with `_json`, automatically parses JsonResult column
- **Events**: Dispatches `widgetLoaded` CustomEvent on both element and window with widgetId and data
- **Reinit Methods**: `ReinitWidget(elementId)` and `ReinitAllWidgets()` for dynamic reloading
