#!/bin/bash
_sfpath="http://downloads.sourceforge.net/corefonts"
fonts=($_sfpath/andale32.exe $_sfpath/arial32.exe $_sfpath/arialb32.exe $_sfpath/comic32.exe $_sfpath/courie32.exe $_sfpath/georgi32.exe
$_sfpath/impact32.exe $_sfpath/times32.exe $_sfpath/trebuc32.exe $_sfpath/verdan32.exe $_sfpath/webdin32.exe)

for i in "${fonts[@]}"
do
    wget $i
    cabextract $(basename $i) -d fonts
done

