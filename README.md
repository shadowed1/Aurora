<p align="center">
  <img src="https://i.imgur.com/vhqBIyM.png" alt="logo" width="5000" />
</p>  


## *Run apps in Borealis using emulated AUR helpers, Flatpak, Git, Python, and GCC for signficantly higher performance than Crostini!*

**With Steam support ending in 2026, a new project is here!** <br>
Run Steam games and apps *natively* in ChromeOS with GUI, audio, and full GPU acceleration: <pre>https://github.com/shadowed1/Chard/blob/main/README.md</pre>

### Aurora Requirements: 

- ChromeOS
- Steam installed and open (log in not required)
- Steam (Borealis) VM can be enabled in chrome://flags for x86 users if below hardware requirements.  
<br>

### How to install:

- Open Crosh (ctrl-alt-t) and type in: <br>
`vsh borealis`

- Copy Paste in borealis shell: <br>
<pre>bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Aurora/main/aurora_installer.sh?$(date +%s)")</pre> <br>

*Aurora needs Borealis; it won't work anywhere else.*

<br>
<br>

### Features:

- Fantastic hardware acceleration for all apps; even unsupported web browsers.
- Steam can be closed entirely as long as an app is running.
- Borealis shell tabs automatically initiate Flatpak support.
- Tweak display scaling and cursor size. 
- Change default apps, generate shortcuts and icons, and download + extract tar files.
- Emulate pacman, yay, pacaur, and paru to download packages from arch repo directly. 
- Uninstaller is able to clean up after itself.

<br><br>


Minecraft Java with Prism Launcher @ 2160p:
<br>
<p align="center">
  <img src="https://i.imgur.com/SKNLuZb.png" alt="logo" width="5000" />
</p>  

<br><br>


### How to use: 

<br>

Commands with examples: <br>

`aurora                  # Show current display and cursor values` <br>
`aurora display 1.0      # Set display scaling factor (0.25 - 4.0)` <br>
`aurora cursor 32        # Set cursor size (8 - 200)` <br>
`aurora help             # Show help` <br>
`aurora_debug            # echo a list of paths that flatpak will use` <br>
`aurora reinstall        # Redownload Aurora from Github` <br>
`aurora uninstall        # Launch uninstaller` <br>
`aurora shortcut         # Create desktop shortcuts` <br> <br>


`starman                # Open GUI app launcher` <br>
`starman refresh        # Update app list` <br>

`starman                    # Open quick access menu` <br> 
`starman default            # Menu to set default apps` <br>
`starman reset              # Remove app entries in quick access menu` <br> <br>
`pacman https://archlinux.org/packages/extra/x86_64/libvlc/` <br>
`pacman vlc` <br>

`flatpak list               # Show list of installed apps` <br>
`flatpak --help             # flatpak has a lot of commands!` <br>

`flatpak search Discord` <br>
`flatpak install com.discordapp.Discord` <br>
`flatpak run com.discordapp.Discord` <br>

Failed to connect to bus error it must be run like example below: <br>

`Visual Studio:` <br>
`flatpak search visualstudio` <br>
`flatpak install com.visualstudio.code` <br>
`flatpak run --command=sh com.visualstudio.code` <br>
`/app/bin/code --no-sandbox  2>/dev/null` <br>
<br>
`Brave browser:` <br>
`flatpak search Brave` <br>
`flatpak install com.brave.Browser` <br>
`flatpak run --command=sh com.brave.Browser` <br>
`/app/brave/brave --no-sandbox --no-zygote --disable-gpu-sandbox --disable-features=UsePortal &` <br>
`Various Options:` <br>
`--no-sandbox --no-zygote --disable-gpu-sandbox --disable-features=UsePortal` <br>


Use ls /app/bin to help find the app in these situations.

<br>

- Apps and their data are saved in ~/opt/bin, ~/.local/share/flatpak, and Aurora + Flatpak are stored in~/opt/.
- --user argument is built-in for this Flatpak since we lack root access.
- Some apps will not run the conventional way. Brave or Visual Studio are good examples.<br>
- Both Brave and Visual Studio run significantly easier without Flatpak by downloading them straight from their websites!

  ### Appimages
  Appimages are not supported due to fuse mount issues. To bypass, run the .AppImage like this:
  `~/opt/usr/src/Brave-Web-Browser-stable-1.82.172-x86_64.AppImage --appimage-extract-and-run 2>/dev/null`
  Thanks to DennyL for finding this.


