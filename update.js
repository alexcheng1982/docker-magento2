const Handlebars = require("handlebars");
const Promise = require("bluebird");
const merge = require("lodash.merge");
const fs = Promise.promisifyAll(require("fs"));
const path = require("path");

const versions = [
  {
    phpVersion: "8.1",
    magento2Version: "2.4.6-p3",
    openSearchVersion: "2",
  },
  {
    phpVersion: "8.1",
    magento2Version: "2.4.5-p5",
    openSearchVersion: "1",
  },
  {
    phpVersion: "8.1",
    magento2Version: "2.4.4-p6",
    openSearchVersion: "1",
  },
];

function getVersionDir(version) {
  return path.join(__dirname, "versions", version);
}

function writeFile(context, version, fileName, template) {
  return fs
    .readFileAsync(path.join(__dirname, template || `${fileName}.hbs`), "utf8")
    .then((content) => Handlebars.compile(content)(context))
    .then((content) =>
      fs.writeFileAsync(path.join(getVersionDir(version), fileName), content)
    );
}

function copyFile(fileName, version) {
  return fs.copyFileAsync(
    path.join(__dirname, fileName),
    path.join(getVersionDir(version), fileName)
  );
}

function createVersionDir(version) {
  const dir = getVersionDir(version);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

const filesToCopy = [
  "auth.json",
  "install-magento",
  "install-sampledata",
  "env",
];
const templatedFiles = ["Dockerfile", "docker-compose.yaml"];
Promise.map(versions, (versionConfig) => {
  const context = merge({}, versionConfig);
  const version = versionConfig.magento2Version;
  createVersionDir(version);
  return Promise.map(filesToCopy, (fileToCopy) =>
    copyFile(fileToCopy, version)
  ).then((_) =>
    Promise.map(templatedFiles, (templatedFile) =>
      writeFile(context, version, templatedFile)
    )
  );
})
  .then(() => console.log("Updated successfully"))
  .catch(console.error);
