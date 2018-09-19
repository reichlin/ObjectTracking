% input = center x coordinate, center y coordinate, length of the
% subregion, fram
%   x:          1
%   y:          1
%   h:          1
%   frame:      heightxlengthx3
% output = subregion
%   reference:  hxhx3

function r = region(x, y, h, frame)

    r = zeros(h, h, 3);
    
    r(:,:,1) = frame(x-floor(h/2):x+floor(h/2), y-floor(h/2):y+floor(h/2), 1);
    r(:,:,2) = frame(x-floor(h/2):x+floor(h/2), y-floor(h/2):y+floor(h/2), 2);
    r(:,:,3) = frame(x-floor(h/2):x+floor(h/2), y-floor(h/2):y+floor(h/2), 3);
       
end
