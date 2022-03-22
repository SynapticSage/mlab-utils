function [obj, fields] = unnest(obj, nestfield, fields, varargin)
% Performs the nd.nest operation on every struuct in the ndbranched cell

ip = inputParser;
ip.addParameter('indices',[]);
ip.parse(varargin{:});
Opt = ip.Results;

if ~isempty(Opt.indices)
    m = size(Opt.indices,2);
end
if nargin < 3
    fields = [];
end


indices = ndBranch.indicesMatrixForm(obj);
cnt = 0;
F={};
for index = indices'
    if ~isempty(Opt.indices) && ...
       ~ismember(index(1:m)', Opt.indices, 'rows')
       continue 
    end
    cnt  = cnt+1;
    O = ndBranch.get(obj, index);
    [O, F{cnt}] = nd.unnest(O, nestfield, fields);
    F{cnt} = string(F{cnt});
    obj = ndBranch.set(obj, index, O);
end

fields = unique([F{:}]);
