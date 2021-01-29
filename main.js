const {
  app,
  BrowserWindow,
  ipcMain,
  session
} = require('electron');
const fs = require('fs');
const path = require('path');

function createWindow() {
  session.defaultSession.loadExtension(path.join(__dirname, "app/extension"));
    const mainWindow = new BrowserWindow({
    width: 1440,
    height: 810,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      enableRemoteModule: false,
      contextIsolation: true
    }
  });
  mainWindow.removeMenu()
  mainWindow.loadFile('app/index.html');
}

app.whenReady().then(() => {
  createWindow();

  app.on('activate', function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow()
  });
});

app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit()
});

ipcMain.on("save_settings", (event, arg) => {
  var raw_data = JSON.stringify(arg, null, 2);
  fs.writeFileSync('setting.json', raw_data);
});

ipcMain.on("get_settings", (event, arg) => {
  fs.readFile("setting.json", (err, data) => {
    var setting_data = JSON.parse(data);
    event.returnValue = setting_data;
  });
});