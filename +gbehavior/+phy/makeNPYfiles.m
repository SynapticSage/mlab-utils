function makeNPYfiles(animal, index, beh, varargin)
% Adds behaviors to phy so we can see behavioral content of spikes during
% clustering/curating spikes

ip = inputParser;
ip.addParameter('replace', {}); % string
ip.addParameter('match', []); % string
ip.parse(varargin{:})
Opt = ip.Results;


msfolder   = dirLib.mountainsort(animal, index, Opt);
tetfolders = dirLib.mountainsortTets(animal, index ,Opt);

% Acquire the times
timefile = dir(fullfile(msfolder, '*time*mda*'));
timefile = timefile(1);
timefile = fullfile(msfolder, timefile.name);
if contains(timefile, 'prv')
    json = loadjson(timefile);
    mdatime = readmda(json.original_path);
else
    mdatime = readmda(timefile);
end


disp("Folders")
disp("-")
disp(tetfolders')

for tetfolder = progress(tetfolders, 'Title', 'Adding behaviors')

    if ~isempty(Opt.match) && ~contains(tetfolder, Opt.match)
        continue
    end

    path2phy        = fullfile(tetfolder, 'phy');
    spiketimesfiles = fullfile(path2phy, 'spike_times.npy');
    if ~exist(spiketimesfiles, 'file')
        warning('File %s does not exist', spiketimesfiles)
        continue
    end
    spikeinds       = readNPY(spiketimesfiles);
    spiketimes      = mdatime(spikeinds(:))/30e3;
    spikes.spikeTimes = {spiketimes};
    spikes = units.atBehavior(beh, spikes,...
        'violationHandling','nan');
    %spikes.beh = spikes.beh{1};
    height(spikes.beh), numel(spikeinds)
    assert(height(spikes.beh) == numel(spikeinds), ...
        'why spike times not the same?!');

    % Behaviors
    vars1d = gbehavior.phy.vars1d(beh);
    vars2d = gbehavior.phy.vars2d(beh);

    for var1d = progress(vars1d(:)', 'Title', '1d vars')
        gbehavior.phy.atomicNPYfile(spikes.beh, var1d, path2phy);
    end

    for var2d = progress(vars2d', 'Title', '2d vars')
        gbehavior.phy.atomicNPYfile(spikes.beh, var2d, path2phy);
    end

    % Augment with LFP details? We need to capture idealized LFP first
end