When running VS:
  
`flatpak run --command=sh com.visualstudio.code` <br>
`/app/bin/code --no-sandbox --no-zygote --disable-gpu-sandbox --disable-features=UsePortal` <br> <br>

When running Brave:

`flatpak run --command=sh com.brave.Browser` <br>
`/app/brave/brave --no-sandbox --no-zygote &` <br> <br>

- To find where an app is after opening a shell for the app, run:
`ls /app/bin` <br> <br>


- 4k DPI scaling is easy to apply. Before starting an app run:

`aurora display 2` to set scaling to 2x. <br>
`aurora cursor 32` will set the cursor to 32px. <br>

 Customize to your liking. Applying changes requires restarting app. <br><br>

  #### Sharing files (Similar to "Share with Linux")

 (optional) create a new folder under "MyFiles" (i.e. Steam_files)
 - Open Crosh (ctrl-alt-t) and type in: <br>
`vmc share borealis [folder path from MyFiles]` <br>
- in my example this would be:  <br>
  `vmc share borealis Steam_files` <br>
- if you simply want to share the whole downloads folder do: <br>
  `vmc share borealis Downloads` <br>

 ### How it works:

- Borealis offers hardware acceleration support that makes Crostini's poor performance untenable. 
- Downloads Flatpak and its required dependencies from Arch's repository.
- Extracts Flatpak to ~/opt/flatpak and its dependencies to ~/opt/flatpak-deps
- Adds .bashrc for flatpak commands to actually work.


### Changelog:
0.01: `Release` <br>
0.02: `Removed .bashrc file and added append capability. Added check to make sure not to install anywhere but Borealis.
Added uninstall and reinstall commands. Thanks to Saragon for the suggestions and teachimg me more about .bashrc.` <br><br>
0.03: `Added command to auto-generate shortcuts and icons with pin support. Thanks to Saragon for helping find how to do that. Added starman (steam tar manager) - download and decompress files, quick access menu, and change default apps. Added ability to download AppImages and run them with starman.` <br><br>
0.04: `Added quick reinstall option, starman AUR emulation, and shortcut ability from AUR emulation. Added ability to build packages using git, python, gcc.` <br><br>
0.05: `Fixed starman bug with link parsing. Added support for yay, paru, pacaur, and pacman to install packages multiple ways. Added version base 10 support.` <br><br>
0.06: `Improved shortcut command. Improved scaling support.` <br><br>
0.07: `Added bsdtar support for simpler extraction syntax. Improved starman download logic.` <br><br>
0.08: `Added permission fix logic for Starman. Fixed severe bug preventing install due to LD_LIBRARY_PATH being assigned too early.` <br><br>
0.09: `Fixed segfault issue on fresh install/reinstall. Improved shortcut fallback logic support. Significantly improved starman's ability to read PKGBUILD's for convenient downloading. Added /tmp/ folder support for cleaning up extracting packages. Fixed various syntax errors.` <br><br>
0.10: `Updated installer to be compatible with archlinux servers under a perpetual DDOS attack` <br><br>
0.11: `Fixed aurora cursor command, fixed reinstall command, introduced source syntax to make it clear how to update in-shell.` <br><br>
0.12: `Fixed libostree error affecting some Borealis users. Removed leftover.bashrc entries on reinstall/uninstall.` <br> <br>
To do list: Convince Google that Steam should remain supported. 

<br>


### Acknowledgments
- Saragon making great suggestions, educating me about .bashrc, improving readme, finding bugs, and working on making Steam shortcuts a reality:
https://github.com/Saragon4005

- Thanks to DennisLfromGA for finding bugs, making great suggestions, and finding issues to running certain apps:
https://github.com/DennisLfromGA

<br>

__Support__

- Feel free to post any issues here or on the ChromeOS discord - there is a thread dedicated to Aurora: https://discord.gg/chromeos
  

