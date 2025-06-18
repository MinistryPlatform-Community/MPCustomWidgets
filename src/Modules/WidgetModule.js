import { ApiService as api } from "../Services/APIService";
import { TemplateService } from "../Services/TemplateService";

const skyApplication = `sky`;

export class WidgetModule {
    
    static async Init() {
        console.log('===> Widget Module Init...');
        console.info(`===> Custom Widget Version: process.env.BUILD_VERSION`);
        var elements = document.querySelectorAll('[data-component="CustomWidget"]');

        elements.forEach(element => {
            this.InitWidget(element);
        });
    }

    static async ReinitWidget(elementId){
        var element = document.getElementById(elementId);
        WidgetModule.InitWidget(element);
    }

    static async ReinitAllWidgets(){
        this.Init();
    }

    static checkForUser(){
        // Get Data
        var userData = this.getUserData();

        // Check Data
        if (userData == "null" || !userData || userData.length < 10)
        {
            return false;
        }        

        var expireDt = this.getAuthExpiration();
        var now = new Date();

        if (expireDt < now)
        {
            return false;
        }

        return true;
    }

    static getUserData()
    {
        var userData = localStorage.getItem("mpp-widgets_AuthToken");
        return userData;
    }

    static getAuthExpiration()
    {
        var expireData = localStorage.getItem("mpp-widgets_ExpiresAfter");
        if (expireData)
        {
            console.log(expireData);
            var expireDt = Date.parse(expireData);
            console.log(expireDt);
            return expireDt;
        }
        return null;
    }

    static async InitWidget(element){
        var storedprocedure = element.getAttribute('data-sp');
        var template = element.getAttribute('data-template');
        var templateId = element.getAttribute('data-templateId');        
        var cache = element.getAttribute('data-cache');
        var host = element.getAttribute('data-host');
        var params = element.getAttribute('data-params');

        var requireUser = false;
        if (element.getAttribute('data-requireUser') && element.getAttribute('data-requireUser').toLowerCase() === 'true')
        {
            requireUser = true;
        }

        var debugMode = false;
        if (element.getAttribute('data-debug'))
        {
            debugMode = true;
        }

        var useCalendar = false;
        if (element.getAttribute('data-useCalendar'))
        {
            useCalendar = true;
        }

        var authOverride = false;
        if (element.getAttribute('data-authOverride') && element.getAttribute('data-authOverride').toLowerCase() === 'true')
        {
            authOverride = true;
        }

        if (!host)
        {
            console.error("Host must refer to the church prefix ONLY and cannot contain http, https, or other characters");
            return;
        }

        if (host.indexOf(".") > -1 || host.indexOf("http") > -1)
        {
            console.error("Host must refer to the church prefix ONLY and cannot contain http, https, or other characters");
            return;
        }

        if (!useCalendar)
        {            
            if (params && params.indexOf("@") < 0)
            {
                console.warn("params must include the '@' character to correctly pass parameters to the data stored procedure");
            }

            // TODO: Split on & symbol and check each for @
        }

        if (storedprocedure && useCalendar)
        {
            console.warn("Stored Procedure and Use Calendar are configured.  In this case, only UseCalendar will be processed.  Please reivew your custom widget configuration and correct to avoid this warning.");
        }

        console.info('**************************************************');
        console.info(`Element ID:       ${element.id}`);
        console.info(`Host:             ${host}`);
        console.info(`Stored Procedure: ${storedprocedure}`);
        console.info(`Params:           ${params}`);
        console.info(`Template:         ${template}`);
        console.info(`Template ID:      ${templateId}`);
        console.info(`Require User:     ${requireUser}`);
        console.info(`Cache Data:       ${cache}`);
        console.info(`Use Calendar:     ${useCalendar}`);
        console.info(`Params:           ${params}`);
        console.info(`Debug Enabled:    ${debugMode}`);
        console.info(`Auth Override:    ${authOverride}`);
        console.info('**************************************************');
        
        this.LoadWidget(element.id, storedprocedure, params, template, templateId, requireUser, cache, host, useCalendar, debugMode, authOverride);

    }

