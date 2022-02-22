%% Write generated AVI video to Disk
function [] = SaveMovie(targetFolderMovie, dest, store)
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
end