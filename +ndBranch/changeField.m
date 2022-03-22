function X = changeField(X, field, newfield, varargin)

ip = inputParser;
ip.addParameter('indices',[]);
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
    x.(newfield) = x.(field);
    x = rmfield(x,field);
    X =  ndb.set(X, index, x);
end

