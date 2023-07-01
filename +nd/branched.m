function results = branched(X)
% Converts an nd struct to a branched nd struct
%
% results = branched(X)
%
% This function converts an nd struct to a branched nd struct. This is
% useful for when you want to convert an nd struct to a cell array, but
% still want to keep the structure of the nd struct.
%
% Input variables:
%
%   X:      nd struct
%
% Output variables:
%
%   results:    branched nd struct


ndim = ndims(X);

results = {};
indices = nd.indicesMatrixForm(X);

if ~exist('progress.m','file')
    progress = @(x, y, z) x;
else
    progress = @progress;
end

for index = progress(indices','Title','Branching')

    % Grab the value
    I = num2cell(index);
    value = X( I{:} );

    % If we have a value to add the branched cell
    if ~nd.isEmpty(value)

        % Forward/Copy phase
        branch = {};
        branch{1} = results;
        for dim = 1:ndim

            % Make space if not avail
            if numel(branch{dim})  < index(dim)
                if dim < ndim
                    branch{dim}{ index(dim) } = {};
                else
                    branch{dim}{ index(dim) } = [];
                end
            end

            branch{dim+1} = branch{dim}{ index(dim) };
        end

        % Insertion phase
        branch{dim+1} = value;

        % Backup phase
        for dim = ndim:-1:1
           branch{dim}{ index(dim) } =  branch{dim+1}; 
        end

        % Assign
        results = branch{1};
    end

end


%function answer = sIsempty(x)
%answer = all(structfun(@(y) check(y), x,'UniformOutput',true));
%function answer = check(y)
%if isnumeric(y)
%    answer = all(isnan(y),'all') || isempty(y);
%elseif isstring(y)                
%    answer = all(ismissing(y),'all') || isempty(y);
%elseif ischar(y)                  
%    answer = all(isnan(y),'all') || isempty(y);
%else
%    answer = false;
%end
%    
