# Makedeb
Makedeb is a packaging tool for Debian and Ubuntu based systems that aims to be simple and easy to use, whilst still remaining just as powerful as standard Debian tooling.

Makedeb tries to be compatible with Arch version of makepkg

# Building
Type the following commands to build makepkg .deb package:
```
make build
```
You will see builded package in the ./build directory. to order to install makepkg, just type as normal user:
```
make install
```
You will be prompted for sudo password to order to install package

