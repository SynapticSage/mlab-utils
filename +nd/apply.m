function X = apply(X, varargin)
% function X = apply(X, varargin)
% Applies a funciton iteratively over an nd struct type
%
% Inputs:
% X - nd struct
% lambda - function to apply (if 2 args, this is the second arg; if 2+ args, this is the third arg)
% fieldmethod - how to apply the function to the fields of the struct (if 2+ args, this is the second arg)
% varargin - optional arguments
%
% The function can optionally be put into a recursive mode by "**"
%
% In recursive mode, it can optionally also dive into cells looking for elements to
% apply the lambda to via a recurseCell=true name-value argument.
%
% if function is not struct/cell, it will instead just directly apply the lambda function to it
%
% fieldmethod = "*" apply lambda to all fields without recursing
% fieldmethod = "**" all fields and recursively apply if encounter an ndstruct
% fieldmethod = set of fields, only apply to those fields
% fieldmethod = x"-"y , apply to x and title the new result y
% fieldmethod = x1,x2,x3,...,xn"-"y , apply to set of fields and title the new result y
%
% if fieldmethod is empty, then the lambda is applied to the entire struct
%

ignoreEmpty = true;
fieldmethod = "";
lambda = [];

V = varargin;
varg1_mode = numel(varargin) == 1;
if varg1_mode
    lambda = varargin{1};
    varargin(1) = [];
elseif numel(varargin) >= 2
    fieldmethod = string(varargin{1});
    lambda = varargin{2};
    varargin(1:2) = [];
end
recurseCell = false;
allowLambdaFail = false;
varargin = optlistassign(who, varargin{:});

assert(~isempty(lambda));

% Ensure the any new fields put into the structure
if contains(fieldmethod, "-")
    split = strsplit(fieldmethod, "-");
    to = split(1);
    from = split(2);
    X(1,1,1).(to) = []; 
end

if isstruct(X) || iscell(X)
    inds = nd.indicesMatrixForm(X);
    for ind = progress(inds', 'Title', 'apply')

        x = nd.get(X, ind);

        if ignoreEmpty && nd.isEmpty(x)
            continue
        end

        if fieldmethod == "*" || fieldmethod == "**" % ALL FIELD APPLY
            for f = string(fieldnames(x))'
                if fieldmethod == "**" && isstruct(x.(f))
                    L = @(x) nd.apply(x, V{:});
                elseif fieldmethod == "**" && recurseCell && iscell(x.(f))
                    L = @(x) cellfun(@(xx) nd.apply(xx, V{:}), x, 'UniformOutput', false);
                else
                    L = lambda;
                end
                if allowLambdaFail
                    try
                    x.(f) = L(x.(f));
                    catch 
                    end
                else
                    x.(f) = L(x.(f));
                end
            end
        elseif contains(fieldmethod, "-") % NEW VAR ASSIGN MODE
            split = strsplit(fieldmethod, "-");
            to = split(1);
            if contains(from, ",")
                from = split(2);
                from = strsplit(from, ",");
                x.(to) = lambda(x(:,from));
            else
                from = split(2);
                x.(to) = lambda(x.(from));
            end
        elseif strlength(fieldmethod) % SINGLE FIELD APPPLY
            x.(fieldmethod) = lambda(x.(fieldmethod));
        else % WHOLE STRUCT FUNCTION
            x = lambda(x);
        end

        X = nd.set(X, ind, x);
        
    end
else
    X = lambda(X);
end
