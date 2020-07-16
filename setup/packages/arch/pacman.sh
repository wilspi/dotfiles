#!/usr/bin/env bash

sudo pacman -Syu

sudo pacman -S xorg xorg-server gnome gnome-extra
#sudo pacman -S xf86-video nvidia nvidia-lts amd-ucode pulseaudio pulseaudio-alsa webext-ublock-origin
sudo pacman -S guake git bash-completion chromium terminator vnstat ntfs-3g pacman-contrib docker firefox-ublock-origin atom spotify
sudo pacman -S zsh

# Install yay
#git clone https://aur.archlinux.org/yay.git
#cd yay/
#makepkg -si
#cd .. && rm -rf yay

yay -S postman6-bin clion
