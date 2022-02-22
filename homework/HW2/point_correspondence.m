function cor = point_correspondence(I1, I2, Ftp1, Ftp2, varargin)
% In this function you are going to compare the extracted features of a stereo recording
% with NCC to determine corresponding image points.

%% Input parser from task 2.1
% window_length         side length of quadratic window
% min_corr              threshold for the correlation of two features
% do_plot               image display variable
% Im1, Im2              input images (double)
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

%% Feature preparation from task 2.2
% no_pts1, no_pts 2     number of features remaining in each image
% Ftp1, Ftp2            preprocessed features
sz = {};
sz{1} = size(Im1);
sz{2} = size(Im2);
originalFeature = {};
originalFeature{1} = Ftp1;
originalFeature{2} = Ftp2;
windowLength_half = (window_length-1)/2;

reducedFeature = {};
for i=1:2
    features_max = originalFeature{i} + windowLength_half;  % exceed the right bottom borders
    [row, col] = find(features_max(1,:)>sz{i}(2) | features_max(2,:)>sz{i}(1));
    features_max(:, col) = NaN;
    indexNonNaN = ~isnan(features_max(1, :));
    features = originalFeature{i}(:, indexNonNaN); % remove all of the invalid features
    
    features_min = features - windowLength_half;  % exceed the left top borders
    [row, col] = find(features_min(1,:)<1 | features_min(2,:)<1);
    features_min(:, col) = NaN;
    indexNonNaN = ~isnan(features_min(1, :));
    features = features(:, indexNonNaN); % remove all of the invalid features
    
    reducedFeature{i} = features;
end
Ftp1 = reducedFeature{1};
Ftp2 = reducedFeature{2};
no_pts1 = length(Ftp1);
no_pts2 = length(Ftp2);

%% Normalization from task 2.3
% Mat_feat_1            normalized windows in image 1
% Mat_feat_2            normalized windows in image 2
reducedFeature = {};  % after feature preparation (eliminate border features)
reducedFeature{1} = Ftp1;
reducedFeature{2} = Ftp2;
image = {};  % original images
image{1} = Im1;
image{2} = Im2;
windowLength_half = (window_length-1)/2;
numElementWindow = window_length.^2;  % number of pixels within a window

matFeat = {};
for i=1:2  % two reduced feature arrays
    numReducedFeature = length(reducedFeature{i});
    matFeat{i} = zeros(window_length.^2, numReducedFeature);  % initialization
    for k=1:numReducedFeature
        row = reducedFeature{i}(2,k);
        col = reducedFeature{i}(1,k);
        window = image{i}(row-windowLength_half:row+windowLength_half,...
            col-windowLength_half:col+windowLength_half);
        % mean matrix of window
        window_meanMatrix = ones(window_length) * window * ones(window_length)...
            ./(numElementWindow);
        m = window-window_meanMatrix;
        std = sqrt(sum(m.* m, 'all') ./ (numElementWindow-1));
        matrixFeature = m ./ std;
        matFeat{i}(:, k) = matrixFeature(:);
    end
end
Mat_feat_1 = matFeat{1};
Mat_feat_2 = matFeat{2};

%% NCC from task 2.4
% NCC_matrix            matrix containing the correlation between the image points
% sorted_index          sorted indices of NCC_matrix entries in decreasing order of intensity
numFeature_Img1 = size(Mat_feat_1, 2);
numFeature_Img2 = size(Mat_feat_2, 2);
NCC_matrix = zeros(numFeature_Img2, numFeature_Img1);
for q=1:numFeature_Img1
    for p=1:numFeature_Img2
        NCC_matrix(p, q) = trace(sum(Mat_feat_1(:,q) .* Mat_feat_2(:,p)))...
            ./(window_length.^2-1);
    end
end
NCC_matrix(NCC_matrix<min_corr) = 0;
[~, sorted_index] = sort(NCC_matrix(:), 'descend');
numNonzero = sum(NCC_matrix(:)~=0); % number of nonzeros in NCC matrix
sorted_index = sorted_index(1:numNonzero);

%% Correspondeces from task 2.5
% cor                   matrix containing all corresponding image points
numFeature_Img1 = size(Mat_feat_1, 2);
numFeature_Img2 = size(Mat_feat_2, 2);
numTotalCor = length(sorted_index);  % number of qualified correspondences
cor = zeros(4, numTotalCor);
for i=1:numTotalCor
    corIndex = sorted_index(i);
    [row, col] = ind2sub([numFeature_Img2, numFeature_Img1], corIndex);
    if NCC_matrix(row, col) ~= 0
        % make sure no feature in img 1 is mapped to more than one feature in img 2
        NCC_matrix(:, col) = 0;
        cor(1:2, i) = Ftp1(:, col);
        cor(3:4, i) = Ftp2(:, row);
    end
end
numNonzeroCor = find(cor(1,:)~=0); % number of nonzeros in NCC matrix
cor = cor(:, numNonzeroCor);

%% Visualize the correspoinding image point pairs
if do_plot == true
    imshow(Im1/255);
    hold on
    imshow(Im2/255);
    hold on
    alpha(0.5);  % add transparancy of 50%
    for i=1:size(cor,2)
        plot(cor(1,:), cor(2,:), 'r*', 'MarkerSize', 6, 'LineWidth',1);
        plot(cor(3,:), cor(4,:), 'b*', 'MarkerSize', 6, 'LineWidth',1);
        plot([cor(1,i),cor(3,i)],[cor(2,i),cor(4,i)], 'g-', 'LineWidth',1);
        hold on
    end
end

end