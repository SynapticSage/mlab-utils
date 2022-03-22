function [result, status] = rawpull(animal, dayDir, varargin)
% Pushes to a machine with rsync

ip = inputParser;
ip.KeepUnmatched = true;
ip.addParameter('local', []);
ip.addParameter('remote', []);
ip.addParameter('test', false);
ip.addParameter('ext_exclusions', ["mp4", "h264", "raw", "rec"]);
ip.addParameter('exclude_pulls',  ["rawmda","raw.LFP"]);
ip.addParameter('add_pull_excludes',  []);
ip.addParameter('mountainsort', true);
ip.addParameter('sessionNum', [])
ip.parse(varargin{:});
Opt = ip.Results;

if isempty(Opt.local)
    error("Please provide local machine name");
end
if isempty(Opt.remote)
    error("Please provide remote machine name");
end
if Opt.test
    Opt.test = "--dry-run";
else
    Opt.test = [];
end

% Build remote folder string
from = rawdef(animal, 'machine', Opt.remote) + filesep + dayDir;
% Build local folder string
to   = rawdef(animal, 'machine', Opt.local) + filesep;

% Build the exclusion list
if ~isempty(Opt.ext_exclusions)
    Opt.ext_exclusions = "--exclude ""*." + Opt.ext_exclusions + """";
end

% Build rsync phrase
exclusions = "--exclude ""*." + [Opt.exclude_pulls, Opt.add_pull_excludes] + """";
phrase  = ["rsync --progress -avuL", Opt.test, Opt.ext_exclusions, exclusions, from, to];
phrase = join(phrase, " ");


% Hopefully this executes displaying text as it runs
disp(phrase);
[status, result] = system(phrase, '-echo');

% Handle mountainsort files
if Opt.mountainsort
    if isempty(Opt.sessionNum)
        error("pulling mountainsort requires a session number");
    end
    animalfolder = animaldef(animal);
    from = fullfile(rawdef(animal, 'machine', Opt.remote), '..', animal + "_direct", 'MountainSort', animal + "_" + Opt.sessionNum + ".mountain").replace([filesep, filesep], filesep);
    to = (string(animalfolder{2}) + filesep + "MountainSort" + filesep);
    to = replace(to, [filesep, filesep], filesep);
    exclusions = "--exclude ""*." + [Opt.exclude_pulls, Opt.add_pull_excludes] + """";
    phrase = ["rsync -avuL ", Opt.test, exclusions, from, to];
    phrase = join(phrase, " ");
    disp(phrase);
    [msstatus, msresult] = system(phrase,'-echo');
    %disp(msresult);
end
