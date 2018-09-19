% input = value to be assigned, color cue flag, number of bins per dimension
%   x:          1
%   color:      1
%   n:          1
% output =  bin assignment
%   color == 1:
%       bins:   1x3
%   color == 0:
%       bins:   1x2

function [bins] = bin_assignment(x, color, n)
    if color == 1
        bins = [channel(x(1), n), channel(x(2), n), channel(x(3), n)];
    else
        bins = [channel(x(1).*255, n), channel((x(2)./(pi) + 0.5).*255, n)];
    end
    
end

function bin = channel(val, n)

    bin = n;
    for i=1:n
        if val < (255/n)*i
            bin = i;
            break
        end
    end
end
