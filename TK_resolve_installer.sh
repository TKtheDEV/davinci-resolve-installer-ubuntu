#!/bin/bash
cd ~/Downloads
unzip DaVinci_Resolve_19.1_Linux.zip
sudo apt install libapr1t64 libaprutil1t64 libxcb-composite0 libxcb-xinerama0
sudo SKIP_PACKAGE_CHECK=1 ~/Downloads/DaVinci_Resolve_19.1_Linux/DaVinci_Resolve_19.1_Linux.run -i
sudo cp /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0 /opt/resolve/libs/
sudo cp /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0 /opt/resolve/libs/
sudo cp /usr/lib/x86_64-linux-gnu/libglib-2.0.so.0 /opt/resolve/libs/
echo All done, you can open resolve now. Have Fun! ~TKtheDEV