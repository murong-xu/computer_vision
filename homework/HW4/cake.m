%% P1.8
% Cake = cake(50);
% colormap('gray');
% imagesc(Cake)

%% P1.8
function Cake = cake(min_dist)
% The cake function creates a "cake matrix" that contains a circular set-up of zeros
% and fills the rest of the matrix with ones.
% This function can be used to eliminate all potential features around a stronger feature
% that don't meet the minimal distance to this respective feature.
range = -min_dist:min_dist; 
[x, y] = meshgrid(range, range);
circle = x.^2 + y.^2; % circle border

Cake = zeros(length(range));  
Cake(circle>min_dist.^2) = 1; % outside the border: set to 1
Cake = logical(Cake);
end