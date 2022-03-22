function Tnew = icat(Tcell, varargin)
% T = function icat(Tcell)
%
%
% Tcell : a cell of tables
%
% A field insensitive version of cat() that's immune to differences in
% field number --- for cating cells of table or cells of struct
%
% Sort of a very bootleg, feature-lax subsitute for some aspects of 
% pandas table merge/join
%
% Method will either concatonate only the fields that match for all
% tables (intersect) or concatonate all fields, including unmatched
% (union), where tables that lack a field have those missing fields as
% nan.
%

if numel(Tcell)==1
    Tnew = Tcell{1};
    return
end

dim = [];
if ~isempty(varargin) && isnumeric(varargin{1})
    dim = varargin{1};
    varargin(1) = [];
end

ip = inputParser;
ip.addParameter('fieldCombine', 'intersect');
ip.addParameter('removeEmpty', false);
ip.addParameter('pack', false);
ip.addParameter('verbose', false);
ip.parse(varargin{:})
Opt = ip.Results;


if isempty(dim)

    if Opt.removeEmpty
        Tcell = util.cell.removeEmpty(Tcell);
    end

    fields = util.cell.fieldnames(Tcell, Opt.fieldCombine);
    Tcell = cellfun(@(x) util.table.select(x, fields), Tcell, 'UniformOutput', false);
    Tcell = util.table.fastRowCat(Tcell);
    Tnew  = Tcell;

else

    inds = nd.indicesMatrixForm(Tcell);
    inds = unique(inds(:, setdiff(1:ndims(inds), dim)), 'rows');
    inds = num2cell(inds);
    insert = @(x, n) cat(2, x(:,1:(n-1)), repmat({':'}, size(x,1),1), x(:,n:end));
    inds = insert(inds, dim);
    indsNew = inds;
    indsNew(:,dim) = [];
    Tnew = {};
    if Opt.verbose
        II = progress(1:size(inds,1), 'Title', sprintf('Concat over dim=%d', dim));
    else
        II = 1:size(inds,1);
    end
    for ii = II
        ind  = inds(ii,:);
        indNew = indsNew(ii,:);
        Tnew{indNew{:}} = util.cell.icat(Tcell(ind{:}), Opt);
        [Tcell{ind{:}}] = deal([]);
    end
end

%if Opt.pack
%    pack;
%end
