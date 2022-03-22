function type_ = type(x)
% Returns the type of the ndbranch object leaf elements
indices = ndBranch.indicesMatrixForm(x);
val = ndBranch.get(x, indices(1,:));
type_ = class(val);
