function results = fieldMean(results, axisField, axisFieldBins)
%Generates mean over axis field or in bins of the axisField

sizes = structfun(results(1));
axisField_dimNum = find(results(1).(axisField) ~= 1);

if 

function binMeans = returnBins(D, bins)
    binMeans = zeros(size(D,1), size(bins,1));
    for b = 1:size(bins,1)
        binMeans(:,b) = mean(D(:, ...
            result.(axisField)(:) >= bins(b,1) & ...
            result.(axisField)(:) <= bins(b,2)),2);
    end
