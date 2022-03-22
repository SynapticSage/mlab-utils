function S = appendgroupfield(S, gstruct, g, varargin)
% function S = appendgroupfield(S, gstruct, g)
% 
%
% Appends group fields from util.table.findgroups to a struct

ip = inputParser;
ip.addParameter('directassign', false); % Whether to directly assign findgroup struct items when g not given
ip.parse(varargin{:})
Opt = ip.Results;

if nargin < 3
    if ~Opt.directassign
        assignStruct.findgroups = gstruct;
    else
        assignStruct = gstruct;
    end
    if isscalar(S)
        S = util.struct.update(S, assignStruct); % PLace the entire set of gstruct elements in there as a description
    elseif numel(S) == numel(gstruct.uGroups)
        for g = gstruct.uGroups'
            S = util.struct.update(S.findgroups, assignStruct, @(x) x(g)); % Iteratively describe them
        end
    else
        error("Unexpected inputs or unimplemented condition: see code for allowed conditions");
    end
else
    S = util.struct.update(S, gstruct.group.field, @(x) x(g));
end
