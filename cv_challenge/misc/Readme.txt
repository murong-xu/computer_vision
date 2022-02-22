Computer Vision Challenge 2020
Foreground and Background Detection of Videos
===========================
Last updated: 2020/07/12

##########Authors##########
group number: G06
group member: Yujia Gu, Qiyue Huang, Donghao Song, Murong Xu
mail: ge38cav@tum.de, qiyue.huang@tum.de, donghao.song@tum.de, murong.xu@tum.de


##########Main Function##########
By running this project, the foreground and background segmentation will be performed on a given video which consists of a sequence of RGB frames in JPEG format with arbitrary size. 

Four rendering modes are available: 
1. 'background':  preserve foreground of the original frame, set background to black.
2. 'foreground':  preserve background of the original frame, set foreground to black.
3. 'overlay'   :  the foreground of the original image will be marked in green with 50% transparency, and the background in red with 50% transparency.
4. 'substitute':  the background of the original frame is replaced by a virtual single RGB JPEG image or a video in MP4 format with arbitrary size, while the foreground remains.

The generated results will be stored in variable "movie" and also in an AVI file. The execution time will be displayed in command window.


##########Requirement##########
Install the Matlab Image Processing Toolbox. 
The code is tested on Matlab 2020a, with operating system Unix and Windows.


##########Usage Description##########
Usage 1: Run the scripts
1. Unzip the file.
2. Open the 'config.m' and 'challenge.m' in Matlab.
3. Run the 'config.m' with specifying the following input parameters:
   * src        : absolute or relative path of the video folder
   * L          : left camera number, 1 or 2
   * R          : right camera number, 2 or 3
   * start      : the starting frame to process the video, default = 0
   * N          : the number of succeeding frames at each time, default = 1. Please use N = 4 to obtain the best result!!
   * render_mode: rendering mode, select from 'foreground', 'background', 'overlay' and 'substitute'
   * bgMode     : if the render_mode is 'substitute', select 'image background' or 'video background' for the virtual background mode
   * bg         : if the render_mode is 'substitute', the file selection dialog box will be opened automatically for choosing a virtual background image/video
   * store      : true or false, choose whether to store the generated video in 'output.avi'
4. Run the 'challenge.m' and wait for the results. The generated frames will be saved in variable 'movie' in workspace, and also in the folder './results/Movie/'. If store=true, the video file 'output.avi' will be produced in current folder. And the execution time will be displayed in command window.
5. Enjoy and have fun! 

Usage 2: Use GUI
1. Unzip the file.
2. For Windows/Unix, type in addpath(fullfile('lib')); in the command window and execute.
3. Type in 'start_gui' in the command window or double click the file 'start_gui.mlapp' or open the file and click 'Run Tests' in the editor.
4. Click the "select" button of "Source" to enter folder selection UI and click the folder name that contains test data (eg.P2E_S5).
5. Click the "select" button of "SavePath" to enter folder selection UI and click a folder to store the results.
6. Click the downslide windows of L and R to select camera folders for left and right tensor.
7. Type in the value for "start" in the input box of "Start" to set a start frame.
8. Type in the value for "N" in the input box of "N" to set the number of a tensor. The best result is achieved when N=4!!
9. Click the downslide window of "RenderMode" to select the render mode.
10. Click the downslide window of "BgMode" to select the mode based on if it is an image or a video as the virtual background.
11. Click the "select" button of "BgPath" to enter folder selection UI and pick an image or a video as the virtual background according to the previous step.
12. Click render and wait. After rendering, 2 folders are generated. One folder contains original frames, the other contains rendering results.
13. Click "Save" to generate 2 videos that corresponding to aforementioned 2 image folders. 
14. Use "PLAY", "STOP" buttons as usual. Click "LOOP" button to play videos endless.
15. After press any button or select any fold, the GUI window will be hidden by other application windows. If the GUI window disappeared, do not be panic :). You only need to minimize other application windows.
16. Enjoy and have fun! 

##########Catalog##########

+--G06
 |   +--lib
 |      +--fastpcp.m
 |      +--svdsecon.m
 |      +--ResizeVideo.m
 |      +--SaveMovie.m
 |   +--misc
 |      +--doku-G06.pdf
 |      +--Readme.txt
 |   +--GUI
 |      +--start_gui.mlapp
 |   +--config.m
 |   +--challenge.m
 |   +--ImageReader.m
 |   +--segmentation.m
 |   +--render.m


##########API Description##########

--------------------
config.m
--------------------
(This program runs independently)

