#!/bin/sh

# set -e

which butler

echo "Checking application versions..."
echo "-----------------------------"
cat ~/.local/share/godot/templates/3.3.stable/version.txt
godot --version
butler -V
echo "-----------------------------"

mkdir build/
mkdir build/linux/
mkdir build/osx/
mkdir build/win/

echo "EXPORTING FOR LINUX"
echo "-----------------------------"
godot --export "Linux/X11" build/linux/missile-war.x86_64 -v
# echo "EXPORTING FOR OSX"
# echo "-----------------------------"
# godot --export "Mac OSX" build/osx/missile-war.dmg -v
echo "EXPORTING FOR WINDOZE"
echo "-----------------------------"
godot --export-debug "Windows Desktop" build/win/missile-war.exe -v
echo "-----------------------------"

# echo "CHANGING FILETYPE AND CHMOD EXECUTABLE FOR OSX"
# echo "-----------------------------"
# cd build/osx/
# mv missile-war.dmg missile-war-osx-alpha.zip
# unzip missile-war-osx-alpha.zip
# rm missile-war-osx-alpha.zip
# chmod +x missile-war.app/Contents/MacOS/missile-war
# zip -r missile-war-osx-alpha.zip missile-war.app
# rm -rf missile-war.app
# cd ../../

ls -al
ls -al build/
ls -al build/linux/
ls -al build/osx/
ls -al build/win/

echo "ZIPPING FOR WINDOZE"
echo "-----------------------------"
cd build/win/
zip -r missile-war-win-alpha.zip missile-war.exe missile-war.pck
rm -r missile-war.exe missile-war.pck
cd ../../

echo "ZIPPING FOR LINUX"
echo "-----------------------------"
cd build/linux/
zip -r missile-war-linux-alpha.zip missile-war.x86_64 missile-war.pck
rm -r missile-war.x86_64 missile-war.pck
cd ../../

echo "Logging in to Butler"
echo "-----------------------------"
butler login

echo "Pushing builds with Butler"
echo "-----------------------------"
butler push build/linux/ synsugarstudio/missile-war:linux-alpha
# butler push build/osx/ synsugarstudio/missile-war:osx-alpha
butler push build/win/ synsugarstudio/missile-war:win-alpha
