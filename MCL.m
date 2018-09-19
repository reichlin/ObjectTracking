% input = frame at time t, color reference, state system, uncertainties for
% prediction and observation for color and edge, histogram reference for
% color and edge, height and width of the frame, mutation rate, model's
% type, length of the subregion, number of bins per dimention, number of
% particle for edge reinforcement, weight of the edge in the linear
% combination between color and edge observations
%       frame:              480x640x3
%       RGBreference:       Nx3
%       Spast:              3xN
%       R:                  1
%       QC:                 1
%       QE:                 1
%       qedge:              nxnx2
%       qcolor:             nxnx3
%       height:             1
%       width:              1
%       mutationRate:       1
%       typeOfTracking:     1
%       h:                  1
%       n:                  1
%       NedgeP:             1
%       alpha:              1
% output = State system
%       S:                  3xN
%       pos:                1x2
function [S, pos] = MCL(frame, RGBreference, Spast, R, QC, QE, qedge, qcolor, height, width, mutationRate, typeOfTracking, h, n, NEdgeP, alpha)

%prediction
S_hat = prediction(Spast, R, height, width, mutationRate, typeOfTracking, h);

%observation
Psi = observation(S_hat, frame, RGBreference, QC, QE, qedge, qcolor, typeOfTracking, h, n, NEdgeP, alpha);

%weight
S_hat = weight(S_hat, Psi);

%compute posterior belief
N = size(Spast,2);
summa(1) = sum(S_hat(3,:) .* S_hat(2,:));
summa(2) = sum(S_hat(3,:) .* S_hat(1,:));
pos = summa ./ sum(S_hat(3,:));

%resample
S = resample(S_hat);

end