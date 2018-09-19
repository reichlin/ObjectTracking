% input = first frame, number of particles, height and width of the frame,
% first position of the object, variance of the gaussian from which to
% sample first set of particles, length of the subregion, model's type
%       frame:              480x640x3
%       N:                  1
%       height:             1
%       width:              1
%       pos:                1x2
%       variance:           1x2
%       h:                  1
%       typeOfTracking:     1
% output = State system, RGBreference
%       S:                  3xN
%       RGBreference:       Nx3
function [S, RGBreference] = init(frame, N, height, width, pos, variance, h, typeOfTracking)

S = zeros(3, N);

%initialize particles given a starting point, create reference based on
%points
if ismember(typeOfTracking, [0, 1, 5])
    
    RGBreference = zeros(N,3);
    
    S(1:2,:) = floor(mvnrnd(pos, variance, N))';
    S(3,:) = ones(1,N) .* 1/N;
    
    S(1, (S(1,:) < 1)) = 1;
    S(1, (S(1,:) > height)) = height;
    S(2, (S(2,:) < 1)) = 1;
    S(2, (S(2,:) > width)) = width;
    
    idx = sub2ind(size(frame),S(1,:),S(2,:),1.*ones(1,N));
    RGBreference(:,1) = frame(idx);
    idx = sub2ind(size(frame),S(1,:),S(2,:),2.*ones(1,N));
    RGBreference(:,2) = frame(idx);
    idx = sub2ind(size(frame),S(1,:),S(2,:),3.*ones(1,N));
    RGBreference(:,3) = frame(idx);
    
% initialize particles randomly, create reference based on points
elseif typeOfTracking == 2
    
    RGBreference = zeros(N,3);
    
    S(1, :) = randi(height, 1, N);
    S(2, :) = randi(width, 1, N);
    S(3, :) = 1/N .* ones(1, N);
    
    %reference color
    RGBreference(:, 1) = 255 .* ones(N, 1);
    RGBreference(:, 2) = 229 .* ones(N, 1);
    RGBreference(:, 3) = 113 .* ones(N, 1);
    
% initialize particles given a starting point, create reference based on
% histograms
elseif ismember(typeOfTracking, [3, 4])
    
    RGBreference = zeros(h, h, 3);
    
    S(1:2,:) = floor(mvnrnd(pos, variance, N))';
    S(3,:) = ones(1,N) .* 1/N;
    
    S(1, (S(1,:) - h/2 < 1)) = 1 + floor(h/2);
    S(1, (S(1,:) + h/2 > height)) = height - floor(h/2);
    S(2, (S(2,:) - h/2 < 1)) = 1 + floor(h/2);
    S(2, (S(2,:) + h/2 > width)) = width - floor(h/2);
    
    % print subregion used as reference
    RGBreference = region(pos(1), pos(2), h, frame);
    figure, imshow(RGBreference./255)
    edgereference = sobel(RGBreference, h);
    figure, imshow(edgereference(:,:,1))
    pause;
    
end

end