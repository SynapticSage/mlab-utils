function answer = isEmpty(x, deep)
% Returns whether I consider a struct in the nd struct empty
%
%   answer = nd.isEmpty(x)
%   answer = nd.isEmpty(x, deep)
%

if nargin == 1
    deep = true;
end

%answer = isempty(x) || all(structfun(@(y) check(y), x,'UniformOutput',true));

%function answer = check(y)
if isnumeric(x) 
    answer = all(isnan(x),'all') || isempty(x);
elseif iscell(x)                
    if deep
        answer = all(cellfun(@nd.isEmpty, x, 'UniformOutput', true), 'all');
    else
        answer = isempty(x);
    end
elseif isstring(x)                
    answer = all(ismissing(x),'all') || isempty(x);
elseif ischar(x)                  
    answer = all(isnan(x),'all') || isempty(x);
elseif isstruct(x)
    if  numel(x) == 1
        if deep
            answer = all(structfun(@nd.isEmpty, x, 'uniformoutput', true));
        else
            answer = all(structfun(@(y) nd.isEmpty(y,false), x, 'uniformoutput', true));
        end
    else
        %answer = all(arrayfun(@(y) nd.isEmpty(y,false), x, 'uniformoutput', true));
        inds = nd.indicesMatrixForm(x);
        answer = true;
        for ind = inds'
            if ~nd.isEmpty(nd.get(x, ind), deep)
                answer = false;
            end
        end
    end
elseif istable(x)
    answer = height(x) == 0 || width(x) == 0;
else
    answer = false;
end
    
