export class HelperModule {
    static getUserAuthToken() {
        if (localStorage.getItem('mpp-widgets_AuthToken'))
        {
            return localStorage.getItem('mpp-widgets_AuthToken');
        }

        return null;
    }

    static async loadRecaptcha(siteKey) {
        const scriptUrl = `https://www.google.com/recaptcha/api.js?render=${siteKey}`;
        
        // Check if the script is already loaded
        if (!document.querySelector(`script[src="${scriptUrl}"]`)) {
            return new Promise((resolve, reject) => {
                const script = document.createElement("script");
                script.src = scriptUrl;
                script.async = true;
                script.defer = true;
                script.onload = resolve; // Resolve the promise once the script loads
                script.onerror = reject; // Reject the promise if there's an error
                document.head.appendChild(script);
            });
        }
        // If the script is already loaded, return immediately
        return Promise.resolve();
    }
    
    static async getGoogleRecaptchaToken(siteKey, action = "default") {
        // Ensure the reCAPTCHA script is loaded
        await HelperModule.loadRecaptcha(siteKey);
    
        // Wait for the grecaptcha object to be ready
        if (window.grecaptcha) {
            return new Promise((resolve, reject) => {
                window.grecaptcha.ready(() => {
                    window.grecaptcha
                        .execute(siteKey, { action })
                        .then(resolve) // Resolve with the token
                        .catch(reject); // Reject if there's an error
                });
            });
        } else {
            throw new Error("reCAPTCHA script failed to load properly.");
        }
    }     
}