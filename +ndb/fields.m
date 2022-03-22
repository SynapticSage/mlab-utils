function F = fields(x)
% Acquire fields of the leaf node

indices = ndBranch.indicesMatrixForm(x);
F = fields(ndBranch.get(x, indices(1,:)));
