%% P3.6
% %Bilder laden
% Image1 = imread('sceneL.png');
% IGray1 = rgb_to_gray(Image1);
% 
% Image2 = imread('sceneR.png');
% IGray2 = rgb_to_gray(Image2);
% 
% % Harris-Merkmale berechnen
% features1 = harris_detector(IGray1,'segment_length',9, ...
%     'k',0.05,'min_dist',40,'N',50,'do_plot',false);
% features2 = harris_detector(IGray2,'segment_length',9, ...
%     'k',0.05,'min_dist',40,'N',50,'do_plot',false);
% 
% % Korrespondenzschaetzung
% correspondences = point_correspondence(IGray1,IGray2, ...
%     features1,features2,'window_length',25,'min_corr',0.9,'do_plot',false);
% 
% [correspondences_robust, largest_set_F] =  ...
%     F_ransac(correspondences, 'tolerance', 0.04);

%% P3.6
function [correspondences_robust, largest_set_F] = F_ransac(correspondences, varargin)
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

%% RANSAC algorithm preparation
% Pre-initialized variables:
% k                     number of necessary points
% s                     iteration number
% largest_set_size      size of the so far biggest consensus-set
% largest_set_dist      Sampson distance of the so far biggest consensus-set
% largest_set_F         fundamental matrix of the so far biggest consensus-set
k = 8;
s = ceil(log(1-p) ./ log(1 - (1-epsilon)^k));
largest_set_size = 0;
largest_set_dist = Inf;
largest_set_F = zeros(3,3);

%% RANSAC algorithm
biggestSet = [];
numFeatures = size(correspondences, 2);
for i = 1:s
    kIndex = randi([1, numFeatures], k, 1); % random k indices
    kCorrespondence = correspondences(:,kIndex); % k randomly chosen correspondence points
    F = epa(kCorrespondence); % fundamental matrix of current k points
    sd = sampson_dist(F, x1_pixel, x2_pixel);
    consensusSet = [];
    sumDistance = 0;
    for m = 1:size(sd, 2)
        if sd(m) < tolerance
            % include the pairs in current consensus set if sampson
            % distance is satisfied
            satisfiedPairs = [x1_pixel(1:2, m); x2_pixel(1:2, m)];
            consensusSet = [consensusSet satisfiedPairs];
            sumDistance = sumDistance + sd(m);  % update the sum of sampson distance
        end
    end
    numCorPair = size(consensusSet, 2);  % number of pairs in current consensus set
    
    % update the biggest set by choosing 1) the biggest number of pairs in
    % current set, 2) the smallest sampson distance
    if numCorPair > largest_set_size || ...
            (numCorPair == largest_set_size && sumDistance < largest_set_dist)
        biggestSet = consensusSet;
        largest_set_size = numCorPair;
        largest_set_dist = sumDistance;
        largest_set_F = F;
    end
end
% after all the iterations, obtain the final consensus set
correspondences_robust = biggestSet;

end