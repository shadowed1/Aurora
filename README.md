# Aurora

## *Installing and running apps in Borealis (Steam) for superb performance over Crostini!*

### Requirements: 

- ChromeOS
- Steam installed and open
- Internet connection

### How to install:

- Open Crosh (ctrl-alt-t) and type in: <br>
`vsh borealis`

- Copy Paste in borealis shell: <br>
`bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Aurora/main/aurora.sh?$(date +%s)")`


### How it works:

- Downloads Flatpak and its minimum required dependencies from Arch's repository.
- Extracts Flatpak to ~/opt/flatpak and its dependencies to ~/opt/flatpak-deps
- Adds .bashrc for flatpak commands to actually work.
- Steam can be closed entirely as long as an app is running.
- Many apps will require to be run 'internally' see 'How to Use' section below.

### How to use:

--user argument is always part of this Flatpak install since we have no root access.
  
`flatpak search firefox` <br>
`flatpak install flathub org.mozilla.firefox` <br>
`flatpak run org.mozilla.firefox` <br>

`flatpak run --command=sh com.visualstudio.code` <br>
`/app/bin/code --no-sandbox --no-zygote --disable-gpu-sandbox --disable-features=UsePortal` <br>
