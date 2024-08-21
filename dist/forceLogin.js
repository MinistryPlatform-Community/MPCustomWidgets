// Force Login Script
// Update the mpHost to match your MinistryPlatform configuration
// Simply include this script on any page with a user secured widget and it will automatically redirect to the SSO page and force the user to login

// -------------------------------------------------------
// CHANGE this to your MP HOST!!!
const mpHost = 'mpi.ministryplatform.com';
// -------------------------------------------------------


// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------
// YOU SHOULD NOT NEED TO CHANGE ANYTHING BELOW THIS COMMENT
// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

// Retrieve the value of the key from local storage
const authToken = localStorage.getItem('mpp-widgets_AuthToken');

// Construct final SSO Redirect URL
const ssoUrl = `https://${mpHost}/ministryplatformapi/oauth/connect/authorize?response_type=code&scope=openid%20http://www.thinkministry.com/dataplatform/scopes/all&client_id=TM.Widgets&redirect_uri=https://${mpHost}/widgets/signin-oidc&nonce=${generateNonce()}&state=${createStateUrl()}`;

// Get the Current URL
const currentUrl = window.location.href;

// Create a URL object
const url = new URL(currentUrl);

// Get the search parameters
const params = new URLSearchParams(url.search);

// Check if the key exists and has a non-empty value
if (authToken !== null && authToken !== '' && authToken !== 'null') {
    // User is Authenticated
    console.log("The 'mpp-widgets_AuthToken' key is present and has a value:", authToken);
} 
else if (params.has('mpCustomWidgetAuth'))
{
    // User has Authenticated, but Custom Widgets needs to wait for the MP Login Widget to finish initializing
    console.log("Waiting for Auth to Finalize");
}
else {
    // Prepare to Redirect to the Login URL
    console.log("The 'mpp-widgets_AuthToken' key is not present or is empty.");
    console.log('Preparing to redirect:');
    console.log(ssoUrl);
    window.location.href = ssoUrl;                
}

// Create a random Nonce string for OAuth Processing
function generateNonce(length = 16) {
    const array = new Uint8Array(length);
    window.crypto.getRandomValues(array);
    return Array.from(array, (byte) => byte.toString(16).padStart(2, '0')).join('');
}

// Create the StateUrl for redirecting after SSO Authentication
function createStateUrl()
{
    // Get the Current URL
    const currentUrl = window.location.href;

    // Create a URL object
    const url = new URL(currentUrl);

    // Get the search parameters
    const params = new URLSearchParams(url.search);

    // Prepare the stateUrl variable that will process the redirect after the user authenticates
    var stateUrl = `${currentUrl}`;
    // Check for QueryString Parameters in currentUrl to correctly handle state redirection
    if (stateUrl.includes('?'))
    {
        // Add mpCustomWidgetAuth query param to "force" custom widgets to wait for auth after SSO
        stateUrl += `&mpCustomWidgetAuth=true`;
    }
    else
    {
        // Non-Query String Version
        stateUrl += `?mpCustomWidgetAuth=true`;
    }

    // Return the string URL Encoded
    return encodeURIComponent(stateUrl);
}