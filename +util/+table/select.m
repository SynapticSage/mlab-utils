function T = select(T, varargin);
%function T = select(T, varargin);
% 
% More general version of T(stuff, stuff)
%
% If columns are not present, they are created de novo
% with nan values.

if numel(varargin) == 1
    fields = varargin{1};
    rows = ':';
elseif numel(varargin) == 2
    fields = varargin{2};
    rows = varargin{1};
else
    error("Too many arguments");
end

fields_not_present = setdiff(fields, fieldnames(T));
if ~isempty(fields_not_present)
    for field = string(fields_not_present(:))'
        T.(field) = nan(height(T), 1);
    end
end

T = T(rows, fields);
