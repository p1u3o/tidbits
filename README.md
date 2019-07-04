# tidbits
Various things I do on Silverblue to avoid having to overlay packages and containers, mainly for myself.

### Nano

#### Ncurses

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
### Android Platform Tools (adb)

```bash
wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
unzip platform-tools-latest-linux.zip
sudo cp -v platform-tools/adb platform-tools/fastboot platform-tools/mke2fs* platform-tools/e2fsdroid /usr/local/bin
```
