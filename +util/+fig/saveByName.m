function saveByName(savedir, varargin)
% saves every figure open by it's name

ip = inputParser;
ip.addParameter('append',  "");
ip.addParameter('prepend', "");
ip.addParameter('close', false);
ip.addParameter('as', ["svg","png"]);
ip.addParameter('screenSize', []);
ip.parse(varargin{:})
Opt = ip.Results;

% Make sure string
Opt.append = string(Opt.append);
Opt.prepend = string(Opt.prepend);
Opt.as = string(Opt.as);

% Iterate over all avail figures
figs = findobj('type','figure');
for fig = figs(:)'
    filename = fullfile(savedir, Opt.prepend + fig.Name + Opt.append);
    if ~isempty(Opt.screenSize)
        screenSize = get(0, 'screenSize');
        if isscalar(Opt.screenSize)
            screenSize = screenSize .* [1 ,1 , Opt.screenSize, Opt.screenSize];
        else
            screenSize = screenSize .* [1, 1, Opt.screenSize];
        end
        set(fig, 'Position', screenSize);
    end
    for as = Opt.as
        saveas(fig, filename, as);
    end
    if Opt.close
        close(fig);
    end
end
