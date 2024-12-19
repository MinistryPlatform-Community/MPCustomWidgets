# My Week Custom Widget

This is an exmple of a custom Widget that will return the next week's events for all contacts in a user's household.

## Features

- Shows upcoming events for the user and members of their household.
- Registration events, group events, and serving events have different FontAwesome icons to quickly distinguish them.
- Can be configured to require authentication or accept a parameter for User_GUID. Useful for linking to this widget from PocketPlatform!
- Optional CSS styling for "Dark Mode" included.
- Use the @DaysAhead parameter to change how many days ahead to show (Default=7).
- Use the @EventTypeID parameter to change what user campus or global event types will show up at the top of the day (Default=7, 0 to disable).
- Use the @FeaturedEvents parameter to show user campus or global featured events at the top of the day (Default=1, 0 to disable).

## Screenshots
Light Mode:

<img src="./Assets/Screenshot-MyWeekSample.png" width="300" />


Dark Mode:

<img src="./Assets/Screenshot-MyWeekSample-DarkMode.png" width="300" />