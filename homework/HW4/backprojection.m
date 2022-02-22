%% P4.5
% load('K.mat')
% load('R.mat')
% load('T.mat')
% load('P1.mat')
% load('robust_new.mat')
% Image2 = imread('sceneR.png');
% IGray2 = rgb_to_gray(Image2);
% 
% [repro_error, ~] = backprojection(correspondences_robust, P1, IGray2, T, R, K);

%% P4.5
function [repro_error, x2_repro] = backprojection(correspondences, P1, Image2, T, R, K)
% This function calculates the mean error of the back projection
% of the world coordinates P1 from image 1 in camera frame 2
% and visualizes the correct feature coordinates as well as the back projected ones.

% transform the 3D P1 points into camera2 coordinates, uncalibrated
numPoints = size(P1, 2);
P2 = K * (R * P1 + repmat(T, 1, numPoints));
% convert to homogeneous coordinates (scaling by Z=1)
x2_repro = P2 ./ P2(3, :);
% display the image 2, detected features and back projected points
figure(1)
imshow(Image2);
hold on
plot(correspondences(3,:), correspondences(4,:), 'r*', 'MarkerSize', 6, 'LineWidth',1);
hold on
plot(x2_repro(1,:), x2_repro(2,:), 'b*', 'MarkerSize', 6, 'LineWidth',1);
hold on
plot([correspondences(3,:),x2_repro(1,:)],...
    [correspondences(4,:),x2_repro(2,:)], 'g-', 'LineWidth',1);
hold on
for i=1:numPoints
    str = int2str(i);
    text(correspondences(3,i), correspondences(4,i), str, 'Color', 'r');
    text(x2_repro(1,i), x2_repro(2,i), str, 'Color', 'b');
end
% calculate the mean error of back projection
onesArray = ones(1, numPoints);
x2 = correspondences(3:4, :);
x2 = [x2; onesArray];  % x2 in uncalibrated homo coordinates
repro_error = 0;
for j = 1:numPoints
    repro_error = repro_error + norm(x2(:, j) - x2_repro(:, j));
end
repro_error = repro_error ./ numPoints;

end