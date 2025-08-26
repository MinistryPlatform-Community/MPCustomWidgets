# Volunteer Tracker Widget

The Volunteer Tracker is a Domino’s Pizza Tracker–inspired widget that helps volunteers see exactly where they are in the application process. Just like watching your pizza go from “Order Placed” to “Out for Delivery,” this tracker moves you from “Application Received” to “Ready to Serve!”—minus the melted cheese (unless you’re volunteering in the kitchen 🍕).

## Features

- **Domino’s-Style Progress Bar**: Big, bold, and colorful stages that light up as you complete each requirement.
- **Stages Include**:
  1. **Received** – Your application is in!
  2. **Leader Review** – Waiting for approval from your leader.
  3. **Background Check** – Show if a background check is required.
  4. **Additional Requirements** – Tracks milestones, certifications, and forms.
  5. **Ready to Serve!** – All steps complete and you’re good to go.
- **Helpful Links**: Direct links to complete background checks or forms if they’re still pending.
- **Contact Info**: Displays the opportunity leader’s name and email for quick help.
- **No Auth Required**: Just add ?response=[Response_ID]&cid=[Contact_GUID] to the URL this widget is on to load the tracker.

## Configuration

- Modify the stored procedure parameters to reflect your church's setup:
  - **@BGCWebUrl** - Public web address for completing background checks. The Background_Check_GUID will be appended.
  - **@FormWebUrl** - Public web location of a Custom Form widget. The Form_GUID will be appended.
  - **@CheckTypeID** - The default/fallback Background_Check_Type_ID for your church.
  - **@EnforceVolunteerGroup** - If set to 1, then the widget will _only_ work with Groups with a Type that is set as a Volunteer Group.
- Create any "Requirement" records for the Group Role associated with the Opportunity, if needed. This widget will show all distinct requirements associated with the Group Role.
- If no Background Check is set in a requirement record, but the Group Role requires a Background Check, then the default/fallback @CheckTypeID will be used.
- The "Leader Review" step utilizes the "Response Result" field on the Response record. Blank/Null will leave it in the "Pending" state, "Not Placed" will change the tracker to the "closed" state, and any other "Response Result" will advance the tracker to the next stage.

## Screenshots

<img src="./Assets/screenshot-volunteertracker.png" width="800" />