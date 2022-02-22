%% P4.1
% load('K.mat')
% load('robust.mat')
% E = epa(correspondences_robust, K);
% 
% [T1, R1, T2, R2, ~, ~] = TR_from_E(E)

%% P4.1
function [T1, R1, T2, R2, U, V] = TR_from_E(E)
% This function calculates the possible values for T and R
% from the essential matrix
[U, S, V] = svd(E);
% ensure the rotation matrices
if det(U) ~= 1
    U = U * [1,0,0; 0,1,0; 0,0,-1]; % reverse, along z-axis
end
if det(V) ~= 1
    V = V * [1,0,0; 0,1,0; 0,0,-1];
end
% compute the rotation matrices around z-axis
Rz_1 = [0,-1,0; 1,0,0; 0,0,1];  % + 180
Rz_2 = [0,1,0; -1,0,0; 0,0,1];  % - 180
% reconstruction of R and T
R1 = U * Rz_1' * V';
T1_hat = U * Rz_1 * S * U';
R2 = U * Rz_2' * V';
T2_hat = U * Rz_2 * S * U';
% convert T_dach (3,3) to T matrix (3,1)
T1 = [T1_hat(3,2); T1_hat(1,3); T1_hat(2,1)];
T2 = [T2_hat(3,2); T2_hat(1,3); T2_hat(2,1)];
end