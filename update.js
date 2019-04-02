const Handlebars = require('handlebars');
const Promise = require('bluebird');
const merge = require('lodash.merge');
const fs = Promise.promisifyAll(require("fs"));
const path = require("path");

const commonOptions = {
  phpVersion: '7.2.12',
  magento2Version: '2.3.1',
};

function readPartial(profile, section) {
  return fs.readFileAsync(path.join(__dirname, 'partials', profile, section), 'utf8');
}

function writeFile(context, profile, fileName, template) {
  return fs.readFileAsync(path.join(__dirname, template || `${fileName}.hbs`), 'utf8')
    .then(content => Handlebars.compile(content)(context))
    .then(content => fs.writeFileAsync(path.join(__dirname, profile, fileName), content));
}

function copyFile(fileName, profile) {
  return fs.copyFileAsync(path.join(__dirname, fileName), path.join(__dirname, profile, fileName));
}

const profiles = ['integrator', 'developer'];
const sections = ['magento2Installation', 'extraCronJobs'];
const filesToCopy = ['auth.json', 'install-magento', 'install-sampledata'];
const templatedFiles = ['Dockerfile', 'crontab'];
Promise.map(profiles, profile => {
  return Promise.reduce(sections, (obj, section) => {
    return readPartial(profile, section).then(value => {
      obj[section] = value;
      return obj;
    })
  }, {}).then(profileContext => {
    const context = merge({}, commonOptions, profileContext);
    return Promise.map(filesToCopy, fileToCopy => copyFile(fileToCopy, profile))
      .then(_ => Promise.map(templatedFiles, templatedFile => writeFile(context, profile, templatedFile)));
  });
}).then(() => console.log("Update successfully"))
  .catch(console.error);