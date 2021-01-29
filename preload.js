const {
    contextBridge,
    ipcRenderer
} = require('electron');

contextBridge.exposeInMainWorld(
    "api", {
        save_settings: (data) => {
            ipcRenderer.send("save_settings", data);
        },
        get_settings: () => {
            return ipcRenderer.sendSync("get_settings", "");
        }
    }
)