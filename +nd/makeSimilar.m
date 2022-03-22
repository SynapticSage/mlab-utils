function [varargout] = makeSimilar(varargin)
% Make two dissimilar structure nd arrays similar

% Meat and potatoes pairwise interaction
if numel(varargin) == 2
    fields1 = string(fieldnames(varargin{1}));
    fields2 = string(fieldnames(varargin{2}));

    field_diff1 = setdiff(fields1, fields2);
    field_diff2 = setdiff(fields2, fields1);
    empty1 = nd.emptyLike(varargin{1});
    empty2 = nd.emptyLike(varargin{2});

    % Set missing fields in each
    for field = field_diff1
        varargin{2}.(field) = varargin{1}.(field);
    end
    
    for field = field_diff2
        varargin{1}.(field) = varargin{2}.(field);
    end
    
else
    % If more than 2, do pairwise recursively
    for i = 1:numel(varargin)
        for j = i:numel(varargin)
            [varargin{i}, varargin{j}] = ...
                nd.makeSimilar(varargin{i}, varargin{j});
        end
    end
end

for i = 1:numel(varargin)
    varargout{i} = varargin{i};
end
