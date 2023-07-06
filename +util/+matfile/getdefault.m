function out = getdefault(m, var, def)
% GETDEFAULT  Get a variable from a structure, or a default value if it doesn't exist.
% OUT = GETDEFAULT(M, VAR, DEF) returns M.VAR if it exists, otherwise DEF.
% Analagous to setdefault in Python.
%
% Input:
%   m   matlab.io.MatFile
%   var string

if isprop(m, var)
    out = m.(var);
else
    out = def;
end
