function out = fieldGet(X, field, varargin)
% Gets a single field from the nd struct, and stores it into a cell in the same
% nd shape
%
% out = fieldGet(X, field, varargin)
%
% Inputs:
%   X: nd struct
%   field: field name
%   varargin: options
%       squeeze: if true, squeeze the output
%       cat: if not empty, cat the output along this dimension
%
% Output:
%   out: cell array of the field values

ip = inputParser;
ip.addParameter('squeeze', false);
ip.addParameter('cat', []);
ip.parse(varargin{:})
Opt = ip.Results;

if ischar(field) || numel(field) == 1
    outersize = size(X);
    innersize = size(X(1).(field));

    out = cell(outersize);
    nInner = numel(innersize);
    nOuter = numel(outersize);

    indices = nd.indicesMatrixForm(X);
    for index = indices'
        I = num2cell(index);
        out{ I{:} } = shiftdim(X( I{:} ).(field), -nInner);
    end

    try
        out = cat(1, out{:});
        out = reshape(out, [outersize, innersize]);
    catch ME
    end
else
    out = cell(1,numel(field));
    fcount = 0;
    for f = string(field(:))'
        fcount = fcount + 1;
        out{fcount} = nd.fieldGet(X, f);
    end
end

if iscell(out) && Opt.squeeze
    out = cellfun(@squeeze, out, 'UniformOutput', false);
end
if iscell(out) && ~isempty(Opt.cat)
    out = cat(Opt.cat, out{:});
end
