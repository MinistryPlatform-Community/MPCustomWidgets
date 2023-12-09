# MP Custom Widget Samples

This is a collection of custom widgets built against the Custom Widget Toolkit. You will find samples from Group Finders to calendars to KPI widgets.

# Customer Examples

Here you can see what other churches have created for inspiration or to get an idea of just how flexible a Custom Widget can be:

- [Lutheran Church of Hope Classes Widget](https://wdm.lutheranchurchofhope.org/get-involved/classes/)
- [Granger Church Core Classes Dates and Times](https://grangerchurch.com/core/)

## Contribute

If you have a widget to submit to the sample collection, please fork this collection, add your widget and all supporting resources / assets and submit a pull request. New widgets will be reviewed every 2 weeks and if deemed reusable and unique, will be added to the samples collection.

# Custom Widget Examples

- [Group Finder](./Widgets/GroupFinder/GroupFinder.md)
- [Milestone Gamification](./Widgets/MilestoneGamification/MilestoneGamification.md)
- [Publication Widgets](./Widgets/PublicationWidgets/PublicationWidgets.md)
- [View Message In Browser](./Widgets/ViewMessageInBrowser/ViewMessageInBrowser.md)

# Custom Widget Release Information

Custom Widget core code is updated periodically. If you would like to see a history of changes, please visit the releases page:

[Custom Widget Release History](./RELEASES.md)

# Custom Widgets MP Community

There is a special section on the MP Community for Custom Widgets. You can follow this link, but if you don't have access, you might need to request it. Right now this forum is NOT open to everyone as this is still very much an early release / innovation project.

[Community Forum](https://mpcommunity.ministrysmart.com/custom-widgets)

# Custom Widget Features

Custom Widgets has a growing list of features available to Citizen Developers seeking to build lightweight read-only widgets capable of accessing any data in [MinistryPlatform](https://www.ministryplatform.com).

## Custom Widget Tag Features

The Widget Tag is used to embed the widget into a webpage. Each custom widget will use this tag on one or multiple pages to render the widget directly into the website.

```html
<div
  id="MyCustomWidget"
  data-component="CustomWidget"
  data-sp="api_Custom_StoredProcedure"
  data-useCalendar="true"
  data-params="@ParamName=ParmValue"
  data-template="/Path/To/Template/TemplateName.html"
  data-requireUser="false"
  data-cache="true"
  data-debug="true"
  data-host="mpi"
></div>
```

### id="MyCustomWidgetName"

- **_required_** attribute
- Standard DOM ID for the element
- The ID must be a unique name across all elements on the page

### data-component="CustomWidget"

- **_required_** attribute
- This defines the element as a custom widget and automatically renders it as a custom widget when the DOM is loaded

### data-sp="api_Custom_StoredProcedure"

- This defines the stored procedure to use for data retrieval when this custom widget is rendered. **_Note_** - All Stored Procedures **MUST** be prefixed by api_Custom in order to be used. Additionally, any Stored Procedure **MUST** also be registered in the MinistryPlatform meta data to be accessible by Custom Widgets or the REST api at all.

### data-useCalendar="true"

- _Defaults to: false_
- When this is set to true, the params are sent to the Event API instead of a Stored Procedure. If this is set to true it will override the data-sp parameter and events will be used instead of a Stored Procedure.

### data-params="@ParamName=ParmValue"

- Allows Parameters to be used for the innvocation of the Stored Procedure. SQL Parameter are prefixed the **@** symbol and are passed to the Custome Widget in key value pairs.
- Using Params allows a single Custom Widget to be used for various Minsitries, Campuses, etc by easily allowing parameters to be passed to set the context for the specific rendering of the widget.
- **Query String Support** - If you wrap the value component of an individual parameter key value pair in square brackets **[** **]**. The value will be retrieved from the correlating named QueryString parameter found in the current URL.
  - _Example_ - @Param=[id] - This would retrieve the value of ?id=something from the querystring of the URL and place that dynamically in the parameters sent to the stored procedure or call to the Event API.
  - By using the querystring support, you can quickly build dynamic widgets that can take dynamic data from other pages / widgets / links and create custom widgets on the fly.

### data-template="/Path/To/Template/TemplateName.html"

- **_required_** attribute
- This defines the path to the widget template. Custom Widgets use the [LiquidJS](https://liquidjs.com/) templating engine to render standard HTML / CSS with data retrieved from MinistryPlatform. There is ample documentation available on the Liquid website and on other help systems easily found by searching the web.
- For more information on common Liquid Usage, [Jump to Liquid Intro]()./liquid.md)
- **Note** - data-template does **NOT** support relative paths. If you just use the template name (mytemplatename.html) or even (./mytemplatename.html) you will see a 404 error when custom widgets tries to load the template. You **need** to either use the full _URL_ (https://www.whatever.com/templates/mytemplate.html) or a full relative path (/templates/mytemplate.html)

### data-requireUser="false"

- _Defaults to: false_
- When set to true, the widget will require a user to be logged in. Login is accomplished by using the standard MP Login Widget. Note: Anytime a user is loggded in to widgets on the website hosting the custom widget, the user will be sent with the request.
- If you set the requireUser="true", you should also include the @UserName parameter to be non-nullable in your stored procedure to enforce the username requirement across all parts of the custom widget system.
- **Note** - You must include a @Username nvarchar(75) nonnullable parameter in your Stored Procedure. To compare against User_ID, don't forget to query for User_ID.

### data-cache="true"

- _Defaults to: true_
- This parameter controls whether or not the data element is cached. This defaults to _true_ to improve performance. The cached data is held in memory and does not hit the MinistryPlatform instance on each request.
- Cache is computed from the Stored Procedure Name and **ALL** params that are sent with the request.
- Cache Timeout is 5 minutes and is absolute. This means data is cached upon the first request and is cached for the duration of 5 minutes.

### data-debug="true"

- _Defaults to: false_
- When set to _true_, the javascript engine with output extra debugging information in the javascript console. In addition to various debugging messages about Widget Initialization and Rendering, **all** data retrieved from the Stored Procedure or Events API will be output to the console.
- **_Best Practice_** - Set this to false or just remove the data-debug element entirely when publishing to production.

### data-host="mpi"

- **_required_** attribute
- This is the MinistryPlatform Cloud Host. This value is unique per customer and is easily located by Launching the Add / Edit Family Tool and noting the first element of the hostname.
- ![AEFT](./aeft.png)

## Custom Widget Javascript

You can find the [customWidget.js](./dist/) files in the "DIST" folder if you want to download them or you can reference the latest version from the MinistryPlatform CDN:

[https://mpweb.azureedge.net/cdn/customWidget.js](https://mpweb.azureedge.net/cdn/customWidget.js)

Example of including the javascript file in your webpage:

```javascript
<script
  type="text/javascript"
  src="https://mpweb.azureedge.net/cdn/customWidget.js"
></script>
```
