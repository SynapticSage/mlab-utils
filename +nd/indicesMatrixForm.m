function indices = indicesMatrixForm(obj)
%GETINDICES returns matrix form of indices of object
%   indices = indicesMatrixForm(obj)
%
%   Example
%   indices = indicesMatrixForm(obj)
%
% Suppose we have
%   obj = Image2D(rand(3, 2));
%   indices = indicesMatrixForm(obj)
%   indices = [
%       1   1
%       2   1
%       3   1
%       1   2
%       2   2
%       ....
%       3   2]
%
%   In other words, we are given the indices of each location within
%   each row of the output

size_ = size(obj);
size_ = num2cell(size_);
size_ = cellfun(@(x) 1:x, size_, 'UniformOutput',false);

grid = cell(1, numel(size_));
[grid{:}] = ndgrid(size_{:});

grid = cellfun(@(x) x(:), grid, 'UniformOutput', false);

indices = cat(2, grid{:});
