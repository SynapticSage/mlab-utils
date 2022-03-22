function X = toTidy(X, varargin)

indices = ndBranch.indicesMatrixForm(X);
type    = ndBranch.type(X);

switch type
    case 'struct'
        X = tidyData.fromNd(X, varargin{:});
    case 'cell'
        X = tidyData.fromNd(X, varargin{:});
    case 'table' % data that is already tabular at the leaves
        X = tidyData.fromNdBranch_tidy(X, varargin{:});
end
