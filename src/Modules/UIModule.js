export class UIModule {
    // Helper to get element by ID or return the element if it's already an object
    static getElement(elementOrId) {
        if (typeof elementOrId === "string") {
            return document.getElementById(elementOrId);
        } else if (elementOrId instanceof HTMLElement) {
            return elementOrId;
        } else {
            console.warn(`Invalid element or ID provided: ${elementOrId}`);
            return null;
        }
    }

    // ********************************************
    // HideElement - Hides Elements by ID or Object
    // ********************************************
    static HideElement(elementOrId) {
        const obj = UIModule.getElement(elementOrId);
        if (obj) {
            obj.style.display = "none";
            console.log(`HideElement: Element ${obj.id || "(no id)"} is now hidden.`);
        }
    }

    // ********************************************
    // ShowElement - Shows Elements by ID or Object
    // ********************************************
    static ShowElement(elementOrId) {
        const obj = UIModule.getElement(elementOrId);
        if (obj) {
            obj.style.display = "block";
            console.log(`ShowElement: Element ${obj.id || "(no id)"} is now visible.`);
        }
    }

    // ********************************************
    // DisableElement - Disables Elements by ID or Object
    // ********************************************
    static DisableElement(elementOrId) {
        const obj = UIModule.getElement(elementOrId);
        if (obj) {
            obj.disabled = true;
            console.log(`DisableElement: Element ${obj.id || "(no id)"} is now disabled.`);
        }
    }

    // ********************************************
    // EnableElement - Enables Elements by ID or Object
    // ********************************************
    static EnableElement(elementOrId) {
        const obj = UIModule.getElement(elementOrId);
        if (obj) {
            obj.disabled = false;
            console.log(`EnableElement: Element ${obj.id || "(no id)"} is now enabled.`);
        }
    }

    // ********************************************
    // UpdateButtonText - Updates Text for Buttons or A Elements
    // ********************************************
    static UpdateButtonText(elementOrId, text) {
        const obj = UIModule.getElement(elementOrId);
        if (obj) {
            const tagName = obj.tagName.toUpperCase();
            if (tagName === "BUTTON" || tagName === "A") {
                obj.textContent = text;
                console.log(`UpdateButtonText: Updated text of ${tagName.toLowerCase()} element ${obj.id || "(no id)"} to "${text}".`);
            } else {
                console.warn(`UpdateButtonText: Element ${obj.id || "(no id)"} is not a <button> or <a> element.`);
            }
        }
    }
   
}
