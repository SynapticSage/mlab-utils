function A = merge(A,B, varargin)
% Merge two structs with different fields but the same ND shape into one
% struct with all fields. The fields of A take precedence over the fields
% of B.
%
% Example:
%   A = struct('a',1,'b',2);
%   B = struct('b',3,'c',4);
%   A = repmat(A, [1,2]);
%   B = repmat(B, [2,1]);
%   C = merge(A,B);
%   size(C) % [2,2]
%   C(1,1) % struct('a',1,'b',2,'c',4)
%   C(1,2) % struct('a',1,'b',3,'c',4)

ip = inputParser();
ip.addParameter('ignore', {}, @(x) iscellstr(x) || isstring(x));
ip.addParameter('only', {},   @(x) iscellstr(x) || isstring(x) || ischar(x));
ip.addParameter('broadcastLike', false, @islogical);
ip.addParameter('overwrite',     false, @islogical);
ip.parse(varargin{:});
Opts = ip.Results;

if Opts.broadcastLike
    [A,B] = nd.broadcastLike(A,B);
end
assert(all(size(A)==size(B)));

indices = nd.indicesMatrixForm(A);
for index = indices'
    I = num2cell(index);
    fields = string(fieldnames(B(I{:})))';
    if ~isempty(Opts.only)
        fields = intersect(fields, Opts.only);
    elseif ~isempty(Opts.ignore)
        fields = setdiff(fields, Opts.ignore);
    end
    for field = fields
        if  Opts.overwrite || ~isfield(A(I{:}),field)
            A(I{:}).(field) = B(I{:}).(field);
        end
    end
end
