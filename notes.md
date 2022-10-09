# Issues, Random notes

* Fix CLion Issue: https://aur.archlinux.org/packages/clion/#comment-790360

* Orchis Theme
  https://github.com/vinceliuice/Tela-circle-icon-theme
  https://github.com/vinceliuice/Orchis-theme
  https://drive.google.com/file/d/13fOfn0gq38zOPBwi6wPjba0vEmdLvnNe/view


* Fix GDM getting stuck on startup 
  Edit `/etc/mkinitcpio.conf`
  ```
  ...
  MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
  ...
  ```
  Run `mkinitcpio -P`