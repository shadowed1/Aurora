<p align="center">
  <img src="https://i.imgur.com/vhqBIyM.png" alt="logo" width="5000" />
</p>  



## *Run apps and games in Borealis using Flatpak for signficantly higher performance than Crostini!*
### Requirements: 

- ChromeOS
- Steam installed and open
- Internet connection
- Logging into Steam is NOT required.  
<br>
<br>

### How to install:

- Open Crosh (ctrl-alt-t) and type in: <br>
`vsh borealis`

- Copy Paste in borealis shell: <br>
`bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Aurora/main/aurora_installer.sh?$(date +%s)")`

<br>
<br>

### Features:

- Steam can be closed entirely as long as an app is running.
- Borealis shell tabs automatically initiate Flatpak support.
  
<p align="center">
  <img src="https://i.imgur.com/JaW6d3P.png" alt="logo" width="5000" />
</p>  

- Aurora can tweak display scaling and cursor size. 
- Fantastic hardware acceleration for all apps; even unsupported web browsers
- Built-in GPU acceleration allows for longer battery life vs software rendering.
- Minecraft Java with Prism Launcher @ 2160p:

<p align="center">
  <img src="https://i.imgur.com/SKNLuZb.png" alt="logo" width="5000" />
</p>  




### How to use:

- Apps and their data are saved in ~/opt/
- --user argument is built-in for this Flatpak since we have no root access.
- Some apps will not run the conventional way. Brave or Visual Studio are good examples.<br>

When running VS:
  
`flatpak run --command=sh com.visualstudio.code` <br>
`/app/bin/code --no-sandbox --no-zygote --disable-gpu-sandbox --disable-features=UsePortal` <br> <br>

- To find where an app is after opening a shell for the app, run:
`ls /app/bin` <br> <br>


- 4k DPI scaling is easy to apply. Before starting an app run:

`aurora display 2` to set scaling to 2x. <br>
`aurora cursor 32` will set the cursor to 32px. <br>

 Customize to your liking. Applying changes requires restarting app. <br><br>

 ### How it works:

- Borealis offers hardware acceleration support that makes Crostini's poor performance untenable. 
- Downloads Flatpak and its required dependencies from Arch's repository.
- Extracts Flatpak to ~/opt/flatpak and its dependencies to ~/opt/flatpak-deps
- Adds .bashrc for flatpak commands to actually work.


### Limitations:
- Currently lacking Crostini's integration with the shelf
- To do: Default web browser support

### Changelog:
0.01: Release

### Acknowledgments
- Saragon making some great suggestions like using .bashrc and working on making Steam shortcuts a reality.
  

