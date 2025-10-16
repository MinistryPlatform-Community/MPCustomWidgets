#!/usr/bin/env tsx

import * as fs from 'fs';
import * as path from 'path';
import * as readline from 'readline';

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function question(prompt: string): Promise<string> {
  return new Promise((resolve) => {
    rl.question(prompt, (answer) => {
      resolve(answer);
    });
  });
}

function copyFolderRecursive(source: string, target: string): void {
  if (!fs.existsSync(target)) {
    fs.mkdirSync(target, { recursive: true });
  }

  const items = fs.readdirSync(source);

  for (const item of items) {
    const sourcePath = path.join(source, item);
    const targetPath = path.join(target, item);

    if (fs.lstatSync(sourcePath).isDirectory()) {
      copyFolderRecursive(sourcePath, targetPath);
    } else {
      fs.copyFileSync(sourcePath, targetPath);
    }
  }
}

async function main() {
  const widgetName = await question('Name of New Widget: ');
  
  if (!widgetName) {
    console.error('Widget name is required!');
    rl.close();
    process.exit(1);
  }

  const folderName = widgetName.replace(/\s+/g, '_');
  
  const templatePath = path.join(process.cwd(), 'Widgets', 'WidgetTemplate');
  const newWidgetPath = path.join(process.cwd(), 'Widgets', folderName);

  if (fs.existsSync(newWidgetPath)) {
    console.error(`Widget folder already exists: ${newWidgetPath}`);
    rl.close();
    process.exit(1);
  }

  console.log(`Creating widget: ${folderName}`);
  
  copyFolderRecursive(templatePath, newWidgetPath);

  const oldTemplatePath = path.join(newWidgetPath, 'Template', 'template.html');
  const newTemplatePath = path.join(newWidgetPath, 'Template', `${folderName}.html`);
  
  if (fs.existsSync(oldTemplatePath)) {
    fs.renameSync(oldTemplatePath, newTemplatePath);
    console.log(`Renamed template.html to ${folderName}.html`);
  }

  const demoPath = path.join(newWidgetPath, 'demo.html');
  let demoContent = fs.readFileSync(demoPath, 'utf-8');
  
  const oldPath = '/Widgets/WidgetTemplate/Template/template.html';
  const newPath = `/Widgets/${folderName}/Template/${folderName}.html`;
  
  demoContent = demoContent.replace(oldPath, newPath);
  
  demoContent = demoContent.replace(
    /<h2>Widget Template<\/h2>/,
    `<h2>${widgetName}</h2>`
  );
  
  demoContent = demoContent.replace(
    /<p>Clone this template when creating a new widget\.<\/p>/,
    '<p>Widget Cloned by create-widget</p>'
  );
  
  demoContent = demoContent.replace(
    /<h4>The data-template parameter must be updated to match the folder name of your cloned widget<\/h4>\s*/,
    ''
  );
  
  demoContent = demoContent.replace(
    /id="MyCustomWidget"/,
    `id="${folderName}"`
  );
  
  fs.writeFileSync(demoPath, demoContent, 'utf-8');
  console.log(`Updated demo.html with new template path`);

  console.log(`\nWidget created successfully at: ${newWidgetPath}`);
  
  rl.close();
}

main().catch((error) => {
  console.error('Error:', error);
  rl.close();
  process.exit(1);
});
