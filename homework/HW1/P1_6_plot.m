%% P1.6
img = imread('sceneL.png');
gray = rgb_to_gray(img);
features = harris_detector(gray, 'segment_length', 9, 'k', 0.06, 'do_plot', true);

%% P1.6
function features = harris_detector(input_image, varargin)
% In this function you are going to implement a Harris detector that extracts features
% from the input_image.
%% Input parser from task 1.3
% segment_length    size of the image segment
% k                 weighting between corner- and edge-priority
% tau               threshold value for detection of a corner
% do_plot           image display variable
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
% features          detected features
% corners           matrix containing the value of the Harris measurement for each pixel
H = (G11.*G22 - G12.^2) - k.*(G11 + G22).^2;
borderDistance = (segment_length-1)/2;
borderMask = zeros(size(H));
borderMask(borderDistance+1:end-borderDistance, ...
    borderDistance+1:end-borderDistance) = 1; % not consider corner response on border
corners = H .* borderMask;
corners(corners<tau) = 0; % eliminate features which smaller than tau
[rows, cols] = find(corners);
features = [cols, rows]';
%% Plot
if p.Results.do_plot
    imshow(input_image/255);
    hold on;
    plot(features(1,:), features(2,:), 'ro');
end
end