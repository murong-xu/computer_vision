%% P1.1
% img = imread('sceneR.png');
% gray = rgb_to_gray(img);
% imshow(gray)

%% P1.1
function gray_image = rgb_to_gray(input_image)
% This function is supposed to convert a RGB-image to a grayscale image.
% If the image is already a grayscale image directly return it.
sz = size(input_image);
if numel(sz)>2  % if the image has 3 channels (RGB)
    input_image = double(input_image);
    gray_image = 0.299*input_image(:,:,1) + 0.587*input_image(:,:,2) ...
        + 0.114*input_image(:,:,3);
    gray_image = uint8(gray_image);
else
    gray_image = input_image;
end
end