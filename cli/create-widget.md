# create-widget CLI Documentation

## Overview
The `create-widget.ts` CLI tool scaffolds new custom widgets for the MP Custom Widgets library by cloning the WidgetTemplate and customizing it with your widget name.

## Usage

```bash
npm run create-widget
```

You will be prompted:
```
Name of New Widget: 
```

Enter your widget name (can include spaces). The CLI will:
1. Convert the name to a folder-safe format (spaces → underscores)
2. Copy the WidgetTemplate to a new folder in `Widgets/`
3. Rename and update template files automatically
4. Update demo.html with the new widget configuration

## Example

```bash
$ npm run create-widget
Name of New Widget: My Awesome Widget

Creating widget: My_Awesome_Widget
Renamed template.html to My_Awesome_Widget.html
Updated demo.html with new template path

Widget created successfully at: s:/MPCustomWidgets/Widgets/My_Awesome_Widget
```

## What Gets Created

```
Widgets/
└── My_Awesome_Widget/          # New folder (spaces replaced with underscores)
    ├── Template/
    │   └── My_Awesome_Widget.html  # Renamed from template.html
    ├── demo.html               # Updated with correct paths and widget name
    └── README.md              # Template documentation
```

## Automated Updates

The CLI automatically modifies `demo.html`:

| What Changes | From | To |
|-------------|------|-----|
| Template path | `/Widgets/WidgetTemplate/Template/template.html` | `/Widgets/My_Awesome_Widget/Template/My_Awesome_Widget.html` |
| Widget heading | `<h2>Widget Template</h2>` | `<h2>My Awesome Widget</h2>` |
| Description | "Clone this template..." | "Widget Cloned by create-widget" |
| Element ID | `id="MyCustomWidget"` | `id="My_Awesome_Widget"` |
| Removes instructional text | `<h4>The data-template parameter must be updated...</h4>` | (deleted) |

## Functions

### `question(prompt: string): Promise<string>`
Prompts user for input and returns answer as a promise.

### `copyFolderRecursive(source: string, target: string): void`
Recursively copies all files and subdirectories from source to target.

### `main(): Promise<void>`
Main execution function:
1. Prompts for widget name
2. Validates input (exits if empty or folder exists)
3. Creates new widget folder from template
4. Renames template.html to match folder name
5. Updates demo.html with correct paths and names

## Error Handling

**Widget name required:**
```
Widget name is required!
```
Exit code: 1

**Widget already exists:**
```
Widget folder already exists: s:/MPCustomWidgets/Widgets/My_Widget
```
Exit code: 1

## Requirements
- Node.js with TypeScript support (tsx)
- Existing `Widgets/WidgetTemplate/` folder must be present
- Must be run from project root directory

## Next Steps After Creation
1. Edit `Widgets/YourWidget/Template/YourWidget.html` - Update LiquidJS template
2. Edit `Widgets/YourWidget/demo.html` - Configure data attributes (data-sp, data-host, etc.)
3. Create MinistryPlatform stored procedure (prefixed with `api_Custom_`)
4. Test widget using demo.html in browser
5. Update widget README.md with specific documentation
