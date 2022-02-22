function [mask] = segmentation(left, right)
% SEGMENTATION  generate binary mask for current frame by detecting
% (N+1) neighboring frames from a tensor. Convert to LAB color space and
% then perform RPCA. Separate the result of fram differencing into multiple
% subblocks after morphology processing. Adaptive threshold are implemented
% to handle different scenes.

% Input: left --> left tensor with the size [height,width,3*(N+1)]
%        right  --> right tensor with the size [height,width,3*(N+1)]
% Output: mask --> a binary mask with the size of [height,width]. Pixels
%         that belong to foreground object are set to 1, otherwise 0.

%% Initilization
global adaptiveThreshold;
global count;
numFrame = size(left, 3)./3;  % num of frames in a tensor
height = size(left, 1);
width = size(left, 2); % size of input image
totalPixel = height * width;
matrix = zeros(numFrame, height*width);  % input of RPCA

%% Load tensor and do preprocessing
for i = 1:numFrame
    % we only need the left camera frames
    frame = left(:, :, 3*(i-1)+1:3*i)./255;
    % median filter preprocessing: remove salt&pepper noise, preserve
    % edge features
    frame = cat(3,medfilt2(frame(:,:,1)),medfilt2(frame(:,:,2)),medfilt2(frame(:,:,3)));
    % RGB to LAB color space
    frame = rgb2lab(frame);
    % only need the L component, reshape it to a 1D row vector
    matrix(i,:) = reshape(frame(:,:,1), [], 1);  % col-wise
end

%% Perform RPCA on L component
lambda = 1/sqrt(max(size(matrix)));  % lambda depends on input matrix dimension
% do RPCA decomposition over (numFrame) images
[L, ~, ~] = fastpcp(matrix, lambda);

%% Generate binary masks
% loop for all frames in the tensor
% first: make sure the foreground object exists

currentFrameNr = ceil(numFrame./2);
frame1 = reshape(matrix(currentFrameNr,:), 600,800);
frame2 = reshape(matrix(currentFrameNr+1,:), 600,800);
bg1 = reshape(L(currentFrameNr,:), 600,800);  % background of frame1
bg2 = reshape(L(currentFrameNr+1,:), 600,800);  % background of frame2
fg1 = imabsdiff(frame1, bg2);  % difference image method
fg2 = imabsdiff(bg2, frame2);
bgDiff = imabsdiff(bg1, bg2);


% first: make sure the foreground object exists
if max(bgDiff(:))<0.009  % if no significant changes
    mask = logical(zeros(height, width));  % set to entire background
