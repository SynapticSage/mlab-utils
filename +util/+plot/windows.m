function matlabGraphicsObjects = windows(windowList, varargin)
% Encapsulates what we repeatedly do with window-plotting. Useful to have
% as a function tool since we do this so often.

ip = inputParser;
ip.addParameter('ax',[])
ip.addParameter('ylim',[])
ip.addParameter('colormap',[])
ip.addParameter('varargin',{});
ip.parse(varargin{:})
opt = ip.Results;

if isempty(opt.ax)
    ax = gca;
else
    ax = opt.ax;
end

if isempty(opt.ylim)
    ylim = get(ax,'YLim');
else
    ylim = opt.ylim;
end

% Using patch() for speed of computing
% to see patch documentation, run
% `doc patch`

if ~isempty(opt.colormap)
    if ischar(opt.colormap) || isstring(opt.colormap)
        colors = cmocean(opt.colormap, size(windowList,1));
    else
        colors = opt.colormap;
        assert(size(colors,1) == size(windowList,1));
    end
    matlabGraphicsObjects = gobjects(size(windowList,1),1);
    for window = 1:size(windowList,1);
        matlabGraphicsObjects(window) = util.plot.windows(windowList(window,:), 'ylim', ylim, 'ax', ax, 'varargin', {'FaceColor', colors(window,:), opt.varargin{:}});
    end
else
    % Generate vertices
    Y = repmat([ylim(1) ylim(2) ylim(2) ylim(1)], 1, size(windowList,1));
    Y = Y';
    X = repelem(windowList, 1, 2);
    X = X';
    X = X(:);
    vertices = [X, Y]; % list of xy points used to draw windows

    % Link vertices into faces (windows)
    faces = 1:size(vertices,1);
    faces = reshape(faces, 4, [])'; % each row specifies which vertices are linked into a face object (dots that are connected to make a shape)

    matlabGraphicsObjects = patch(ax,'faces', faces, 'vertices', vertices, opt.varargin{:});
end
