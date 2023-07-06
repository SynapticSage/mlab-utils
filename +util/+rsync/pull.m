function [result, status] = pull(animal, dayDir, varargin)
% Pushes to a machine with rsync

ip = inputParser;
ip.addParameter('local', []);
ip.addParameter('remote', []);
ip.addParameter('test', false);
ip.addParameter('ext_exclusions', ["mp4", "h264", "raw"]);
ip.parse(varargin{:})
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
to   = rawdef(animal, 'machine', Opt.remote) + filesep + dayDir;

% Build the exclusion list
if ~isempty(Opt.ext_exclusions)
    Opt.ext_exclusions = "--exclude ""*." + Opt.ext_exclusions + """";
end

% Build rsync phrase
phrase  = ["rsync --progress -avu", Opt.test, from, to]
phrase = join(phrase, " ");


% Hopefully this executes displaying text as it runs
[status, result] = system(phrase);

disp(result)
