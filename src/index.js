import {WidgetModule as widget} from "./Modules/WidgetModule";

window.addEventListener('load', function () {
    widget.Init();
});

window.ReInitWidget = widget.ReinitWidget;
window.ReinitAllWidgets = widget.ReinitAllWidgets;