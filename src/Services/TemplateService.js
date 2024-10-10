import { Liquid } from 'liquidjs';

export class TemplateService {
    static Init() {
        this.engine = this.GetEngine();
    }

    static GetEngine() {
        this.engine = new Liquid({
            root: '/',
            extname: '.html'          // extension used for layouts/includes (.html) templates
        });

        this.engine.registerFilter('mp_currency', (value) => {
            return '$' + parseFloat(value).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
          });

        return this.engine;
    }

    static async GetRenderedTemplate(templateName, data) {

        if (!this.engine) {
            this.Init();
        }

        return await this.engine.renderFile(templateName, data)
    }

    static async GetRenderedTemplateString(templateString, data) {

        if (!this.engine) {
            this.Init();
        }

        return await this.engine.parseAndRender(templateString, data)
    }
}