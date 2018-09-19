v = VideoReader('in4.mp4');
height = v.Height;
width = v.Width;

% manually calculated groundtruth of video in4.mp4
load Groundtruth

% decide from which frame to start the video, default 0
frameIniziale = 0;
for i=1:frameIniziale
    readFrame(v);
end


% model:
% 0 given starting point, RGB color based point wise
% 1 given starting point, RGB color based point wise and edge based histogram wise
% 2 no initial point given, RGB color based point wise
% 3 given starting point, RGB color based histogram wise
% 4 given starting point, edge based histogram wise
% 5 given starting point, HSV color based point wise and edge based histogram wise
typeOfTracking = 3;

n = 8; % number of bins per dimention
NEdgeP = 5; % number of particles used in models 1 and 5 for edge reinforcement
alpha = 0.1; % weight edge renforcement in models 1 and 5
R = 15; % initial prediction uncertainty
nu = 1; % uncertainty on prediction uncertainty

if ismember(typeOfTracking, [0, 1, 2, 5])
    QC = 1; % color obeservation uncertainty
    QE = 0.001; % edge observation uncertainty
    N = 1000; % number of particles
    h = 125; % dimention of particle side for histogram
elseif typeOfTracking == 3
    QC = 0.01;
    QE = 0.001;
    N = 35;
    h = 55;
else
    QC = 0.01;
    QE = 0.001;
    N = 35;
    h = 125;
end


mutationRate = 0.1; % mutation rate

showParticles = 1; % if 1 shows also the particles

%parameters for the initial localization
pos = groundtruth(1,:);
variance = [25 25];
PastPos(1,1) = pos(2);
PastPos(1,2) = pos(1);

frame = im2double(readFrame(v));
frameRGB(:,:,1) = frame(:,:,1) .* 255;
frameRGB(:,:,2) = frame(:,:,2) .* 255;
frameRGB(:,:,3) = frame(:,:,3) .* 255;
frameHSV = rgb2hsv(frameRGB);
frameHSV(:,:,1) = frameHSV(:,:,1) .* 255;
frameHSV(:,:,2) = frameHSV(:,:,2) .* 255;
frameHSV(:,:,3) = frameHSV(:,:,3) .* 0.1;

if typeOfTracking == 5
    [S, RGBreference] = init(frameHSV, N, height, width, pos, variance, h, typeOfTracking);
else
    [S, RGBreference] = init(frameRGB, N, height, width, pos, variance, h, typeOfTracking);
end

% show first frame 
imshow(frame), hold on
if showParticles
    if ismember(typeOfTracking, [0, 1, 2, 5])
        plot(S(2,:), S(1,:), 'o', 'Color', 'b');
    elseif ismember(typeOfTracking, [3, 4])
        for i=1:N
            rectangle('Position', [S(2,i) - floor(h/2), S(1,i) - floor(h/2), h, h], 'EdgeColor', 'b');
        end
    end
end
drawnow

if ismember(typeOfTracking, [3, 4])
    qedge = hist(RGBreference, pos, 0, n);
    qcolor = hist(RGBreference, pos, 1, n);
elseif ismember(typeOfTracking, [1, 5])
    qedge = hist(region(pos(1), pos(2), h, frameRGB), pos, 0, n);
    qcolor = 0;
else
    qedge = 0;
    qcolor = 0;
end

err(1) = 0;

t = 2;
%for each frame
while hasFrame(v)
    
    %read frame a convert it into RGB and HSV values
    frame = im2double(readFrame(v));
    
    frameRGB(:,:,1) = frame(:,:,1) .* 255;
    frameRGB(:,:,2) = frame(:,:,2) .* 255;
    frameRGB(:,:,3) = frame(:,:,3) .* 255;
    frameHSV = rgb2hsv(frameRGB);
    frameHSV(:,:,1) = frameHSV(:,:,1) .* 255;
    frameHSV(:,:,2) = frameHSV(:,:,2) .* 255;
    frameHSV(:,:,3) = frameHSV(:,:,3) .* 0.1;
    
    %perform Monte Carlo
    if typeOfTracking == 5
        [S, pos] = MCL(frameHSV, RGBreference, S, R, QC, QE, qedge, qcolor, height, width, mutationRate, typeOfTracking, h, n, NEdgeP, alpha);
    else
        [S, pos] = MCL(frameRGB, RGBreference, S, R, QC, QE, qedge, qcolor, height, width, mutationRate, typeOfTracking, h, n, NEdgeP, alpha);
    end
    
    %print frame with mean and possibly the particles
    imshow(frame), hold on
    if showParticles
        if ismember(typeOfTracking, [0, 1, 2, 5])
            plot(S(2,:), S(1,:), 'o', 'Color', 'b');
        elseif ismember(typeOfTracking, [3, 4])
            for i=1:N
                rectangle('Position', [S(2,i) - floor(h/2), S(1,i) - floor(h/2), h, h], 'EdgeColor', 'b');
            end
        end
    end
    rectangle('Position', [pos(1) - floor(h/2), pos(2) - floor(h/2), h, h], 'EdgeColor', 'r');
    plot(mean(S(2,:)), mean(S(1,:)) , 'x', 'Color', 'r');
    plot(groundtruth(t,2), groundtruth(t,1), 'x', 'Color', 'g');
    drawnow
    
    %compute distance between truth and belief
    err(t) = sqrt( (groundtruth(t,2)-pos(1))^2 + (groundtruth(t,1)-pos(2))^2 );
    t = t + 1;
    
    % update R based on previous speed
    PastPos(2,:) = PastPos(1,:);
    PastPos(1,:) = pos;
    R = 2 * sqrt((PastPos(1,1) - PastPos(2,1))^2 + (PastPos(1,2) - PastPos(2,2))^2) + nu;
    
end

nframe = size(err, 2);
x = 1:nframe;
err = err ./ sqrt( width^2 + height^2);
average_error = sum(err) / nframe;

figure, plot(x, err), grid on, hold on
plot(x, average_error .* ones(size(x)))




