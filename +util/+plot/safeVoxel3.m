function safeVoxel3(varargin)
% safe version of the voxel plotting program



varargin{1}(isnan(varargin{1})) = 0;
varargin{1} = double(gather(varargin{1}));
voxel3(varargin{:});
