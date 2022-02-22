function [result] = render(frame, mask, bg, render_mode)
% RENDER renders the mask for current frame according to the given mode.

% Input: frame       --> original RGB frame with size [600,800,3]
%        mask        --> binary mask of frame with size [600,800,1]
%        bg          --> virtual background with size [600,800,3]
%        rendermode  --> rendering mode, choose a string between
%                      'foreground' 'background' 'overlay' and 'substitute'
%
% 'foreground' : Preserve foreground of the original frame, set background
%                to black.
% 'background' : Preserve background of the original frame, set foreground
%                to black.
% 'overlay'    : The foreground of the original image will be marked
%                in green with 50% transparency, and the background in red
%                with 50% transparency.
% 'substitute' : The background of the original frame is replaced by a
%                virtual background, while the foreground remains.

switch render_mode
    case 'foreground'
        result = frame .* mask;
        
    case 'background'
        mask = abs(mask - 1);
        result = frame .* mask;
        
    case 'overlay'
        z = zeros(size(frame));
        G = zeros(size(frame));
        R = zeros(size(frame));
        % separate the foreground in green
        G(:, :, 2) = (z(:, :, 2) + 255) .* mask;
        mask = abs(mask - 1);
        % separate the background in red
        R(:, :, 1) = (z(:, :, 1) + 255) .* mask;
        % add transparency
        result = frame + 0.5.*G + 0.5.*R;
        
    case 'substitute'
        result_fg = frame .* mask;
        mask = abs(mask - 1);
        % apply virtual background
        result_bg = bg .* mask;
        result = result_fg + result_bg;
end
end
