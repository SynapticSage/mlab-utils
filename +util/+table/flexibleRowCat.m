function C = flexibleRowCat(A,B)
% flexibleRowCat(A,B) concatenates two tables A and B
% in such a way that they are allowed to have different
% numbers of columns. The output table C will have the
% all columns of A and B

varsA = A.Properties.VariableNames;
varsB = B.Properties.VariableNames;

% Add the variables in A but not in B
vars = setdiff(varsA,varsB);
if ~isempty(vars)
    % pad out the missing variables in B with NaNs
    B = [array2table(nan(height(B),length(vars)),'VariableNames',vars) B];
end


% Add the variables in B but not in A
if ~isempty(varsB)
    % pad out the missing variables in A with NaNs
    A = [array2table(nan(height(A),length(varsB)),'VariableNames',varsB) A];
end

% get the intersection of the variables in A and B
vars = intersect(varsA,varsB);

% Create C by concatenating the intersection of A and B
C = [A(:,vars);B(:,vars)];
