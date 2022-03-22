function [I, dups] = getduplicates(T, dupfield, context)
% Show duplicates in the table
%
% Inputs
% ------
% T : table
% dupfield : string char cellstr
%   Field that might have dups
%
% Currently works only with numeric dupfield
%
% Returns
% -------
% I : indices to duplicates with context
% dups : (optional) if requeested, the original table with duplicates. in memory intense cases, do not provide this and it will not be generated.

if nargin < 3
    context = [0, 1];
end
if nargin < 2
    dupfield = 1;
end

T = sortrows(T, dupfield);
if istable(T)
    nonunique = [0; diff(T.(dupfield))==0];
elseif isnumeric(T)
    if isrow(T)
        T = T(:);
    end
    nonunique = [0; diff(T(:,dupfield))==0];
else
    error("Unsupported type")
end
ind = find(nonunique);
I = zeros(numel(ind), context(2)-context(1)+1);
C = context(1):context(2);
for c = 1:numel(C)
    I(:, c) = ind + C(c);
end

I = I';
I = I(:);

if nargout == 2
    dups = T(I,:);
end
