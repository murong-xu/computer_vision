%% P1.7
img = imread('sceneL.png');
gray = rgb_to_gray(img);
[min_dist, tile_size, N] = harris_detector(gray, 'min_dist', 10, 'N', 30, 'tile_size', [100, 200]);

%% P1.7
function [min_dist, tile_size, N] = harris_detector(input_image, varargin)
% In this function you are going to implement a Harris detector that extracts features
% from the input_image.
%% Input parser
defaultSegment_length = 15;
defaultK = 0.05;
defaultTau = 10^6;
defaultDo_plot = false;
defaultMin_dist = 20;
defaultTile_size = 200;
defaultN = 5;

p = inputParser;
addRequired(p, 'input_image', @(x) numel(size(x))==2);
addParameter(p, 'segment_length', defaultSegment_length, ...
    @(x) isnumeric(x) && (mod(x,2)==1) && (x>1));
addParameter(p, 'k', defaultK, @(x) isnumeric(x) && (x>=0) && (x<=1));
addParameter(p, 'tau', defaultTau, @(x) isnumeric(x) && (x>0));
addParameter(p, 'do_plot', defaultDo_plot, @(x) islogical(x));
addParameter(p, 'min_dist', defaultMin_dist, @(x) isnumeric(x) && (x >= 1));
addParameter(p, 'tile_size', defaultTile_size, @(x) isnumeric(x));
addParameter(p, 'N', defaultN, @(x) isnumeric(x) && (x >= 1));

parse(p, input_image, varargin{:});

segment_length = p.Results.segment_length;
k = p.Results.k;
tau = p.Results.tau;
do_plot = p.Results.do_plot;
min_dist = p.Results.min_dist;
N = p.Results.N;

if size(p.Results.tile_size, 2) == 1
    tile_size = [p.Results.tile_size, p.Results.tile_size];
else
    tile_size = p.Results.tile_size;
end
end