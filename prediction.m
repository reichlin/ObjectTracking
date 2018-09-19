% input = state system at t-1, uncertainty, height and width of the frame,
% mutation rate, model's type, length of the subregion
%     S:                3xN
%     R:                1
%     height:           1
%     width:            1
%     mutationRate:     1
%     typeOfTracking:   1
%     h:                1
% output = believed state system
%     S_hat:            3xN
function S_hat = prediction(S, R, height, width, mutationRate, typeOfTracking, h)

N = size(S, 2);
S_hat = zeros(3,N);

if ismember(typeOfTracking, [0, 2])
    
    %increase uncertainty
    S_hat(1,:) = S(1,:) + floor(R.*2.*rand(1,N) - R);
    S_hat(2,:) = S(2,:) + floor(R.*2.*rand(1,N) - R);
    S_hat(3,:) = S(3,:);
    
    %mutation
    for i=1:floor((mutationRate*N))
        mutatedParticle = floor(rand()*N);
        if mutatedParticle == 0
            mutatedParticle = 1;
        end
        S_hat(1, mutatedParticle) = floor(rand()*height);
        S_hat(2, mutatedParticle) = floor(rand()*width);
    end
    
    %check that particles remain into the frame boundaries
    S_hat(1, (S_hat(1,:) < 1)) = 1;
    S_hat(1, (S_hat(1,:) > height)) = height;
    S_hat(2, (S_hat(2,:) < 1)) = 1;
    S_hat(2, (S_hat(2,:) > width)) = width;
    
elseif ismember(typeOfTracking, [1, 3, 4, 5])
    
    %increase uncertainty
    S_hat(1,:) = S(1,:) + floor(R.*2.*rand(1,N) - R);
    S_hat(2,:) = S(2,:) + floor(R.*2.*rand(1,N) - R);
    S_hat(3,:) = S(3,:);
    
    %mutation
    for i=1:floor((mutationRate*N))
        mutatedParticle = floor(rand()*N);
        if mutatedParticle == 0
            mutatedParticle = 1;
        end
        S_hat(1, mutatedParticle) = floor(rand()*height);
        S_hat(2, mutatedParticle) = floor(rand()*width);
    end
    
    %check that particles remain into the frame boundaries
    S_hat(1, (S_hat(1,:) - h/2 < 1)) = 1 + floor(h/2);
    S_hat(1, (S_hat(1,:) + h/2 > height)) = height - floor(h/2);
    S_hat(2, (S_hat(2,:) - h/2 < 1)) = 1 + floor(h/2);
    S_hat(2, (S_hat(2,:) + h/2 > width)) = width - floor(h/2);
    
end

end