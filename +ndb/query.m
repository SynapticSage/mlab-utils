function S = query(S, filt)
% function query(S, filt)
% filters an ndb struvcture with filt logical

indices = ndb.indicesMatrixForm(S);
notInSet = ~filt;

for ind = indices(notInSet, :)'
    S = ndb.set(S, ind, []);
end
