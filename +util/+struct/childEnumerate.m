function fieldcollect = childEnumerate(S, varargin)
% Enumerate all child addresses of the struct

ip = inputParser;
ip.addParameter('appendSize', false);
ip.addParameter('appendClass', false);
ip.parse(varargin{:})
Opt = ip.Results;

fields = string(fieldnames(S));
fieldcollect = [];
for f = 1:numel(fields)
    if isstruct(S(1).(fields(f)))
        if Opt.appendClass
            cl = "<" + string(class(S)) + ">";
        else
            cl = "";
        end
        if Opt.appendSize
            sz = "[" + join(string(size(S)),",") + "]";
        else
            sz = "";
        end
        recursiveResult = fields(f) + cl + sz + "."  + util.struct.childEnumerate(S(1).(fields(f)), Opt)';
        fieldcollect = [fieldcollect; recursiveResult(:)];
    else
        item = S.(fields(f));
        if Opt.appendClass
            cl = "<" + string(class(item)) + ">";
        else
            cl = "";
        end
        if Opt.appendSize
            sz = "[" + join(string(size(item)), ",") + "]";
        else
            sz = "";
        end
        fieldcollect = [fieldcollect; fields(f) + cl + sz ];
    end
end

fieldcollect = fieldcollect(:);
