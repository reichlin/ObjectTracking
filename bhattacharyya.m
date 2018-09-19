% input = particle histogram, reference histogram, color cue flag
%   color == 1:
%       p:      nxnx3
%       q:      nxnx3
%   color == 0:
%       p:      nxnx2
%       q:      nxnx2
% output = Bhattacharyya distance
%   dist:       1

function [dist] = bhattacharyya(p, q, color)
    
    if color == 1
        ro = sum( sum( sum( (p .* q).^(0.5) ) ) );
    else
        ro = sum( sum( (p .* q).^(0.5) ) );
    end
    
    dist = sqrt(1 - ro);
end
