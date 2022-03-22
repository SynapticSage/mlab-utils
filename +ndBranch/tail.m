function X =tail(X)
indices = ndBranch.indicesMatrixForm(X);
X = ndBranch.get(X, indices(end,:));
