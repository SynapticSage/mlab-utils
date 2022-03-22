function T = unsplit(T, varargin{:})
% Undoes the operation of util.table.split(T) over dimension dim
%
% This is in essence a wrapper for util.table.icat (insensitive cancatonate)

T = util.table.icat(T, varargin{:});
