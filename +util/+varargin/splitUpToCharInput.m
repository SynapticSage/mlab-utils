function [V1, V2] = splitUpToCharInput(V)

loc = util.varargin.charPosition(V);
V1 = V(1:loc-1);
V2 = V(loc:end);
