#!/usr/bin/env bash

sudo pacman -Syu

sudo pacman -S xorg
#sudo pacman -S xfce4
sudo pacman -S gnome 
sudo pacman -S nvidia amd-ucode 
sudo pacman -S pulseaudio pulseaudio-alsa pulseaudio-bluetooth

#sudo pacman -S webext-ublock-origin
sudo pacman -S guake git bash-completion terminator ntfs-3g pacman-contrib firefox firefox-ublock-origin atom
sudo pacman -S zsh
sudo pacman -S obs-studio chromium vnstat net-tools docker

sudo pacman -S gnome-tweak-tool python-nautilus


# Install yay
#git clone https://aur.archlinux.org/yay.git
#cd yay/
#makepkg -si
#cd .. && rm -rf yay

yay -S postman6-bin clion
yay -S typora huestacian nix tor-browser spotify
#yay -S zoom
