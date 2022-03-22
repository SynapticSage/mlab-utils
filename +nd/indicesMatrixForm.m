function indices = indicesMatrixForm(obj)
%GETINDICES returns matrix form of indices of object

size_ = size(obj);
size_ = num2cell(size_);
size_ = cellfun(@(x) 1:x, size_, 'UniformOutput',false);

grid = cell(1, numel(size_));
[grid{:}] = ndgrid(size_{:});

grid = cellfun(@(x) x(:), grid, 'UniformOutput', false);

indices = cat(2, grid{:});
