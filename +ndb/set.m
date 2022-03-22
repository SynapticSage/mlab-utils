function obj = set(obj, index, value, varargin)
% function obj = set(obj, index, value, varargin)
% Set an nd branch at the address of index

ip = inputParser;
ip.addParameter('secure',true);
ip.parse(varargin{:});
opt = ip.Results;

I = index;

% More secure
if opt.secure
    objBuffer = {};
    while numel(I)>0
        [i,I] = popIndex(I);
        if i > numel(obj)
            obj{i} = [];
        end
        objBuffer = push(objBuffer, obj);
        obj = obj{i};
    end
    obj = value;

    cnt = 0;
    while numel(objBuffer) > 0
        i = index(end-cnt);
        [objNew, objBuffer] = pop(objBuffer);
        objNew{i} = obj;
        obj = objNew;
        cnt = cnt + 1;
    end
% Less secure
else
    index = string(index);
    index = "{" +  index + "}";
    index = join(index,"");
    strval = "obj" + index + "=value;";
    assert(all(contains(strval,["}","{"])));
    eval(strval) % security flaw: could be used to run arbitrary code
end

% --------------------Helper Functions------------------------
function [i,I] = popIndex(I)
i = I(1);
I = I(2:end);

function [V]   = push(V, v)
V{end+1} = v;

function [v,V]   = pop(V)
v =  V{end};
V(end) = [];
