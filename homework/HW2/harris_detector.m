% %% P1.11
% img = imread('sceneL.png');
% gray = rgb_to_gray(img);
% features = harris_detector(gray, 'segment_length', 9, 'k', 0.06, 'do_plot', true);

%% P1.11
function features = harris_detector(input_image, varargin)
% In this function you are going to implement a Harris detector that extracts features
% from the input_image.

%% Input parser from task 1.7
% segment_length    size of the image segment
% k                 weighting between corner- and edge-priority
% tau               threshold value for detection of a corner
% do_plot           image display variable
% min_dist          minimal distance of two features in pixels
% tile_size         size of the tiles
% N                 maximal number of features per tile
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

%% Preparation for feature extraction from task 1.4
% Ix, Iy            image gradient in x- and y-direction
% w                 weighting vector
% G11, G12, G22     entries of the Harris matrix
[~, ~, numChannel] = size(input_image);
if numChannel > 1
    error('Image format has to be NxMx1');
else
    input_image=double(input_image);
end
% Approximation of the image gradient
[Ix, Iy] = sobel_xy(input_image);
% Weighting
sz = segment_length;
x = linspace(-(sz-1)/2, (sz-1)/2, sz);
sigma = sz/5; % adequate relationship between sample_number w and deviation
w = exp(-x.^2 ./ (2*sigma^2)); % 1D symm weighting vector
w = w / sum(w); % normalization
W = w'*w; % 2D separable weighting filter
% Harris Matrix G
G11 = conv2(Ix.*Ix, W, 'same');
G12 = conv2(Ix.*Iy, W, 'same');
G22 = conv2(Iy.*Iy, W, 'same');

%% Feature extraction with the Harris measurement from task 1.5
% corners           matrix containing the value of the Harris measurement for each pixel
H = (G11.*G22 - G12.^2) - k.*(G11 + G22).^2;
borderDistance = (segment_length-1)/2;
borderMask = zeros(size(H));
borderMask(borderDistance+1:end-borderDistance, ...
    borderDistance+1:end-borderDistance) = 1; % not consider corner response on border
corners = H .* borderMask;
corners(corners<tau) = 0; % eliminate features which smaller than tau

%% Feature preparation from task 1.9
% sorted_index      sorted indices of features in decreasing order of feature strength
minDistMask = zeros(size(corners, 1)+2*min_dist, size(corners, 2)+2*min_dist);
% fill with previous corners elements in the middle
minDistMask(min_dist+1:end-min_dist, min_dist+1:end-min_dist) = corners;
corners = minDistMask;

[~, sorted_index] = sort(corners(:), 'descend');
numNonzero = sum(corners(:)~=0); % number of nonzeros in matrix corners
sorted_index = sorted_index(1:numNonzero);

%% Accumulator array from task 1.10
% acc_array         accumulator array which counts the features per tile
% features          empty array for storing the final features
numTailY = ceil(size(input_image, 1) / tile_size(1)); % number of tails in vertical direction
numTailX = ceil(size(input_image, 2) / tile_size(2)); % number of tails in horizontal direction
acc_array = zeros(numTailY, numTailX);

% choose the minimal threshold between preprocessed features & predefined max
% values
numFeatures = min(N*numTailY*numTailX, size(sorted_index, 1));
features = zeros(2, numFeatures);

%% Feature detection with minimal distance and maximal number of features per tile
numTotalFeatures = length(sorted_index); % number of preprocessed nonzero features
cornersSizeY = size(corners, 1);
cornersSizeX = size(corners, 2);
allFeatures = zeros(2, numTotalFeatures);
for i = 1:numTotalFeatures
    featureIndex = sorted_index(i);
    % as the exceeding Harris measurements within a tile will be later cleared,
    % here can simply skip those zero values
    if corners(featureIndex) == 0
        allFeatures(:, i) = [NaN; NaN]; % use NaN to represent invalid features
    else
        locationY = mod(featureIndex, cornersSizeY); % vertical pixel location (corners)
        if locationY == 0
            locationY = cornersSizeY;
        end
        locationX = floor((featureIndex-1) / cornersSizeY) + 1; % horizontal pixel location (corners)
        locationTailY = floor((locationY-min_dist-1)/(tile_size(1))) + 1;  % vertical current tile number
        locationTailX = floor((locationX-min_dist-1)/(tile_size(2))) + 1;  % horizontal current tile number
        % update the acc_array and use the cake function to elminate the neighboring
        % features around the current strong feature point
        acc_array(locationTailY, locationTailX) = acc_array(locationTailY, locationTailX) + 1;        
        corners(locationY-min_dist:locationY+min_dist, locationX-min_dist:locationX+min_dist) = ...
            corners(locationY-min_dist:locationY+min_dist, locationX-min_dist:locationX+min_dist) .* cake(min_dist);
        if acc_array(locationTailY, locationTailX) == N
            % clear all of the Harris measurements within the current tile,
            % update the last vaild feature point in the tile
            rangeTailY = (locationTailY-1)*tile_size(1)+min_dist+1 : min(locationTailY*tile_size(1)+min_dist, cornersSizeY);
            rangeTailX = (locationTailX-1)*tile_size(2)+min_dist+1 : min(locationTailX*tile_size(2)+min_dist, cornersSizeX);
            corners(rangeTailY, rangeTailX) = 0;
            allFeatures(:, i) = [locationX - min_dist; locationY - min_dist];
        else
            % if the max feature numbers within a tail is fullfilled, just
            % update the feature point
            allFeatures(:, i) = [locationX - min_dist; locationY - min_dist];
        end
    end
end
indexNonNaN = ~isnan(allFeatures(1, :));
features = allFeatures(:, indexNonNaN); % remove all of the invalid features

%% Plot Routine
if do_plot
    imshow(input_image/255);
    hold on;
    plot(features(1,:), features(2,:), 'ro');
end
end