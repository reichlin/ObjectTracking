% input = State of the system, current frame, RGB reference, observation
% uncertainty for color and edge models, histogram reference for color and edge,
% model's type, length of the subregion, number of bins per dimention,
% number of particle for edge reinforcement, weight of the edge in the
% linear combination between color and edge observations
% uncertainty
%   S:                3xN
%   frame:            480x640x3
%   RGBreference:     Nx3
%   QC:               1
%   QE:               1
%   qedge:            nxnx2
%   qcolor:           nxnx3
%   typeOfTracking:   1
%   h:                1
%   n:                1
% NEdgeP:
% alpha:
% output = likelihood
%   Psi:              1xN
function Psi = observation(S, frame, RGBreference, QC, QE, qedge, qcolor, typeOfTracking, h, n, NEdgeP, alpha)

N = size(S,2);
Psi = zeros(1,N);

% distance between color values of each particle and the reference
if ismember(typeOfTracking, [0, 2])
    
    idx = sub2ind(size(frame),S(1,:),S(2,:),1.*ones(1,N));
    RGB(:,1) = frame(idx);
    idx = sub2ind(size(frame),S(1,:),S(2,:),2.*ones(1,N));
    RGB(:,2) = frame(idx);
    idx = sub2ind(size(frame),S(1,:),S(2,:),3.*ones(1,N));
    RGB(:,3) = frame(idx);
    
    Psi(:) = exp(-0.5 .* sqrt((RGBreference(:,1) - RGB(:,1)).^2 + (RGBreference(:,2) - RGB(:,2)).^2 + (RGBreference(:,3) - RGB(:,3)).^2) ./ QC);
    
% same as before but add edge observation as reinforcement
elseif ismember(typeOfTracking, [1, 5])
    
    idx = sub2ind(size(frame),S(1,:),S(2,:),1.*ones(1,N));
    RGB(:,1) = frame(idx);
    idx = sub2ind(size(frame),S(1,:),S(2,:),2.*ones(1,N));
    RGB(:,2) = frame(idx);
    idx = sub2ind(size(frame),S(1,:),S(2,:),3.*ones(1,N));
    RGB(:,3) = frame(idx);
    
    
    Psi(:) = exp(-0.5 .* sqrt((RGBreference(:,1) - RGB(:,1)).^2 + (RGBreference(:,2) - RGB(:,2)).^2 + (RGBreference(:,3) - RGB(:,3)).^2) ./ QC);
    
    Edgeparticles = floor(rand(1, NEdgeP).*N + ones(1, NEdgeP));
    for i=1:NEdgeP
        p = hist(region(S(1,Edgeparticles(i)), S(2,Edgeparticles(i)), h, frame), [S(1,Edgeparticles(i)), S(2,Edgeparticles(i))], 0, n);
        phist = bhattacharyya(p, qedge, 0);
        if phist < 0.15
            for j=1:N
                if S(1, j) > S(1, Edgeparticles(i)) - h/2 && S(1, j) < S(1, Edgeparticles(i)) + h/2
                    if S(2, j) > S(2, Edgeparticles(i)) - h/2 && S(2, j) < S(2, Edgeparticles(i)) + h/2
                        Psi(j) = Psi(j) + alpha*exp(-phist);
                    end
                end
            end
        end
    end
    
% bhattacharyya distance between histogram build on each particle and
% reference histogram color based
elseif typeOfTracking == 3
    
     for i=1:N
        p = hist(region(S(1,i), S(2,i), h, frame), [S(1,i), S(2,i)], 1, n);
        Psi(i) = bhattacharyya(p, qcolor, 1);
     end
     Psi = exp(-0.5.*(Psi.^2)./QC);
    
% bhattacharyya distance between histogram build on each particle and
% reference histogram edge based
elseif typeOfTracking == 4
        
    for i=1:N
        p = hist(region(S(1,i), S(2,i), h, frame), [S(1,i), S(2,i)], 0, n);
        Psi(i) = bhattacharyya(p, qedge, 0);
     end
     Psi = exp(-0.5.*(Psi.^2)./QE);
    
end

end