function X = flexset(X, ind, x)
% Flexible version of nd.set
% Solves the issue of struct X and x being dissimilar

if ~iscell(ind)
    ind = num2cell(ind);
end

fnX = string(fieldnames(X));
fnx = string(fieldnames(x));

missingX = setdiff(fnx, fnX);
missingx = setdiff(fnx, fnX);

for field = missingX(:)'
    X(1).(field) = [];
end
for field = missingx(:)'
    x(1).(field) = [];
end

X(ind{:}) = x;
