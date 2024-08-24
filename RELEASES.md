# MP Custom Widget Releases

Below you can find the release history of MP Custom Widgets Core code. Please

## Release History

- 2024.08.24.1
  - Added authenticated:true|false to widget data based on login status
  - Added new optional parameter 'data-authOverride' which disables the automatic red alert when no user is authenticated.  If this is used with authenticated parameter in the widget data object, custom unauthenticated ui can be created in the template.  *NOTE - this requires additional work to properly check for DataSet existence before using datasets.  Please review new example called 'customAuth' for demo and details.
  - Updated Widget Template for easier cloning
  - Updated Cloud Version of customWidget.js  
- 2024.08.21.1
  - Added forceLogin.js script
  - Updated MyMissionTrips Demo to make use of the forceLogin.js script
- 2024.05.07.1
  - Added AddToCalendar Demo / Example
  - Added Staff Widget Demo / Example
- 2024.04.22.1
  - Restored Console Messages in CustomWidgets
  - Added Version Number Output on Start
  - Updated CDN Versions of CustomWidgets
- 2024.04.19.1
  - Updated LiquidJS to 10.11.0
    - This adds new exciting features. Read more in the [liquidJS release notes](https://github.com/harttle/liquidjs/blob/master/CHANGELOG.md)
  - Created NEW Liquid Filter mp_currency
    - This will format a number as US Currency ($1,234.51)
    - You can use this by add the liquid | mp_currency in your output tag
  - Updated all Packages and Dependencies
  - Updated CDN Version of customWidget.js from 2023.12.05.1 to 2024.04.19.1
    - Inline Templates and Updated User Detection now included in Cloud Version
    - Features all rolled up to CDN Version
- 2024.4.17
  - Updated BUILD of CustomWidget.js
  - Added Parish Progress Example Widget
- 2024.3.18
  - Updgraded Sky Middleware to .Net 8
  - Added Demo from Perimeter
- 2024.3.5
  - Added My Mission Trip Widget Sample Widget
  - Updated README Docs for Each Widget
  - Project Cleanup
- 2024.2.7
  - Added the ability to use inline templates via script tag
    - This is NOT in the CLOUD Hosted Instance Yet. Please pull a local copy of customWidget.js to use this functionality
- 2023.12.4
  - Fixed problems with Authentication and added new functionality for events (beta)
- 2023.11.17
  - Initial Release
