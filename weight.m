% input = prediction, likelihood
%   S_hat:         3xN
%   Psi:           1xN
% output = weight particles at time t in state system
%   S_hat:         3xN
function S_hat = weight(S_hat, Psi)

normalizationFactor = sum(Psi);
if normalizationFactor ~= 0
    S_hat(3, :) = Psi/normalizationFactor;
end

end