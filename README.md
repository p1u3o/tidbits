# Silverblue tidbits
Some things I do on Fedora Silverblue (best Linux desktop 😀️) to get software I want on the host whilst trying to avoid package overlaying. This is entirely for myself, but maybe others might find it useful.

- Contents
	- [Google Chrome](#google-chrome)
  - [Nano](#nano)
  - [Android Tools (adb, fastboot etc)](#android-tools-adb-fastboot-etc)
  - [MS Core Fonts](#ms-core-fonts) Arial, Courier, Times, Webdings etc
  - [youtube-dl](#youtube-dl)
  - [wireguard](#wireguard)
  - [Broadcom Wireless Driver (wl/b43)](#broadcom)
  - [NVIDIA](#nvidia)
  - [Visual Studio Code (Prompt & SDKs)](#vscode-tweaks)
  - [Large /sysroot/ostree/repo](#ostree-prune)

### Google Chrome
It's a bad idea to install the Google Chrome RPM, you'll eventually get stuck in an update loop where the rpm keeps replacing the update each time.

#### Repo

```bash
sudo -i
```
```bash
cat << EOF > /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
```

#### Install

```bash
rpm-ostree install google-chrome-stable
```
---

### Nano

#### ncurses

```bash
wget https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.1.tar.gz
tar -xvf ncurses-6.1.tar.gz && cd ncurses-6.1
./configure --prefix=/usr/local
make -j4
sudo make install
```

#### nano
```bash
wget https://www.nano-editor.org/dist/v4/nano-4.3.tar.gz
tar -xvf nano-4.3.tar.gz && cd nano-4.3
CFLAGS="-I/usr/local/include/ncurses" ./configure --prefix=/usr/local
make -j4
sudo make install
```
---

### Android Tools (adb, fastboot etc)

```bash
wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
unzip platform-tools-latest-linux.zip
sudo cp -v platform-tools/adb platform-tools/fastboot platform-tools/mke2fs* platform-tools/e2fsdroid /usr/local/bin
```

#### Device rules (to use without root)

```bash
git clone https://github.com/M0Rf30/android-udev-rules.git
cd android-udev-rules
sudo cp -v 51-android.rules /etc/udev/rules.d/51-android.rules
sudo chmod a+r /etc/udev/rules.d/51-android.rules
sudo groupadd adbusers
sudo usermod -a -G adbusers $(whoami)
sudo systemctl restart systemd-udevd.service
adb kill-server
adb devices
```
---

### MS Core Fonts

#### cabextract
```bash
wget https://www.cabextract.org.uk/cabextract-1.9.1.tar.gz
tar -xvf cabextract-1.9.1.tar.gz
cd cabextract-1.9.1
./configure --prefix=/usr/local && make
sudo make install
```

#### mscorefonts.sh

```bash
wget https://raw.githubusercontent.com/p1u3o/tidbits/master/mscorefonts.sh
sh mscorefonts.sh
```
##### To install user-wide (Flatpak will see these)
```bash
mkdir ~/.local/share/fonts
mkdir ~/.local/share/fonts/mscorefonts
cp -v fonts/*.ttf fonts/*.TTF ~/.local/share/fonts/mscorefonts/
```
##### To install system-wide (Flatpak might not see these yet)
```bash
sudo mkdir /usr/local/share/fonts/
sudo mkdir /usr/local/share/fonts/mscorefonts/
sudo cp -v fonts/*.ttf fonts/*.TTF /usr/local/share/fonts/mscorefonts/
```
---

### youtube-dl

#### Python Fix
```bash
sudo ln -s /usr/bin/python3 /usr/local/bin/python
```
#### youtube-dl
```bash
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
sudo chmod a+rx /usr/local/bin/youtube-dl
youtube-dl
```
---

### wireguard

#### rpm fusion

Enable RPM Fusion if you haven't already

```bash
sudo rpm-ostree install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```
Reboot

#### kmod

```bash
rpm-ostree install akmod-wireguard
```
Reboot

---

### Broadcom

#### rpm fusion

Enable RPM Fusion if you haven't already

```bash
sudo rpm-ostree install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```
Reboot

#### non-free driver (wl)

This driver is not open source and is known to be unreliable. If possible use the alternative driver below if your hardware supports it.

```bash
rpm-ostree install akmod-wl
```
Reboot

#### free driver (b43)

Please see [here](https://wireless.wiki.kernel.org/en/users/Drivers/b43#Supported_devices) that your hardware is supported before using this.

The open source driver still needs firmware files.

```bash
rpm-ostree install http://download1.rpmfusion.org/nonfree/fedora/tainted/30/x86_64/Packages/b/b43-firmware-6.30.163.46-4.fc30.noarch.rpm
```
Reboot

---

### NVIDIA

#### rpm fusion

Enable RPM Fusion if you haven't already

```bash
sudo rpm-ostree install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```
Reboot

#### kmod & drivers

```bash
rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda
rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1
```

#### initramfs

If you want to make sure the nvidia driver is part of the initramfs, which allows the modesetting driver to work sooner (full screen boot logo), enable initramfs generation. I personally recommend this, although it comes at the cost of slower updates.

```bash
rpm-ostree initramfs --enable
```

Reboot

#### note

Fedora has a fast updating kernel, sometimes the kernel can be updated before the nvidia driver does and rpm-ostree will fail to install updates.

There is no need to worry when this happens, ostree is preventing your computer from updating to a point where it won't work. Simply wait a day or two for the nvidia driver to be updated or try enabling the testing repo `/etc/yum.repos.d/rpmfusion-nonfree-updates-testing.repo` to see if that already has a newer driver.

---

### VSCode Tweaks
#### Fix Terminal Prompt

bash-4.4$ => [user@host project/src]$

Add to the end of your ~/.bashrc

```bash
if [ "$FLATPAK_ID" == "com.visualstudio.code" ]; then
	export PS1="[\u@\h \W]\\$ "
fi
```

#### SDKs (PHP, Java, Golang, Rust etc)

These add compilers, runtimes etc these languages to Flatpak, and VSCode can see these. They get installed to /usr/lib/sdk however VSCode will pickup a few automatically.

`flatpak install <sdk>`

- Java | org.freedesktop.Sdk.Extension.openjdk[9-11]
- PHP | org.freedesktop.Sdk.Extension.php73
- Node | org.freedesktop.Sdk.Extension.node10
- Go | org.freedesktop.Sdk.Extension.golang
- .NET | org.freedesktop.Sdk.Extension.dotnet
- Rust | org.freedesktop.Sdk.Extension.rust-stable

You can find more by searching for them
`flatpak search org.freedesktop.Sdk.Extension`desktop

### OSTree Prune

If you're like me and have messed around with rebases, you may find /sysroot/ostree/repo has become multiple times larger than /usr itself, and `rpm-ostree cleanup` won't fix this.

Instead, you just need to prune. This freed up 15GB for me, but your results may vary depending on your rebases.

```sudo ostree prune```
