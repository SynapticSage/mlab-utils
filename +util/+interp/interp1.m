function out = interp1(varargin)
% Calls matlab's interp1 but is more robust to typing
%  
% Matlab's interp1 requires double, but sometimes for space
% reasons, I'm using single. This just handles that smoothly.


isSingle = false(1,3);
for i = 1:3
    if ~isa(varargin{i}, 'double')
        isSingle(i) = true;
        varargin{i} = double(varargin{i});
    end
end

out = interp1(varargin{:});

if any(isSingle) && isa(out, 'double')
    out = util.type.castefficient(out, 'compressReals', true);
end
