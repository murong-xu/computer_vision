%%
% % Bilder laden
% Image1 = imread('sceneL.png');
% IGray1 = rgb_to_gray(Image1);
% 
% Image2 = imread('sceneR.png');
% IGray2 = rgb_to_gray(Image2);
% 
% % Harris-Merkmale berechnen
% features1 = harris_detector(IGray1,'segment_length',9,'k',0.05,...
%     'min_dist',40,'N',50,'do_plot',false);
% features2 = harris_detector(IGray2,'segment_length',9,'k',0.05,...
%     'min_dist',40,'N',50,'do_plot',false);
% 
% % Korrespondenzschaetzung
% correspondences = point_correspondence(IGray1,IGray2,features1,...
%     features2,'window_length',25,'min_corr',0.9,'do_plot',false);
% 
% % Fundamentalmatrix
% F = epa(correspondences);
% 
% % Essentielle Matrix
% load('K.mat');
% E = epa(correspondences, K);

%%
function [EF] = epa(correspondences, K)
% Depending on whether a calibrating matrix 'K' is given,
% this function calculates either the essential or the fundamental matrix
% with the eight-point algorithm.

%% First step of the eight-point algorithm from task 3.1
% Known variables:
% x1, x2        homogeneous (calibrated) coordinates
% A             matrix A for the eight-point algorithm
% V             right-singular vectors
numFeatures = size(correspondences, 2);
onesArray = ones(1, numFeatures);
x1 = correspondences(1:2, :);
x1 = [x1; onesArray];  % homo coordinates
x2 = correspondences(3:4, :);
x2 = [x2; onesArray];
if nargin == 2  % given calibrating matrix K
    x1 = inv(K) * x1;
    x2 = inv(K) * x2;
end
A = zeros(numFeatures, 9);
for i = 1:numFeatures
    x1_sample = x1(:, i);  % i-th sample
    x2_sample = x2(:, i);
    A(i, :) = kron(x1_sample, x2_sample)';  % cronecker product on i-th sample
end
[U, S, V] = svd(A);

%% Estimation of the matrices
G_s = V(:, 9);  % optimal solution of minimization problem
G = reshape(G_s, [3,3]);  % col-wise, from [1,9] to [3,3]
[U_G, S_G, V_G] = svd(G);
% ensure the rotation matrices
if det(U_G) ~= 1
    U_G = U_G * [1 0 0;0 1 0;0 0 -1];
end
if det(V_G) ~= 1
    V_G = V_G * [1 0 0;0 1 0;0 0 -1];
end
if nargin == 2  % given K, return essential matirx
    sigma = diag([1,1,0]);  % normalized essential matrix
    EF = U_G * sigma * V_G';
else  % return fundamental matrix
    sigma = S_G;
    sigma(3,3) = 0;  % set the smallest singular value to 0
    EF = U_G * sigma * V_G';
end
end