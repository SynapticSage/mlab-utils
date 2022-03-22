function fields = fieldnames(Tcell, method)
% function fields = fieldintersect(Tcell)
% 
% Takes a cell of tables and returns the intersection
% of their fields

if nargin == 1
    method = "intersect";
end
    
if string(method) == "intersect"
    func = @intersect;
elseif string(method) == "union"
    func = @union;
else
    error("Unrecognized method");
end

if istable(Tcell{1})
    fnames = @(x) setdiff(fieldnames(x), {'Properties', 'Row', 'Variables'});
else
    fnames = @fieldnames
end

for i = 1:numel(Tcell)
    if i == 1
        fields = fnames(Tcell{i});
    else
        fields = func(fields, fnames(Tcell{i}));
    end
end
