% input = subregion, length of the subregion
%   frame:      hxhx3
%   sideLength: 1
% output = sobel operator applied on subregion
%   reference:  hxhx2

function [reference] = sobel(frame, sideLength)

    frameBW = (frame(:,:,1)+frame(:,:,2)+frame(:,:,3))/(3*255);
    reference = zeros(sideLength, sideLength, 2);
    kernelx = [-1 0 1; -2 0 2; -1 0 1];
    kernely = [-1 -2 -1; 0 0 0; 1 2 1];
    for h=1:sideLength
        for i=1:sideLength
            x=0;
            y=0;
            for j=1:3
                for k=1:3
                    idx = h+j-2;
                    idy = i+k-2;
                    if idx < 1
                        idx = 1;
                    elseif idx > sideLength
                        idx = sideLength;
                    end
                    if idy < 1
                        idy = 1;
                    elseif idy > sideLength
                        idy = sideLength;
                    end
                    x = x + frameBW(idx, idy) * kernelx(j, k);
                    y = y + frameBW(idx, idy) * kernely(j, k);
                end
            end
            reference(h, i, 1) = sqrt(x^2 + y^2);
            reference(h, i, 2) = atan(y/x);
        end
    end
    
end