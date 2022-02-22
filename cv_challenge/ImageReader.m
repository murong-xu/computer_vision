classdef ImageReader < handle
    % ImageReader
    % ImageReader load frames from left and right camera as tensors.
    
    properties
        src               % source path, relative or absolute
        L                 % choose 1 or 2 to set as left camera
        R                 % choose 2 or 3 to set as right camera
        startFrame        % select the start frame, default=0
        N                 % number of frames to be loaded after the start frame, default=1
        loop              % boolean, when remaining frames are not enough, set to 1
        opSystem          % boolean, 1 for Unix, 0 for Windows
        videoName         % the name of current video, e.g. 'P1E_S1'
        videoLength       % total number of frames in current video folder
        height            % height of each frame
        width             % width of each frame
        filePath_left     % filepath of current video (left camera)
        filePath_right    % filepath of current video (right camera)
    end
    properties(Access = private)
        leftFiles         % file info of current video (left camera)
        gtFrameNames      % ground truth file names in folder
        % 2D array, describes the mapping between ground truth frame indicies ...
        % (maybe not continuous) and user input indicies
        frameNameMapping
    end
    methods
        function ir = ImageReader(source, left, right, start, N)
            % ImageReader  Class constructor
            
            % check the current-using operating system
            if isunix
                ir.opSystem = 1;  % Unix
                sourceSplit = split(source, '/');
                ir.videoName = sourceSplit{end};
            else
                ir.opSystem = 0;  % Windows
                sourceSplit = split(source, '\');
                ir.videoName = sourceSplit{end};
            end
            
            ir.loop = 0;  % default value
            
            if nargin < 3
                % avoid empty input of required para
                assert(~isempty(source), 'Source path can not be empty')
                assert(~isempty(left), 'Please set a left camera')
                assert(~isempty(right), 'Please set a right camera')
            elseif nargin == 3
                % set start and N to default value
                start = 0;
                N = 1;
            elseif nargin == 4
                % set N to default value
                N = 1;
            end
            
            p = inputParser;
            addRequired(p, 'sourcePath', @(x) ischar(x));
            addRequired(p, 'leftCamera', @(x) isnumeric(x) && (fix(x)==x) && (x>=1) && (x<=2));
            addRequired(p, 'rightCamera', @(x) isnumeric(x) && (fix(x)==x) && (x>=2) && (x<=3));
            
            % get filepath of current video (left&right camera)
            leftCamera = [ir.videoName, '_C', num2str(left)];
            rightCamera = [ir.videoName, '_C', num2str(right)];
            if ir.opSystem  % Unix
                ir.filePath_left = fullfile(source, leftCamera, '/');
                ir.filePath_right = fullfile(source, rightCamera, '/');
            else  % Windows
                ir.filePath_left = fullfile(source, leftCamera, '\');
                ir.filePath_right = fullfile(source, rightCamera, '\');
            end
            
            % get information of video frames
            ir.leftFiles = dir(fullfile(ir.filePath_left, '*.jpg'));
            ir.videoLength = length(ir.leftFiles);
            exampleImg = imread(fullfile(ir.leftFiles(1).folder, ir.leftFiles(1).name));
            ir.height = size(exampleImg, 1);
            ir.width = size(exampleImg, 2);
            
            addRequired(p, 'Start', @(x) isnumeric(x) && (fix(x)==x) && (x>=0) && (x<=ir.videoLength));
            addRequired(p, 'numN', @(x) isnumeric(x) && (fix(x)==x) && (x>=0) && (x<=ir.videoLength));
            parse(p, source, left, right, start, N);
            
            ir.src = p.Results.sourcePath;
            ir.L = p.Results.leftCamera;
            ir.R = p.Results.rightCamera;
            ir.startFrame = p.Results.Start;
            ir.N = p.Results.numN;
            
            % get ground truth file names of current video
            ir.gtFrameNames = zeros(ir.videoLength, 1);
            for j = 1 : ir.videoLength
                currentFileName = split(ir.leftFiles(j).name, '.');
                ir.gtFrameNames(j) = str2num(currentFileName{1});
            end
            ir.frameNameMapping = [ir.gtFrameNames, ...
                linspace(0, ir.videoLength-1, ir.videoLength)'];
            
        end
        
        function [left, right, loop] = next(obj)
            % next  Load the corresponding frame pairs
            
            % map the input start index to ground truth file name
            gtStartFrameIndex = find(obj.frameNameMapping(:,2) == obj.startFrame);
            % check if the rest frames are enough to load
            if (obj.startFrame + obj.N >= obj.frameNameMapping(end,2))  % exceed
                obj.loop = 1;
                % only load the rest of frames from current video
                tensorLength = obj.frameNameMapping(end,2) - obj.startFrame + 1;
                obj.startFrame = 0;  % next time: from beginning
            else
                % load (N+1) pairs as normal
                tensorLength = obj.N + 1;
                obj.startFrame = obj.startFrame + tensorLength;
            end
            
            right = zeros(obj.height, obj.width, tensorLength * 3);  % init tensor
            left = zeros(obj.height, obj.width, tensorLength * 3);
            
            % find corresponding gt frames in the dataset
            gtTensorIndex = obj.frameNameMapping(gtStartFrameIndex:gtStartFrameIndex+tensorLength-1, 1);
            
            for i = 1 : tensorLength
                targetFrame = sprintf('%08d', gtTensorIndex(i));
                left(:, :, i*3-2:i*3) = imread([obj.filePath_left, targetFrame, '.jpg']);
                right(:, :, i*3-2:i*3) = imread([obj.filePath_right, targetFrame, '.jpg']);
            end
            
            loop = obj.loop;
        end
    end
end



