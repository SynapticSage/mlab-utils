function C = flexibleColumnCat(A,B)
% flexibleColumnCat(A,B)
%
% concatonates even if two tables have shared column

% get the shared column names
sharedCols = intersect(A.Properties.VariableNames, B.Properties.VariableNames);
B = B(:,~ismember(B.Properties.VariableNames,sharedCols));
C = [A B];
