# Kitti 3D Object Proposal Evaluation
This is a heavily modified version of the code published by 3DOP: http://www.cs.toronto.edu/objprop3d/.

The following plots are evaluated for both 3D and 2D cases:
1. Recall vs # of Proposals curve at a certain IOU threshold.
2. Recall vs IOU curve at a certain number of proposals.
3. Recall vs distance curve at a certain IOU and Number of proposals.  

## Usage
Implemented and tested with Matlab 2017b on Ubuntu 16.04

1. configs.m contains configurations for the three evaluation metrics allowing to change IOU thresholds, number of proposals, or both.
2. Evaluation_Kitti.m is the main script. Usage instructions can be found as comments.

## Folder Structure:
``` bash
cd ~/kitti_proposal_eval/proposals

find . -maxdepth 10 -name  "*" -type f -delete
```

This will clear all .gitkeep files from the folder structure example.
Copy and rename the folder structure with the name of your method. The name 
of the method will be used inside Evaluation_Kitti.m.

Add the proposals in KITTI format to:

```
~/kitti_proposal_eval/proposals/method_name_here/kitti_format/class_name_here
```

Current supported classes are car and people (joint). 
