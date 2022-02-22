%% P3.3
% Bilder laden
Image1 = imread('sceneL.png');
IGray1 = rgb_to_gray(Image1);

Image2 = imread('sceneR.png');
IGray2 = rgb_to_gray(Image2);

% Harris-Merkmale berechnen
features1 = harris_detector(IGray1,'segment_length',9, ...
    'k',0.05,'min_dist',40,'N',50,'do_plot',false);
features2 = harris_detector(IGray2,'segment_length',9, ...
    'k',0.05,'min_dist',40,'N',50,'do_plot',false);

% Korrespondenzschaetzung
correspondences = point_correspondence(IGray1,IGray2,features1,...
    features2,'window_length',25,'min_corr',0.9,'do_plot',false);

[epsilon, p, tolerance, x1_pixel, x2_pixel] = F_ransac(correspondences);

%% P3.3
function [epsilon, p, tolerance, x1_pixel, x2_pixel] = F_ransac(correspondences, varargin)
% This function implements the RANSAC algorithm to determine
% robust corresponding image points

%% Input parser
% Known variables:
% epsilon       estimated probability
% p             desired probability
% tolerance     tolerance to belong to the consensus-set
% x1_pixel      homogeneous pixel coordinates
% x2_pixel      homogeneous pixel coordinates
defaultEpsilon = 0.5;
defaultP = 0.5;
defaultTolerance = 0.01;

parser = inputParser;
addParameter(parser, 'epsilon', defaultEpsilon, @(x) isnumeric(x) && (x > 0) && (x < 1));
addParameter(parser, 'probability',defaultP, @(x) isnumeric(x) && (x > 0) && (x < 1));
addParameter(parser, 'tolerance', defaultTolerance, @(x) isnumeric(x));

parse(parser, varargin{:});

numFeatures = size(correspondences, 2);
onesArray = ones(1, numFeatures);
x1_pixel = correspondences(1:2, :);
x1_pixel = [x1_pixel; onesArray];  % homo coordinates
x2_pixel = correspondences(3:4, :);
x2_pixel = [x2_pixel; onesArray];

epsilon = parser.Results.epsilon;
p = parser.Results.probability;
tolerance = parser.Results.tolerance;

end