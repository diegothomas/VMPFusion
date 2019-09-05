# VMPFusion
This is the source code of VMPFusion that corresponds to the paper published at 3DV2019

This code is only for academic research and non-commercial use. If you use part of this code for your research, please cite the following paper:

Diego Thomas, Akihiro Sugimoto, Ekaterina Sirazitdinova, Rin-ichiro Taniguchi Kyushu.
Revisiting Depth Image Fusion with Variational Message Passing.
International Conference on 3D Vision (3DV 2019), 2019.09


INSTALL Instructions

Prerequis:
(1) Mac OS Mojave+

(2) XCode

(A) Download the repository

(B) Open ToolKit.xcodeproj with XCode

(C) Add a new scheme: ToolKit>MyMAc

(D) Import the RGBDLib.framework into the project's Frameworks group (drag and drop)

(E) In the target's General tab, add RGBDLib.framework in the Embedded Binaries field

(F) Build and Run


RUNNING instructions
Go to File -> Open stream -> Offline 

Search for the directory that contain the data (example one data from TUM dataset)

TUM dataset: http://vision.in.tum.de/data/datasets/rgbd-dataset

Click choose

Then go to Tools -> Static reconstruction -> KFMap

Then click the Start button


