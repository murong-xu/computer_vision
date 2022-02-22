%% P2.1
% Load Images
Image1 = imread('sceneL.png');
IGray1 = rgb_to_gray(Image1);

Image2 = imread('sceneR.png');
IGray2 = rgb_to_gray(Image2);

% Calculate Harris features
features1 = harris_detector(IGray1,'segment_length',9,'k',0.05,...
    'min_dist',50,'N',20,'do_plot',false);
features2 = harris_detector(IGray2,'segment_length',9,'k',0.05,...
    'min_dist',50,'N',20,'do_plot',false);

[window_length, min_corr, do_plot, Im1, Im2] = ...
    point_correspondence(IGray1,IGray2,features1,features2,...
    'window_length',25,'min_corr', 0.90,'do_plot',true);

%% P2.1
function [window_length, min_corr, do_plot, Im1, Im2] = point_correspondence(I1, I2, Ftp1, Ftp2, varargin)
% In this function you are going to compare the extracted features of a stereo recording
% with NCC to determine corresponding image points.

%% Input parser
defaultWindow_length = 25;
defaultMin_corr = 0.95;
defaultDo_plot = false;

p = inputParser;
addParameter(p, 'window_length', defaultWindow_length, ...
    @(x) isnumeric(x) && (mod(x,2)==1) && (x>1));
addParameter(p, 'min_corr', defaultMin_corr, @(x) isnumeric(x) && (x>0) && (x<1));
addParameter(p, 'do_plot', defaultDo_plot, @(x) islogical(x));

parse(p, varargin{:});

window_length = p.Results.window_length;
do_plot = p.Results.do_plot;
min_corr = p.Results.min_corr;
Im1 = double(I1);  % input image save as double
Im2 = double(I2);
end