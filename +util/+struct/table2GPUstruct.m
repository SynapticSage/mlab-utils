function T = table2GPUstruct(T, varargin)
% Converts a table into a gpuarray struct

ip = inputParser;
ip.addParameter('cast', []);
ip.parse(varargin{:})
Opt = ip.Results;

disp('Converting to table');
T = table2struct(T, 'toScalar', true);
disp('Converting struct to GPU');
T = util.struct.struct2GPUstruct(T, Opt);
