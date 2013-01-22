function [H Yrecon score W] = fitactivations(Y, W, H)
% function [H Yrecon score W] = fitactivations(Y, W, H)
% 
% Function to match a target spectrogram Y using a dictionary of short
% spectrograms W.
% 
% Inputs:
% Y: The target spectrogram (M-by-N).
% W: The dictionary of K spectrograms of length L (M-by-K-by-L; W(m, k, l)
% is the amplitude at frequency m and time offset l of spectrogram k).
% H: Initial value for the matrix of activations (K-by-(N+L-1)).
% 
% Outputs:
% H: Improved matrix of activations. H(k, n) says how active each
% dictionary element is at time n-L+1 (i.e., they can start going before
% the target spectrogram does).
% Yrecon: Reconstruction of the target spectrogram using W and H.
% score: Measure of model fit. Higher is better.
% W: Improved matrix of dictionary elements. Not meaningful if you have a
% specific existing set of sounds in mind---in that case, don't reassign W!

M = size(Y, 1);
N = size(Y, 2);
K = size(W, 2);
L = size(W, 3);

% If there are more than 3 arguments variables in the function call,
% compute W
if (nargout > 3)
    Yrecon = reconstruct(W, H);
    score = mean(mean(Y .* log(Yrecon) - Yrecon + gammaln(Y+1)));
    for l = 1:L,
        W(:, :, l) = W(:, :, l) .* (Y ./ Yrecon * H(:, L-l+1:end-l+1)') * ... 
            diag(sparse(1./sum(H(:, L-l+1:end-l+1), 2)));
    end
end

Yrecon = reconstruct(W, H);
score = mean(mean(Y .* log(Yrecon) - Yrecon + gammaln(Y+1)));
Hnum = zeros(size(H));
Hdenom = zeros(size(H));
for l = 1:L,
    Hnum(:, L-l+1:end-l+1) = Hnum(:, L-l+1:end-l+1) + W(:, :, l)' * (Y ./ Yrecon);
    Hdenom(:, L-l+1:end-l+1) = Hdenom(:, L-l+1:end-l+1) + ... 
        repmat(sum(W(:, :, l), 1)', 1, N);
end
H = H .* Hnum ./ Hdenom;



function Yrecon = reconstruct(W, H)
M = size(W, 1);
K = size(W, 2);
L = size(W, 3);
N = size(H, 2) - L + 1;
Yrecon = zeros(M, N);
for l = 1:L
    Yrecon = Yrecon + W(:, :, l) * H(:, L-l+1:end-l+1);
end





