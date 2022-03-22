function  [outMat] =  circshift(vectToShift,shiftVector)
%This function generates a matrix where each row is a circshift of the
%original vector from the specified interval in the shiftVector;
%
%Inputs
%vectToShift:   is the original vector you want to circshift multiple times
%shiftVector:   is the vector of the circshift sizes;
%
%Outputs
%outMat:        is a matrix were every row is circshift by the amount in the
%               shiftVector

[n,m]=size(vectToShift);

if n == 1 && m == 1
    outMat = vectToShift;
    return
end

if n > m 
    % shifts the longest dimension
    inds=(1:n)';
    i = toeplitz(flipud(inds),circshift(inds,[1 0]));
    shiftVector = mod(shiftVector, size(i,1));
    shiftVector(shiftVector == 0) = size(i,1);
    outMat = vectToShift(i(shiftVector,:));
else
    inds=1:m;
    i=toeplitz(fliplr(inds),circshift(inds,[0 1]));
    shiftVector = mod(shiftVector, size(i,1));
    shiftVector(shiftVector == 0) = size(i,1);
    outMat=vectToShift(i(shiftVector,:));
end