    static async setupAuthRecheck()
    {
        if (this.authCheckCount == null)
        {
            this.authCheckCount = 0;
        }

        if (this.authCheckTimer == null && this.authCheckCount < 4)
        {
            console.info('|||===> Auth Check Scheduled');
            let wid = this;

            wid.authCheckTimer = window.setTimeout(function() {
                wid.authCheckTimer = null;
                wid.recheckAuth();
            }, 500);
            wid.authCheckCount++;
        }        
    }

    static async recheckAuth()
    {
        console.info('|||===> Checking Auth');
        if (this.checkForUser())
        {
            this.ReinitAllWidgets();
        }
        else
        {
            this.setupAuthRecheck();
        }
    }

    static async LoadWidget(elementId, storedprocedure, params, template, templateId, requireUser, cache, host, useCalendar, debugMode, authOverride)    {
        var element = document.getElementById(elementId);

        var data = {};

        // Execute Client Side Auth Check
        // NOTE: Widgets doesn't remove the localStorage, but sets it to "null" on logout
        if (requireUser)
        {
            if (!this.checkForUser())
            {
                data.userAuthenticated = false;
                console.info('|||===> No user is logged in.');

                if (!authOverride)
                {
                    element.innerHTML = `<div class="alert alert-danger alert-nologin">You must be logged in to see the details of this widget.</div>`;
                }
                else
                {
                    if (debugMode)
                    {
                        console.log('|||===> Data')
                        console.log(data);        
            
                    }

                    // Attempt to render Widget Template with only userAuthenticated data elements
                    await this.RenderTemplateWithData(templateId, template, data, element);
                }
                
                this.setupAuthRecheck();
                return;
            }
        }

        if (useCalendar)
        {
            data = await this.LoadCalendarData(params, cache, host);
        }
        else
        {
            data = await this.LoadWidgetData(this.getUserData(), requireUser, storedprocedure, params, cache, host);
        }

        // Append Widget ID data
        // Allows for more complicated re-use of templates in a single DOM
        data.widgetId = elementId;

        // Boolean for debugMode
        if (debugMode)
        {
            console.log('|||===> Data')
            console.log(data);        
        }

        // Append Authenticated Status to Widget Data
        console.info('***====> Checking for Authentication <====***');
        if (this.checkForUser())
        {
            console.info('===> User Authenticated');
            data.userAuthenticated = true;
        }
        else
        {
            console.warn('===> User NOT Authenticated');
            data.userAuthenticated = false;
        }

        // Attempt to render Widget Template
        await this.RenderTemplateWithData(templateId, template, data, element);

        // Trigger the widgetLoadedEvent
        // Pass the data object as data parameter
        var widgetLoadedEvent = new CustomEvent('widgetLoaded', {
            detail: { 
                widgetId: `${element.id}`,
                data: data
            }
        });

        // Custom Event Dispatch for Element
        element.dispatchEvent(widgetLoadedEvent);

        // Custom Event Dispatch for Window
        window.dispatchEvent(widgetLoadedEvent);
    }       
    
    static async RenderTemplateWithData(templateId, template, data, element)
    {
        try
        {
            if (templateId)
            {
                var templateElement = document.getElementById(templateId);
                var mergedTemplate = await TemplateService.GetRenderedTemplateString(templateElement.innerText, data);
                element.innerHTML = mergedTemplate;
            }
            else if (template)
            {
                var mergedTemplate = await TemplateService.GetRenderedTemplate(template, data);
                element.innerHTML = mergedTemplate;
            }
            else{
                console.error("Error while rendering template.");
                console.error(err);
    
                element.innerHTML = `<div class="alert alert-danger error">An error occurred while rendering the widget template</div>`;                
            }
        }
        catch (err)
        {
            console.error("Error while rendering template.");
            console.error(err);

            element.innerHTML = `<div class="alert alert-danger error">An error occurred while rendering the widget template</div>`;
        }        
    }

