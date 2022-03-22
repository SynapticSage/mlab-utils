function X = apply(X, varargin)
% Applies a funciton iteratively over an nd struct type

%Other inputs
listOutput = cellfun(@(x) isequal(x, "outputList"), varargin);
if any(listOutput)
    varargin(listOutput) = [];
    listOutput = true;
else
    listOutput = false;
end

ignoreEmpty = true;
field = "";
lambda = [];
if numel(varargin) == 1
    lambda = varargin{1};
    varargin(1) = [];
elseif numel(varargin) == 2
    field = string(varargin{1});
    lambda = varargin{2};
    varargin(1:2) = []
end
allowLambdaFail = false;
varargin = optlistassign(who, varargin{:});

assert(~isempty(lambda));

% Ensure the any new fields put into the structure
if contains(field, "-")
    split = strsplit(field, "-");
    to = split(1);
    from = split(2);
    X(1,1,1).(to) = []; 
end

inds = ndb.indicesMatrixForm(X);
output = cell(size(inds,1),1);
counter = 0;
for ind = inds'

    counter = counter + 1;
    x = ndb.get(X, ind);

    if ignoreEmpty && nd.isEmpty(x)
        continue
    end

    if field == "*" % ALL FIELD APPLY
        for f = string(fieldnames(x))'
            if allowLambdaFail
                try
                x.(f) = lambda(x.(f));
                catch 
                end
            else
                x.(f) = lambda(x.(f));
            end
        end
    elseif contains(field, "-") % NEW VAR ASSIGN MODE
        split = strsplit(field, "-");
        to = split(1);
        from = split(2);
        x.(to) = lambda(x.(from));
    elseif strlength(field) % SINGLE FIELD APPPLY
        x.(field) = lambda(x.(field));
    else % WHOLE STRUCT FUNCTION
        x = lambda(x);
    end

    if listOutput
        output{counter} = x;
    else
        X = ndb.set(X, ind, x);
    end
    
end

if listOutput
    X = output;
end
