#!/usr/bin/env bash

sudo pacman -Syu

sudo pacman -S xorg
#sudo pacman -S xfce4
sudo pacman -S gnome
sudo pacman -S nvidia amd-ucode
sudo pacman -S pulseaudio pulseaudio-alsa pulseaudio-bluetooth

#sudo pacman -S webext-ublock-origin
sudo pacman -S guake git bash-completion terminator ntfs-3g pacman-contrib firefox atom
sudo pacman -S obs-studio chromium vnstat net-tools docker hugo redis firefox-ublock-origin
sudo pacman -S gnome-tweak-tool python-nautilus


# Install yay
#git clone https://aur.archlinux.org/yay.git
#cd yay/
#makepkg -si
#cd .. && rm -rf yay

sudo pacman -S jdk-openjdk
yay -S clion


yay -S typora huestacean spotify
#yay -S zoom tor-browser

sudo pacman -S vlc zsh
sudo pacman -S obs-studio
yay -S postman6-bin discord

yay -S nix

yay -S brave-bin
pacman -S htop wget transmission-gtk ttf-roboto ttf-roboto-mono

## Enable multilib, pacman -> parrallel downloads /etc/pacman.conf
pacman -S steam


# Auto download jetbrain plugins
# https://plugins.jetbrains.com/plugin/download?rel=true&updateId=112365

## Jetbrains config save