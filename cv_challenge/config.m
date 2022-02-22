%% Computer Vision Challenge 2020 settings.m
clc;
clear;
addpath(fullfile('lib'));
%% Generall Settings
% Group number:
group_number = 6;

% Group members:
members = {'Yujia Gu', 'Qiyue Huang', 'Donghao Song', 'Murong Xu'};

% Email-Address (from Moodle!):
mail = {'ge38cav@tum.de', 'qiyue.huang@tum.de', 'donghao.song@tum.de', ...
    'murong.xu@tum.de'};

%% Setup Image Reader
% Specify Scene Folder
src = './P1E_S1';

% Select Cameras
L = 1;
R = 2;

% Choose a start point
start = 220;  % default is 0

% Choose the number of succseeding frames
N = 4;  % default is 1

ir = ImageReader(src, L, R, start, N);

%% Output Settings
% Output Path
dest = "output.avi";

% Select rendering mode: 'video background' or 'image background'
bgMode = 'image background';
BgSize = [ir.height,ir.width];

% Select rendering mode
render_mode = "overlay";

% Load Virual Background in bg
bg = {};
if strcmp(render_mode,'substitute')
    switch bgMode
        case 'image background'  % use still-image background (RGB)
            % select the path of background
            [file, src_bg] = uigetfile('*.jpg', 'Select an Background Image');
            BgPath = [src_bg, file];
            bg{1} = imresize(double(imread(BgPath)),BgSize);
            
        case 'video background'  % use sequantial background (video)
            [file, src_bg] = uigetfile('*.mp4','*.avi','Select an Background Video');
            VideoPath = [src_bg, file];
            FramePath = [src_bg,'Video_Frame'];
            if ~exist(FramePath, 'dir')
                mkdir(FramePath);
            end
            
            ResizeVideo(VideoPath,FramePath,BgSize);
            %         VideoPath = uigetdir('*.jpg', 'Select a Background Folder');
            VideoDir = dir([FramePath, '*.jpg']);
            bg = cell(length(VideoDir), 1);
            for i = 1:length(VideoDir)
                bg{i} = double(imread(strcat(FramePath, VideoDir(i).name)));
            end
    end
end

% Create a movie array
movie = cell([],1);

% Store Output?
store = true;

