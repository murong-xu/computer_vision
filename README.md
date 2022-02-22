# computer_vision
TUM EI Master Course "Computer Vision" in SS20. 

This repository contains solutions of the homework and the final project "CV challenge". Please find them in the corresponding directories. 

## Homework

It includes the content of:
* Harris feature detector
* Sobel filter
* Image point correspondences
* Eight-point algorithm
* RanSaC 
* Reconstruction of the 3D-coordinates
* Back projection

## CV challenge

### Foreground and Background Detection of Videos
In these years, video-call has become a more crucial part of social use such as business, education, and communication 
among family and friends. It provides lots of flexibility for remote working while maintaining relatively high quality
to simulate the real physical meetings. To protect individual privacy, many video conferencing software allow users to 
change their background during the call. So in this year's computer vision challenge, our task is to perform segmentation
of foreground and background from a given video sequence.

The main strategy of our work is to use Robust Principal Component Analysis and decompose the LAB-based input frame to 
low-rank and sparse matrices. Then, applying frame differencing to ensure the completeness of object contour. And lastly, 
combining morphological transformations and the method of "Block-wise ROI" to extract the foreground object precisely. 
One of the highlights of our work is that we use the adaptive parameters to process the images, namely analyzing each
frame individually and then performing the segmentation. In this way, the detected results will be more robust against 
scene variance.

#### Some segmented results from the video
<img src="https://github.com/murong-xu/computer_vision/blob/main/figure/result_single_person.png" alt="drawing" width="800"/>
<img src="https://github.com/murong-xu/computer_vision/blob/main/figure/result_crowd.png" alt="drawing" width="700"/>

#### Methods
<img src="https://github.com/murong-xu/computer_vision/blob/main/figure/flowchart_0.png" alt="drawing" width="500"/>
<img src="https://github.com/murong-xu/computer_vision/blob/main/figure/flowchart_1.png" alt="drawing" width="600"/>
