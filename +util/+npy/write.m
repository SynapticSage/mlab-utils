function write(var, filename, varargin)
% function writeNPY(var, filename)
%
% Only writes little endian, fortran (column-major) ordering; only writes
% with NPY version number 1.0.
%
% Always outputs a shape according to matlab's convention, e.g. (10, 1)
% rather than (10,).
%
% modified by ryan y to be able to shape and cast variables
% before porting to numpy. some npy driven functions require
% things to be a certain shape.

ip = inputParser;
ip.addParameter('dim', []);
ip.addParameter('cast', []);
ip.parse(varargin{:})
Opt = ip.Results;

if ~isempty(Opt.cast)
    var = cast(var, Opt.cast);
end

shape = size(var);
if ~isempty(Opt.dim)
    shape = shape(1:Opt.dim);
end
dataType = class(var);

header = util.npy.constructheader(dataType, shape);

fid = fopen(filename, 'w');
fwrite(fid, header, 'uint8');
fwrite(fid, var, dataType);
fclose(fid);
