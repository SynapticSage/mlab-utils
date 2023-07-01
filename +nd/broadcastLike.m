function [A, B] = boadcastLike(A, B)
%BOADCASTLIKE Broadcasts the dimensions of B to A and vice versa.
%   [A, B] = BOADCASTLIKE(A, B) broadcasts the dimensions of B to A and vice
%   versa. This is useful for broadcasting a scalar to a matrix or a matrix
%   to a scalar.
%
% Example:
%   A = [1, 2, 3];
%   B = 5;
%   [A, B] = nd.broadcastLike(A, B);
%   

[szA, szB] = getSz(A, B);

% How much to expand each dimension of A to match B
% Matching dimensions are allowed...and non-matching
% dimensions are only allowed to be [X, 1] or [1,X]
% where X is the size of the non-matching dimension.

% Expand A to match B
for i = 1:length(szA)
    if szB(i) ~= 1
        d = szB(i);
        if szA(i) == 1
            d = [ones(1, i-1), d];
            A = repmat(A, d);
            [szA, szB] = getSz(A, B);
        elseif szA(i) ~= d
            error('Dimensions do not match');
        end
    elseif szA(i) ~= 1
        d = szA(i);
        if szB(i) == 1
            d = [ones(1, i-1), d];
            B = repmat(B, d);
            [szA, szB] = getSz(A, B);
        elseif szB(i) ~= d
            error('Dimensions do not match');
        end
    end
end

function [szA,szB] = getSz(A, B)

szA = size(A);
szB = size(B);
% pad with ones to make the sizes match
szA = [szA, ones(1, max(0, length(szB) - length(szA)))];
szB = [szB, ones(1, max(0, length(szA) - length(szB)))];
