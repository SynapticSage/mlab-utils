function X = head(X)
indices = ndBranch.indicesMatrixForm(X);
X = ndBranch.get(X, indices(1,:));
