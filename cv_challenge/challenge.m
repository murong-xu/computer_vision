%% Computer Vision Challenge 2020 challenge.m
%% Start timer here
t1=clock;

%% Generate Movie
% Create folder to store the processed frames
targetFolderMovie = './results/Movie/';

if exist(targetFolderMovie, 'dir')
    rmdir(targetFolderMovie, 's');  % remove the previous generated results
end

mkdir(targetFolderMovie);

% Segmentation und rendering

% Initialtion
numBgFrame = length(bg);  % for single bg image is 1, for video bg is >1

% Define global adaptive threshold for foreground detection
global adaptiveThreshold;
global count;
adaptiveThreshold = 0.85;  % initialization
count = 0;  % initialization

% Loop for all frames in current video folder
indexResultFrame = 0;
loop = 0;
while loop ~= 1
    % Get next tensor
    [left, right, loop] = ir.next();
    numFrame = size(left, 3)/3;  % number of frames in a tensor
    
    % Generate the same binary mask for all frames in current tensor
    % Case 1: only 1 frame on hand
    if numFrame == 1
        % Use the information from previous frames
        ir_end = ImageReader(src, L, R, ir.videoLength-N+1, N);
        [left_end, right_end, loop_end] = ir_end.next();
        binaryMask = segmentation(left_end, right_end);
    else
        % Case 2: at least 2 frames remaining
        binaryMask = segmentation(left, right);
    end
    
    % Render and save the resulting frames for current tensor
    for i = 1 : numFrame
        currentLeft = left(:, :, 3*i-2:3*i);
        currentMask = binaryMask;
        indexResultFrame = indexResultFrame + 1;
        
        if strcmp(render_mode, 'substitute')
            % Decide the index of background to be applied
            if numBgFrame == 1  % still image
                numBg = 1;
            else  % video
                if indexResultFrame > numBgFrame
                    if mod(indexResultFrame, numBgFrame) == 0
                        numBg = numBgFrame;
                    else
                        numBg = mod(indexResultFrame, numBgFrame);
                    end
                end
            end
            % Subsitute video background
            movie{indexResultFrame} = render(currentLeft, currentMask, bg{numBg}, render_mode);
        else
            % "foreground"/"background"/"overlay" mode
            movie{indexResultFrame} = render(currentLeft, currentMask, bg, render_mode);
        end
        % Export the resulting images
        imwrite(movie{indexResultFrame}./255, [targetFolderMovie, 'movie_', ...
            num2str(indexResultFrame-1, '%08d'), '.jpg']);
    end
    
    movie = cellfun(@(x) x./255, movie, 'UniformOutput', false);
end

%% Stop timer here
t2 = clock;
elapsed_time = etime(t2, t1);
fprintf('The execution time is: %.2f\n', elapsed_time);

%% Write movie as avi video to disk
% Remove the previous generated video
if(exist(dest, 'file') > 0)
    delete(dest);
end

if store
    v = VideoWriter(dest, 'Motion JPEG AVI');
    v.FrameRate = 30;
    open(v);
    fileExt = '*.jpg';
    files = dir(fullfile(targetFolderMovie, fileExt));
    lengthMovie = size(files, 1);
    
    % Read resulting frames
    for i = 1 : lengthMovie
        fileName = strcat(targetFolderMovie, files(i).name);
        readFrame = im2double(imread(fileName));
        writeVideo(v, readFrame);
    end
    close(v);
end
