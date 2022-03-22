function S = uniqueNonNan(X)
%reeturns unique non nan entries

S = unique(X(~isnan(X)));
