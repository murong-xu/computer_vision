function [] = ResizeVideo(VideoPath,SavePath,BgSize)
% The function converts each frame of the original video from 'VideoPath' to the specified size,
% and saves the resized frames to the 'SavePath'.

% VideoPath : char variable. Path for the original background video, e.g. './bgVideo.mp4'
% SavePath  : char variable. Path to save the resized frames, e.g. './BgVideo'
% BgSize    : 2x1 arrary. The taeget size of the frames after Resize, e.g.[600,800,3]


if ~exist(SavePath, 'dir')
    mkdir(SavePath);
end

obj = VideoReader(VideoPath);
frame = read(obj,1);
height = size(frame,1);
width = size(frame,2);
numFrames = obj.NumFrames;
for k = 1 : numFrames
    frame = read(obj,k);
    if [height,width] == BgSize
        ResizeFrame = frame;
    else
        ResizeFrame = imresize(frame,BgSize);
    end
    path = [SavePath,filesep,strcat('bg_',num2str(k-1,'%08d'),'.jpg')];
    imwrite(ResizeFrame,path,'jpg');
end

end