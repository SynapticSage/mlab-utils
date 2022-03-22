function out = fieldGet(X, field, varargin)
% Gets a single field from the nd struct, and stores it into a cell in the same nd shape

ip = inputParser;
ip.addParameter('shiftdim', []);
ip.parse(varargin{:})
Opt = ip.Results;

out = cell(size(X));
indices = nd.indicesMatrixForm(X);
for index = indices'
    I = num2cell(index);
    if ~isempty(Opt.shiftdim)
        out{ I{:} } = shiftdim(X( I{:} ).(field), Opt.shiftdim);
    else
        out{ I{:} } = X( I{:} ).(field);
    end
end
