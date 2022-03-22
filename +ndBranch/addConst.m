function X = addConst(X, field, value, varargin)

ip = inputParser;
ip.addParameter('indices',[]);
ip.addParameter('addToExisting',false);
ip.parse(varargin{:});
Opt = ip.Results;


indices = ndb.indicesMatrixForm(X);
if ~isempty(Opt.indices)
    m = min(size(Opt.indices,2),size(indices,2));
end

for index = indices'
    if ~isempty(Opt.indices) && ~ismember(index(1:m)', Opt.indices, 'rows')
       continue 
    end
    x = ndb.get(X, index);
    if Opt.addToExisting && isfield(x, field)
        x.(field) = x.(field) + value;
    else
        x.(field) = value;
    end
    X =  ndb.set(X, index, x);
end
