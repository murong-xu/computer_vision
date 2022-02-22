%% P1.4
img = imread('sceneL.png');
gray = rgb_to_gray(img);
[Ix, Iy, w, G11, G22, G12] = harris_detector(gray, 'segment_length', 9, 'k', 0.06);

figure();
subplot(1,2,1), imshow(Ix)
subplot(1,2,2), imshow(Iy)

figure();
subplot(1,3,1), imshow(G11)
subplot(1,3,2), imshow(G22)
subplot(1,3,3), imshow(G12)

%% P1.4
function [Ix, Iy, w, G11, G22, G12] = harris_detector(input_image, varargin)
% In this function you are going to implement a Harris detector that extracts features
% from the input_image.
%% Input parser from task 1.3
% segment_length    size of the image segment
% k                 weighting between corner- and edge-priority
% tau               threshold value for detection of a corner
% do_plot           image display variable
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
%% Preparation for feature extraction
% Check if it is a grayscale image
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

end