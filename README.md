# Aurora

## *Run numerous apps and games through Borealis (Steam) for an enormous performance boost over Crostini!*
### Requirements: 

- ChromeOS
- Steam installed and open
- Internet connection

### How to install:

- Open Crosh (ctrl-alt-t) and type in: <br>
`vsh borealis`

- Copy Paste in borealis shell: <br>
`bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Aurora/main/aurora_installer.sh?$(date +%s)")`


### How it works:

- Borealis offers hardware acceleration support that makes Crostini's poor performance untenable. 
- Downloads Flatpak and its required dependencies from Arch's repository.
- Extracts Flatpak to ~/opt/flatpak and its dependencies to ~/opt/flatpak-deps
- Adds .bashrc for flatpak commands to actually work.
- Steam can be closed entirely as long as an app is running.
- Many apps will require to be run 'internally' see 'How to Use' section below.

### How to use:

- Apps and their data are saved in ~/opt/
- Please back up often, I am not 100% sure what will happen on Steam updates.  
- --user argument is built-in for Flatpak since we have no root access.

- Some apps will not work the conventional way like Brave or Visual Studio. When running VS:
  
`flatpak run --command=sh com.visualstudio.code` <br>
`/app/bin/code --no-sandbox --no-zygote --disable-gpu-sandbox --disable-features=UsePortal` <br> <br>

- To find where an app is after opening a shell for the app, run:
`ls /app/bin` <br> <br>


- 4k DPI scaling is easy to apply. Before starting an app run:

`aurora display 2` to set scaling to 2x. <br>
`aurora cursor 32` will set the cursor to 32px. <br>

 Customize to your liking. Applying changes requires restarting app. <br><br>

