%% P1.2
% img = im2double(imread('sceneL.png'));
% gray = rgb_to_gray(img);
% [Fx, Fy] = sobel_xy(gray);
% 
% colormap('gray')
% figure();
% subplot(1,2,1), imagesc(Fx)
% subplot(1,2,2), imagesc(Fy)

%% P1.2
function [Fx, Fy] = sobel_xy(input_image)
% In this function you have to implement a Sobel filter
% that calculates the image gradient in x- and y- direction of a grayscale image.
sobelX = [1,0,-1; 2,0,-2; 1,0,-1];
sobelY = [1,2,1; 0,0,0; -1,-2,-1];
Fx = conv2(input_image, sobelX, 'same');
Fy = conv2(input_image, sobelY, 'same');
end