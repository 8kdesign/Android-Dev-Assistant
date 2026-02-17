# Android Dev Assistant

**Android Dev Assistant** is a productivity tool for macOS designed to help Android developers save time. It combines essential tools for debugging and testing into one intuitive interface that anyone can use.

## Features

- **Quick APK Installation/Management**
   
   Drag and drop the apk file from your project's build filter to quickly install the latest build with a click. After installation, you can also cold restart or uninstall the app directly from the assistant.

- **Screenshot Edit + Sharing**
   
   Capture a screenshot on your device directly from your Mac, and it will be copied to your clipboard. You can also crop/highlight a particular section before sharing it with the built-in editor.

- **Display Size Switching**
   
   Mock a different display size/ratio on your device with just a click.

- **View Last Crash**

   Check the last crash logs on your device with a click, sorted from most recent to oldest.

- **Off-Commit File Search**

   View a file's state on another branch/commit without switching your current branch. Designed for large projects where switching branches could easily take a couple of minutes.

## Installation

1. Download the latest dmg file on your Mac.
2. Double-click to open, then drag and drop the app into the application folder.
3. Open the Android Dev Assistant app.

## How to Use

Toggle between apk/device and repository mode with the tabs above.

<p align="center">
<img width="233" height="93" alt="image" src="https://github.com/user-attachments/assets/9f99f9ef-8da1-4510-8c31-f39a9a1550de" />
</p>

### 📱 Apk/Device Mode

In this mode, you can carry out apk and device-specific tasks, such as apk installation, view crash logs, and mock screen size.

<p align="center">
<img width="1012" height="744" alt="image" src="https://github.com/user-attachments/assets/78f7db55-9c29-4f34-bf77-34dd9c54ae54" />
</p>

To import an apk file, drag it to the left panel. Ideally, the apk should be in the original folder it was generated in, so that it can be replaced by the latest build every time. After importing, you can tap on the toggles below to install, force restart, or uninstall the app.

<p align="center">
<img width="233" height="172" alt="image" src="https://github.com/user-attachments/assets/a5ca6f29-f4a9-494f-9759-4d07f474a38a" />
</p>

On the main panel, you will find tools for interacting with your device via ADB. If you have multiple devices connected, you can tap on the device name on top to open the menu to select your device.

<p align="center">
<img width="640" height="200" alt="image" src="https://github.com/user-attachments/assets/e7dd448a-2e86-4ee1-a1a0-b20fa6964b77" />
</p>

#### 1. Screenshot

The screenshot toggle allows you to quickly capture a screenshot. After capturing, it will automatically be copied to your Mac's clipboard, and a preview will pop up at the same time. A backup is also saved in the app's folder.

<p align="center">
<img width="302" height="250" alt="image" src="https://github.com/user-attachments/assets/eb297d43-b340-4f17-b8f7-a5e3c5b19291" />
</p>

Click on the preview to bring up the editor, where you can crop or highlight a particular section of the image.

<p align="center">
<img width="826" height="533" alt="image" src="https://github.com/user-attachments/assets/7e8ed81b-12ba-40e4-b369-cfa789be125a" />
</p>

#### 2. Mock Screen

Select a screen size from the list, and your device will mock it.

<p align="center">
<img width="826" height="533" alt="image" src="https://github.com/user-attachments/assets/25a91656-b56e-426a-82ef-73405d4f7b01" />
</p>

⚠️ Note: You will need to enable WRITE_SECURE_SETTINGS in the developer settings for this to work. If you encounter any UI issues, switch back to the default mode and restart your device to clear it.

#### 3. Crash Logs

Even after your app has closed, the crash logs are still stored on the device for a period of time. Quickly view the logs sorted in chronological order, starting with the most recent crash, and quickly copy them if needed.

<p align="center">
<img width="826" height="533" alt="image" src="https://github.com/user-attachments/assets/9f192ac3-c446-4336-a18e-815e96393068" />
</p>

### 🗃️ Repository Mode

Switching to repository mode, you will be able to browse files across any commits and branches without switching to them.

<p align="center">
<img width="1012" height="744" alt="image" src="https://github.com/user-attachments/assets/f84031e2-b574-4d23-b03e-a9af678de2e5" />
</p>

To get started, drag your project folder (which contains the git folder) into the left panel to import it.

<p align="center">
<img width="236" height="157" alt="image" src="https://github.com/user-attachments/assets/0214507f-65b5-4e7c-b7c9-4695c3030f08" />
</p>

Then, on the main panel, tap on the current branch to select the branch you want to view. Next, select the commit that you are interested in, and the tool will load all the files in the commit. Larger projects may take a while.

<p align="center">
<img width="236" height="233" alt="image" src="https://github.com/user-attachments/assets/3e0b58e9-064b-4e0e-bf31-452e2ce733f7" />
</p>

Once the files are ready, the spinner should go away, and you will be able to use the search bar to look for any file in the project.

<p align="center">
<img width="416" height="451" alt="image" src="https://github.com/user-attachments/assets/8a7235e7-5fca-44c9-ac77-2b966c96d7f0" />
</p>

Right-click to copy the entire file, or click on lines to select them before right-clicking them to copy a range of lines.