    static async LoadWidgetData(userData, requireUser, storedprocedure, params, cache, host)
    {
        var url = `https://${host}.cloudapps.ministryplatform.cloud/${skyApplication}/api/CustomWidget?storedProcedure=${storedprocedure}`;

        if (params)
        {
            url += `&spParams=${encodeURIComponent(this.replaceParameters(params))}`;
        }

        // Add userData to Request Parameters
        if (userData)
        {
            url += `&userData=${userData}`;
        }

        // Add cacheData to Request Parameters
        if (cache)
        {
            url += `&cacheData=${cache}`;
        }

        if (requireUser)
        {           
            // Add requireUser parameter to Request
            url += `&requireUser=true`;

            // Check UserData
            if (!userData) {
                console.error("Not logged in...");
                // Show Login Required
                element.innerHTML = `<div class="alert alert-danger error">Please login to see this widget.</div>`;
                return;
            }
        }

        const data = await api.getData(url);

        if (!data)
        {
            return null;
        }   

        // Check for JSON
        if (storedprocedure.toLowerCase().endsWith('_json'))
        {            
            console.info('|||===> JSON Stored Proc detected');

            // Check if data has the specific structure: single array, single row, single column named JsonResult
            if (data && typeof data === 'object' && Object.keys(data).length >= 1) {
                const datasetKey = Object.keys(data)[0];
                const dataset = data[datasetKey];
                
                if (Array.isArray(dataset) && dataset.length === 1 && 
                    dataset[0].hasOwnProperty('JsonResult') && 
                    typeof dataset[0].JsonResult === 'string') {
                    
                    try {
                        // Parse the JsonResult string as JSON
                        const parsedJson = JSON.parse(dataset[0].JsonResult);
                        
                        // Append widgetId and userAuthenticated from the original data object
                        if (data.widgetId) {
                            parsedJson.widgetId = data.widgetId;
                        }
                        if (typeof data.userAuthenticated !== 'undefined') {
                            parsedJson.userAuthenticated = data.userAuthenticated;
                        }
                        
                        console.info('|||===> JSON Parsed -> JSON Object Returned');
                        // console.info(parsedJson);

                        return parsedJson;
                    } catch (parseError) {
                        console.error('Failed to parse JsonResult as JSON:', parseError);
                        // Fall back to returning the original data structure
                        return data;
                    }
                }
            }

            // Attempt to return the data as JSON (original behavior)
            return data;
        }
        
        return data;
    }

    static async LoadCalendarData(params, cache, host)
    {
        var url = `https://${host}.cloudapps.ministryplatform.cloud/${skyApplication}/api/Events/GetEvents`;

        if (params.indexOf("?") > -1)
        {                  
            var resultString = params.replace("?", "");                        
            params = resultString;
        }

        if (params)
        {
            url += `?${params}`;
        }

        // Ensure that JSON DataFormat is enabled
        // Remove any ICAL Reference
        if (params.indexOf("&DataFormat=json") < -1)
        {
            url += `&DataFormat=json`;
            url.replace("&DataFormat=ical", "");
        }
        
        var data = await api.getData(url);

        var modelData = { "Events": data };

        return modelData;
    }    

    static replaceParameters(params)
    {
        var tParams = params;

        var re = /\[.*?]/ig
        var match;
        while ((match = re.exec(params)) != null){
            tParams = tParams.replace(match[0], this.getParameterByName(match[0]));
        }

        return tParams;
    }

    static getParameterByName(qsParam, url = window.location.href) {

        var name = qsParam.replace('[', '');
        name = name.replace(']', '');

        console.log('|||===> Getting Querystring Parameter:' + name);
        

        name = name.replace(/[\[\]]/g, '\\$&');
        var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
            results = regex.exec(url);

        if (!results) return null;
        if (!results[2]) return '';

        console.log('|||===> Param Value:' + decodeURIComponent(results[2].replace(/\+/g, ' ')));

        return decodeURIComponent(results[2].replace(/\+/g, ' '));
    }
}