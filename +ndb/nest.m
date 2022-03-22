function obj = nest(obj, fields, nestfield, varargin)
% Performs the nd.nest operation on every struuct in the ndbranched cell

ip = inputParser;
ip.addParameter('indices',[]);
ip.parse(varargin{:});
Opt = ip.Results;

if ~isempty(Opt.indices)
    m = size(Opt.indices,2);
end

indices = ndBranch.indicesMatrixForm(obj);
for index = indices'
    if ~isempty(Opt.indices) && ~ismember(index(1:m)', Opt.indices, 'rows')
       continue 
    end
    O = ndBranch.get(obj, index);
    O = nd.nest(O, fields, nestfield);
    obj = ndBranch.set(obj, index, O);
end
