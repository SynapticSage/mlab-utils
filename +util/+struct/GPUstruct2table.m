function T = GPUstruct2table(T, varargin)
% Converts a table into a gpuarray struct
%

ip = inputParser;
ip.addParameter('cast', []);
ip.parse(varargin{:})
Opt = ip.Results;

T = util.struct.GPUstruct2struct(T, Opt);
T = struct2table(T);
