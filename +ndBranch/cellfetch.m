function varargrout = cellfetch(x, fields, varargin)
% like cellfetch, but can fetch multiple fields, and returns outputs in
% varargout intead of within a struct

assert(isstring(fields) ||  ischar(fields)  || iscellstr(fields),...
    'Error: fields must be char, strings, or cell of char');
fields  = string(fields);

indices = ndBranch.indicesMatrixForm(x);
varargout = arrayfun(@(x) cell(1,size(indices,1)), 1:numel(fields), ...
    'UniformOutput', false)

icnt = 0;
for index = indices'

    icnt = icnt + 1;
    y = ndBranch.get(x, index);

    % Grab each field
    fcount = 0;
    for field = fields(:)'
        fcount = fcount + 1;

        varargout{fcount}{icnt} = y.(field);
        
    end
end

varargout{end+1} = indices;
