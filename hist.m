% input = subregion, subregion center, color flag, number of bins per dimension
%   region:     hxhx3
%   c:          1x2
%   color:      1
%   n:          1
% output =  subregion histogram 
%   color == 1:
%       p:      nxnx3
%   color == 0:
%       p:      nxnx2

function p = hist(region, c, color, n)
    h = size(region, 1);
    a = h/2; 
    sum = 0; 
    
    if color == 1
        p = zeros(n,n,n);
        
        for i=1:h
            for j=1:h
                bin = bin_assignment(region(i,j,:), color, n);
                k = kern(norm(c-[i+c(1)-floor(h/2),j+c(2)-floor(h/2)]) / a);
                sum = sum + k;
                p(bin(1),bin(2),bin(3)) = p(bin(1),bin(2),bin(3)) + k;
            end
        end
        p = p./sum;
    else
        p = zeros(n,n);
        region = sobel(region, h);
        
        for i=1:h
            for j=1:h
                bin = bin_assignment(region(i,j,:), color, n);
                k = kern(norm(c-[i+c(1)-floor(h/2),j+c(2)-floor(h/2)]) / a);
                sum = sum + k;
                p(bin(1),bin(2)) = p(bin(1),bin(2)) + k;
            end
        end
        p = p./sum;
         
    end
end

function val = kern(in)
    val = 0;
    if in < 1
        val = 1 - in^2;
    end
end