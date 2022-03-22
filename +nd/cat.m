function Y = cat(X, innerdims, outerdims, varargin)
% Merge each matching field along inner dimensions (dimensions of fields in a
% struct) along the outer dimensions of X

ip = inputParser;
ip.addParameter('removeEmpty', false);
ip.parse(varargin{:});
opt = ip.Results;

if iscell(X)
    X = ndb.toNd(X);
end
indices = nd.indicesMatrixForm(X);

if nargin > 2 && ~isempty(outerdims)
    I = num2cell(indices, 2);
    G = findgroups(I{outerdims});
else
    G = ones(size(indices,1),1);
    outerdims = [];
end
uG = unique(G);
emptyArchetype = nd.emptyLike(X(1));

for g = uG'
    filt = G == g;
    I = indices(filt,:);
    M = emptyArchetype;
    for index = indices' % Indices to merge along
        index = num2cell(index);
        cat_this = X(index{:});
        if opt.removeEmpty && nd.isEmpty(cat_this)
            continue
        end
        M = cat_struct(M, cat_this, innerdims);
    end
    if isempty(outerdims)
        new_index={1};
    else
        new_index = index;
        new_index(outerdims) = [];
    end
    Y(new_index{:}) = M;
end

function c = cat_struct(a,b, innerdims)
    % Concatonatese fields of two structs along innerdims
    c = struct();
    for field = string(fieldnames(a))'
        try
            c.(field) = cat(innerdims, a.(field), b.(field));
        catch Exception
            c.(field) = [];
        end
    end