Function:
Initialize all necessary input parameters, settings and paths in the workspace. Construct the object of ImageReader 'ir'. If using the rendering mode 'substitution', also load the virtual background image/video.
   * src        : absolute or relative path of the video folder
   * L          : left camera number, 1 or 2
   * R          : right camera number, 2 or 3
   * start      : the starting frame to process the video, default = 0
   * N          : the number of succeeding frames at each time, default = 1. Please use N = 4 to obtain a better result!!!!
   * render_mode: rendering mode, select from 'foreground', 'background', 'overlay' and 'substitute'
   * bgMode     : if the render_mode is 'substitute', select 'image background' or 'video background' for the virtual background mode
   * bg         : if the render_mode is 'substitute', the file selection dialog box will be opened automatically for choosing a virtual background image/video
   * store      : true or false, choose whether to store the generated video in 'output.avi'

Note: 
For invalid input parameters, you can read the detail of the error message in command window.

Usage:
1. Specify the above mentioned parameters.
2. Type in 'config.m' in the command window or open the file 'config.m' and click 'Run' in editor.


--------------------
start_gui.mlapp
--------------------
(This program runs independently)

Function:
This program provides an alternative way to run the project with a GUI. Generated by Matlab App Designer. Detailed usage instruction see the above section. 


--------------------
challenge.m
--------------------
Precondition of running:
'config.m' should be already executed.

Function: 
This is the main program of the project. Based on the given parameters, it will perform segmentation on the video frames according to the rendering mode, then store the results in variable 'movie' in workspace, and also in the folder './results/Movie/'. If store=true, the video file 'output.avi' will be produced in current folder. And the execution time will be displayed in command window.

Usage:
1. Type in 'challenge' in the command window or open the file 'challenge.m' and click 'Run ' in the editor.


--------------------
ImageReader.m
--------------------
(It is used in config.m and challenge.m)

Form: 
	function ir = ImageReader(source, left, right, start, N)
Function:
It constructs a class 'ir' that delivers the information of the current-processing video, including the properties such as video file path, left/right camera, starting frame, number of succeeding frames, video length, video name, size of frame and etc. 

Form: 
        function [left, right, loop] = next(obj)
Function:
This function loads the corresponding frame pairs from left and right camera sequentially. When the current video is finished, it will set the 'loop' to 1, and the 'start' to 0 as indication for the main program 'challenge.m'.


--------------------
segmentation.m
--------------------
(It is used in challenge.m)

Form: 
	function [mask] = segmentation(left, right)

Function:
This function generates a binary mask for current frame by detecting (N+1) neighboring frames of left camera from a tensor. Convert to LAB color space and then perform RPCA. Separate the result of frame differencing into multiple sub-blocks after morphological transformations. Adaptive thresholds are implemented to handle different scenes. According to preliminary experiments, this function can achieve the best result when N = 4.


--------------------
render.m
--------------------
(It is used in challenge.m)

Form: 
	function [result] = render(frame, mask, bg, render_mode)

Function:
This function renders the mask for current frame according to the given rendering mode. Detailed information see the above section Main Function.

Note:
The virtual background image/video can have arbitrary size. For single image, it should be RGB in JPEG format. For video, it should have MP4 format.


--------------------
fastpcp.m
--------------------
(It is used in segmentation.m)

Form: 
	[L1, S1, statsPCP] = fastpcp(V, lambda, loops, rank0, rankThreshold, lambdaFactor)

Function:
This function performs the fast principal component pursuit via alternating minimization algorithm. For our case, the input 'V' is a data matrix of size [number_frame, number_pixel] which stacks each reshaped 1D original frame in row-wise order. We choose the normalization factor lambda = 1/sqrt(max(size(V))) as it depends on the input matrix dimension.


--------------------
svdsecon.m
--------------------
(It is used in fastpcp.m)

Form: 
	[U, S, V] = svdsecon(X, k)
Function:
This function performs faster singular value decomposition to accelerate the processing speed of 'fastpcp.m'.


--------------------
ResizeVideo.m
--------------------
(It is used in config.m)

Form: 
	[] = ResizeVideo(VideoPath, SavePath, BgSize)
Function:
This function converts each frame of the original video from 'VideoPath' to the specified size, and saves the resized frames to the 'SavePath'. It is used for adjusting the virtual background with arbitrary size.


--------------------
SaveMovie.m
--------------------
(It is used in start_gui.mlapp)

Form: 
	[] = SaveMovie(targetFolderMovie, dest, store)
Function:
This function writes the generated movie as AVI video to disk



##########Basic Description of Algorithms##########

The main strategy is to use Robust Principal Component Analysis and decompose the LAB-based input frame to low-rank and sparse matrices. Then, applying frame differencing to ensure the completeness of object contour. And lastly, combining morphological transformations and the method of “Block-wise ROI” to extract the foreground object precisely. 

One of the highlight of our work is that we use the adaptive parameters to process the images, namely analyzing each frame individually and then performing the segmentation. In this way, the detected results will be more robust against scene variance. 