else
    % compute with adaptive threshold for foreground
    numBin = 1000;
    rangeBin = linspace(min(fg1(:)), max(fg1(:)), numBin);
    diffHist = hist(fg1(:), rangeBin);
    diffCDF = cumsum(diffHist)./totalPixel;
    % assume 15% pixels belonging to movements
    indexThreshold = find(diffCDF>adaptiveThreshold, 1);
    threshold = rangeBin(indexThreshold);
    
    % convert background to binary representation
    fg1(fg1<=threshold) = 0;
    fg1(fg1>threshold) = 1;
    fg2(fg2<=threshold) = 0;
    fg2(fg2>threshold) = 1;
    
    % compute initial result: intersection of two adjacent foregrounds
    result = fg1 .* fg2;
    % morpholfirsogy processing of foreground object
    se1 = strel('disk', 40);
    se2 = strel('disk', 5);
    % step 1: use Gaussian filter to remove salt&pepper noise
    basic = medfilt2(result);
    % step 2: further exclude the scattering outliers
    basic1 = filloutliers(basic, 'nearest', 'mean');
    % step 3: largely extend the contour line
    afterDilate = imdilate(basic1, se1);
    % step 4: flood fill the interior holes
    afterFill = imfill(afterDilate, 'holes');
    % step 5: remove the enlarged contour
    afterErosion = imerode(afterFill, se1);
    % step 6: for foreground object which has intersection with the image
    % border, only using step 4 can not fill all the holes (because the
    % pixels on border line are zeros). So it is necessary to complete a
    % close contour line.
    numWhite = 20;
    if sum(afterErosion(:,1)) > numWhite  % determine if there is an intersection
        afterErosion(:,1) = 1;
    end
    if sum(afterErosion(:,end)) > numWhite
        afterErosion(:,end) = 1;
    end
    if sum(afterErosion(1,:)) > numWhite
        afterErosion(1,:) = 1;
    end
    if sum(afterErosion(end,:)) > numWhite
        afterErosion(end,:) = 1;
    end
    % step 7: slightly enlarge the contour again
    afterDilateAgain = imdilate(afterErosion, se2);
    % step 8: flood fill the possible remaining holes
    afterFillAgain = imfill(afterDilateAgain, 'holes');
    % step 9: remove the remaining noise
    firstMask = medfilt2(imerode(afterFillAgain, se2));
    
    %get the mask to calculate white pixels
    foreground = logical(firstMask);
    foreground = bwareaopen(foreground,30);
    zeroZone = zeros(ceil(height/8),width);
    foreground(1:ceil(height/8),:) = zeroZone;
    %mask preprocessing
    result1 = filloutliers(single(basic), 'nearest', 'mean');
    result1 = bwareaopen(result1, 30);
    foreground1 = bwareafilt(logical(result1),15);
    
    %separate foreground mask into multiple subblocks.
    blockWidth = 2;
    numMaskBlock = width/blockWidth;
    sz = [height,width/numMaskBlock];
    ROI = zeros(height,width);
    
    for ii=1:numMaskBlock
        % calculation for each subblock
        ROIBlock = zeros(600,blockWidth);
        foregroundBlock = foreground1(:,ii*blockWidth-blockWidth+1:ii*blockWidth);
        index = find(foregroundBlock==1);
        
        if length(index)>2
            % locate the largest rectangle in the subblock
            [row,col] = ind2sub(sz,index);
            leftMost  = min(col);
            rightMost = max(col);
            upMost = min(row);
            downMost = max(row);
            height_j = downMost-upMost+1;
            width_J = rightMost-leftMost+1;
            % find the largest rectangle area
            ROIBlock(upMost:downMost,leftMost:rightMost) = ones(height_j,width_J);
        elseif length(index)<=2
            %if the number of pixels in one subblock is less than 2
            %we consider it as noise
            ROIBlock = zeros(600,blockWidth);
        end
        %forms the complete ROI
        ROI(:,ii*blockWidth-blockWidth+1:ii*blockWidth) = ROIBlock;
        ROI = logical(ROI);
        
    end
    
    %morphology processing for ROI
    se1 = strel('disk',20);
    afterFilt = medfilt2(ROI);
    afterDilate = imdilate(afterFilt,se1);
    afterFillout = filloutliers(single(afterDilate), 'nearest', 'mean');
    afterFill = imfill(afterFillout,'holes');
    afterErosion = imerode(afterFill, se1);
    afterErosion(1:ceil(height/8),:) = zeroZone;
    %determine if the selected image includes more than 2 people
    %if yes, change adaptiveThreshold to 0.6
    %if not, change adaptiveThreshold to 0.85
    index2 = find(foreground==1);
    temp = adaptiveThreshold;
    count = count + 1;
    totalArea = 0;
    if length(index2) ~= 0
        
        totalArea = length(index2);
        
        if totalArea >= 0.3*height*width
            %if the number of people in one frame is more than 2
            %change the adaptiveThreshold to 0.6
            adaptiveThreshold = 0.6;
        else
            %if the number of people in one frame is less than 2
            %change the adaptiveThreshold to 0.85
            adaptiveThreshold = 0.85;
        end
        
    end
    % adaptiveThreshold value change every 100(20*5) frames
    if count ~= 1
        adaptiveThreshold = temp;
    end
    
    if count == ceil(100/numFrame)
        count = 0;
    end
    
    if adaptiveThreshold==0.85 && totalArea>=0.25*height*width
        mask = foreground;
    else
        mask = afterErosion;
    end
    
end
end

