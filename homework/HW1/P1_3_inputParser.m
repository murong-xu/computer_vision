%% P1.3
img = imread('sceneL.png');
gray = rgb_to_gray(img);
[segment_length, k, tau, do_plot] = harris_detector(gray, 'segment_length', 9, 'k', 0.06);

%% P1.3
function [segment_length, k, tau, do_plot] = harris_detector(input_image, varargin)
% In this function you are going to implement a Harris detector that extracts features
% from the input_image.
%% Input parser
% segment_length: controls the size of image segment, odd, >1
% k: weights between corner- and edge-priority, [0,1]
% tau: threshold valuf for detection of a corner, >0
% do_plot: whether the image is displayed or not, [true, false]

% Set default input values
defaultSegment_length = 15;
defaultK = 0.05;
defaultTau = 10^6;
defaultDo_plot = false;

p = inputParser;
addRequired(p, 'input_image', @(x) numel(size(x))==2);
addParameter(p, 'segment_length', defaultSegment_length, ...
    @(x) isnumeric(x) && (mod(x,2)==1) && (x>1));
addParameter(p, 'k', defaultK, @(x) isnumeric(x) && (x>=0) && (x<=1));
addParameter(p, 'tau', defaultTau, @(x) isnumeric(x) && (x>0));
addParameter(p, 'do_plot', defaultDo_plot, @(x) islogical(x));

parse(p, input_image, varargin{:});

segment_length = p.Results.segment_length;
k = p.Results.k;
tau = p.Results.tau;
do_plot = p.Results.do_plot;
end