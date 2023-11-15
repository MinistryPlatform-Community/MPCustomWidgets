# MP Custom Widget Samples

This is a collection of custom widgets built against the Custom Widget Toolkit. You will find samples from Group Finders to calendars to KPI widgets.

## Contribute

If you have a widget to submit to the sample collection, please fork this collection, add your widget and all supporting resources / assets and submit a pull request. New widgets will be reviewed every 2 weeks and if deemed reusable and unique, will be added to the samples collection.

# Widget Examples

- [Group Finder](./Widgets/GroupFinder/GroupFinder.md)
- [Milestone Gamification](./Widgets/MilestoneGamification/MilestoneGamification.md)
- [Publication Widgets](./Widgets/PublicationWidgets/PublicationWidgets.md)
- [View Message In Browser](./Widgets/ViewMessageInBrowser/ViewMessageInBrowser.md)

# Custom Widget Features

Custom Widgets has a growing list of features available to Citizen Developers seeking to build lightweight read-only widgets capable of accessing any data in [MinistryPlatform](https://www.ministryplatform.com).

## Custom Widget Tag Features

The Widget Tag is used to embed the widget into a webpage. Each custom widget will use this tag on one or multiple pages to render the widget directly into the website.

## Custom Widget Javascript

You can find the [customWidget.js](./dist/) files in the "DIST" folder or you can reference the latest version from the MinistryPlatform CDN:

[https://cdn.ministryplatform.com/customwidgets/dist/customWidgetLatest.js](https://cdn.ministryplatform.com/customwidgets/dist/customWidgetLatest.js)

Example of including the javascript file in your webpage:

```javascript
<script type="text/javascript" src="../../dist/customWidget.js"></script>
```
