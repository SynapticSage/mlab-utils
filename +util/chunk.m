function X= chunk(X, i, I)
% Return the ith chunk of I chunks

if isrow(X)
    X = X';
end

L  =  size(X,1);

chunkSize = round(L/I);
inds = ((i-1)*chunkSize+1) : min((i*chunkSize), L);
X  = X(inds,:,:,:,:,:,:,:,:,:,:,:);
