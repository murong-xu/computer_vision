%% P4.1 + P4.2 + P4.3
% load('K.mat')
% load('robust.mat')
% E = epa(correspondences_robust, K);
% [T1, R1, T2, R2] = TR_from_E(E);
%
% [T, R, lambda, P1, ~, ~] = ...
%     reconstruction(T1, T2, R1, R2, correspondences_robust, K);
%
% % Equal scaling of X- and Y-Axis
% h = get(gca,'DataAspectRatio');
% set(gca,'DataAspectRatio',[1 1 h(3)]);

%% P4.1 + P4.2 + P4.3
function [T, R, lambda, P1, camC1, camC2] = reconstruction(T1, T2, R1, R2, correspondences, K)
% This function estimates the depth information and thereby determines the
% correct Euclidean movement R and T. Additionally it returns the
% world coordinates of the image points regarding image 1 and their depth information.
%% Preparation from task 4.2
% T_cell    cell array with T1 and T2
% R_cell    cell array with R1 and R2
% d_cell    cell array for the depth information
% x1        homogeneous calibrated coordinates
% x2        homogeneous calibrated coordinates% 4 possibilities to combie T and R
T_cell = {T1, T2, T1, T2};
R_cell = {R1, R1, R2, R2};
N = size(correspondences, 2);  % number of features
onesArray = ones(1, N);
x1 = correspondences(1:2, :);
x1 = [x1; onesArray];  % homo coordinates
x2 = correspondences(3:4, :);
x2 = [x2; onesArray];
% after calibration
x1 = inv(K) * x1;
x2 = inv(K) * x2;
% initialize depth information cell array
d_cell = {zeros(N,2), zeros(N,2), zeros(N,2), zeros(N,2)};
%% R, T and lambda from task 4.3
% T         reconstructed translation
% R         reconstructed rotation
% lambda    depth information
N = size(correspondences, 2);  % number of features
M1 = zeros(3*N, N+1);
M2 = zeros(3*N, N+1);
% loop for all possible combinations of R and T
for i = 1:4
    x1_cell = mat2cell(x1, 3, ones(1,N));  % convert x to a cell array
    x2_cell = mat2cell(x2, 3, ones(1,N));
    % compute the x hat
    x1_hat = cellfun(@(a) hat(a), x1_cell, 'UniformOutput', false);
    x2_hat = cellfun(@(a) hat(a), x2_cell, 'UniformOutput', false);
    T = T_cell{i};
    R = R_cell{i};
    for j = 1:N
        % compute the M matrices
        M1(3*j-2:3*j, j) = x2_hat{j} * R * x1_cell{j};
        M1(3*j-2:3*j, N+1) = x2_hat{j} * T;
        M2(3*j-2:3*j, j) = x1_hat{j} * R' * x2_cell{j};
        M2(3*j-2:3*j, N+1) = -x1_hat{j} * R' * T;
    end
    % SVD on M
    [~,~,V1] = svd(M1);
    [~,~,V2] = svd(M2);
    % the solution of the minimization problem is with the min. singular
    % value (the last column of V)
    d1 = V1(:, end);
    d2 = V2(:, end);
    % normalization: set gamma to 1
    d1 = d1./d1(end, :);
    d2 = d2./d2(end, :);
    % update the depth information
    d_cell{i} = [d1(1:end-1, :), d2(1:end-1,:)];
end
% find the stored depth vector with most positive entries
indexPositive = cellfun(@(a) find(a>0), d_cell, 'UniformOutput', false);
numPositive = cellfun(@length, indexPositive, 'UniformOutput', false);
numPositive = cell2mat(numPositive);
[~, maxIndex] = max(numPositive);
R = R_cell{maxIndex};
T = T_cell{maxIndex};
lambda = d_cell{maxIndex};
%% Calculation and visualization of the 3D points and the cameras
% using the image coordinates + depth info to obtain the 3D points
% (real world)
N = size(correspondences, 2);  % number of features
P1 = zeros(3, N);
for i=1:N
    P1(:, i) = lambda(i, 1) .* x1(:, i);  % in terms of camera 1
end
figure(1)
scatter3(P1(1,:), P1(2,:), P1(3,:));
for i=1:N
    % number the 3D coordinates
    text(P1(1,i), P1(2,i), P1(3,i), num2str(i));
end
% corners of cameraframe 1
camC1 = [-0.2,0.2,0.2,-0.2; 0.2,0.2,-0.2,-0.2; 1,1,1,1];
% compute corners of cameraframe 2 via Eucl. transformation
camC2 = inv(R) * (camC1 - [T, T, T, T]);
% plot the squares for cameraframe1 & 2 into the scene
camC1_plot = [camC1 camC1(:,1)];  % to plot a closed square
camC2_plot = [camC2 camC2(:,1)];
figure(2)
frame1 = plot3(camC1_plot(1,:), camC1_plot(2,:), camC1_plot(3,:), 'b');
grid on;
hold on;
frame2 = plot3(camC2_plot(1,:), camC2_plot(2,:), camC2_plot(3,:), 'r');
xlabel('X');
ylabel('Y');
zlabel('Z');
campos([43, -22, -87]);  % camera position
camup([0, -1, 0]);  % camera up vector
legend([frame1, frame2], {'Cam1','Cam2'});
end
%% hat-operator
function W = hat(w)
% This function implements the ^-operator.
% It converts a 3x1-vector into a skew symmetric matrix.
sz = size(w,1);
if sz == 3
    w_1 = w(1);
    w_2 = w(2);
    w_3 = w(3);
    W = [0, -w_3, w_2; w_3, 0, -w_1; -w_2, w_1, 0];
else
    msg = 'Variable w has to be a 3-component vector!';
    error(msg);
end
end