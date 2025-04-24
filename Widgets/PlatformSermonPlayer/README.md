# Widget Title

This is an exmple of a custom Widget that be deployed as a Record Insight to show a video player.  This was built for use with the PocketPlatform Sermons schema.

This example is built on:

[Bootstrap 5](https://getbootstrap.com/) with no custom css.
[Video.js](https://videojs.com/)

## Features

Allows the Platform to easily play sermons with metadata in the PocketPlatform schema by utilizing the custom widget within a record insight.

## Insight Code Minimal

This is a minimal configuration of the insight with no style changes.  Please NOTE that to implement this, you would need to have published the widget to some location.  In this case, the widget is published to the MinistryPlatform server at `https://mpi.ministryplatform.com/platformwidgets/sermonplayer.html`.  If you do not have access to the MinistryPlatform server, you will need to publish the widget to your own http/https accessible server and update the src attribute to point to your server.  Additionally, you will need to register the url with the Stock MP Widgets Permitted Urls based on this [Help Article](https://help.acst.com/en/ministryplatform/help-topics/widgets/enabling-widgets).

```html
<iframe class="insightCustomWidget" src="https://mpi.ministryplatform.com/platformwidgets/sermonplayer.html?sermonid=[Sermon_ID]" width="100%" height="100%" style="border: none;"></iframe>
```

## Insight with Custom Insight CSS

This example builds on the previous example by adding some custom css to the insight.  This is not required, but can be helpful allowing the insight to consume the space of 2 normal sized insights.

```html
<style>
  .webix_view:has(.insightCustomWidget) {
    overflow-x: auto !important;
  }

  .record-insight-wrapper:has(.insightCustomWidget) {
    overflow: hidden !important;
  }

  .record-insight:has(.insightCustomWidget),
  .record-insight-wrapper:has(.insightCustomWidget) {
    max-width: 496px !important;
    width: 100% !important;
  }

  .record-insight {
    -ms-overflow-style: none !important;
    scrollbar-width: none !important;
  }
</style>

<iframe class="insightCustomWidget" src="https://mpi.ministryplatform.com/platformwidgets/sermonplayer.html?sermonid=[Sermon_ID]" width="100%" height="100%" style="border: none;"></iframe>
```