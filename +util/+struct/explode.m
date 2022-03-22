function X = explode(X, field, varargin)
% Explodes a matrix field out into the struct column-wise

ip = inputParser;
ip.addParameter('columnLimit', []);
ip.addParameter('removePrevVar', true);
ip.parse(varargin{:})
Opt = ip.Results;

x = X.(field);
szx = size(x,2);
if ~isempty(Opt.columnLimit)
    x = x(:,1:min(szx, Opt.columnLimit));
end
for i = 1:size(x,2)
    X.(field + "_" + i) = x(:,i);
end
if Opt.removePrevVar
    X = rmfield(X, field);
end
