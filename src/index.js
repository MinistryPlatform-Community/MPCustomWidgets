import { WidgetModule as widget } from "./Modules/WidgetModule";
import { HelperModule } from "./Modules/HelperModule";
import { UIModule } from "./Modules/UIModule";

// These Global Methods are maintained from earlier versions
// All New Exported Methods will be built on the window.Widgets namespace
window.ReInitWidget = widget.ReinitWidget;
window.ReinitAllWidgets = widget.ReinitAllWidgets;

// Create the Widgets namespace
window.Widgets = {
    // Attach Widget methods directly to the Widgets namespace
    init: widget.Init,
    reinitWidget: widget.ReinitWidget,
    reinitAllWidgets: widget.ReinitAllWidgets,

    // Create the Auth sub-namespace for authentication helper methods
    Auth: {
        getUserAuthToken: HelperModule.getUserAuthToken,
    },

    // Create a Helper sub-namespace for helper methods
    Helpers: {
        getGoogleRecaptchaToken: HelperModule.getGoogleRecaptchaToken,
    },

    UI:{
        hideElement: UIModule.HideElement,
        showElement: UIModule.ShowElement,
        disableElement: UIModule.DisableElement,
        enableElement: UIModule.EnableElement,
        updateButtonText: UIModule.UpdateButtonText,
    }
};

// Automatically initialize the widget on load
window.addEventListener('load', function () {
    window.Widgets.init();
});