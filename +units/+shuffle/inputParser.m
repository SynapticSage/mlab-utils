function ip = optargs()

ip = inputParser;

ip.KeepUnmatched = true; % Any unmatched go to the called method units.atBehavior.m
% Usual params for that: 

% Time filter behavior?
ip.addParameter('query', [], @(x) ischar(x) || isstring(x));

% Quantity and range of shuffles
ip.addParameter('nShuffle', 100, @isnumeric);
ip.addParameter('skipShuffled', false);         % requires a cacheToDisk scenario: if true, if it detects an existing shuffle at that index on the disk, it skips
ip.addParameter('startShuffle', 1, @isnumeric); % the first shuffle index ip.addParameter('endShuffle', [], @isnumeric);  % the first shuffle index
ip.addParameter('endShuffle', [], @isnumeric); % last shuffle HOW do we shift?
ip.addParameter('shuffleunits', 'unitwise');  % shuffle neurons so that {unitwise}|uniform
ip.addParameter('shiftstatistic', 'uniform'); % what statistic of shift? {uniform}|normal
ip.addParameter('shifttype', 'circshift');
ip.addParameter('width', 'whole');            % draw the 'whole' period of time, or some specified amount or standard deviation
ip.addParameter('shiftWhat', 'behavior');     % It's equibalent to shift behavior times repeatedly per cell or spike times per cell, but my estimate is that it's less memory intense for behavior

% SAVE space?
ip.addParameter('throwOutNonGroup', false);
ip.addParameter('preallocationSize', 2); % number of shuffles to run at a time
ip.addParameter('props',[]);
ip.addParameter('dropGroupby', true);

% CACHE specific
ip.addParameter('cacheMethod', 'matfile');                   % {matfile} | parquet | RAM, Speed: RAM>matfile>parquet, RAMspace: matfile>parquet>RAM
ip.addParameter('parquetfile', @(shuff) shuff + ".parquet"); % lambda defining parquet file name
ip.addParameter('cacheToDisk', {});                          % used to define folder or cache file; if out to disk, this takes the parameters for coding.file.shufflefilename or coding.file.parquetfoldername
ip.addParameter('groups', []);                               % pass in computed groups rather than labels from which we have to compute them? for saving computational time,
ip.addParameter('groupby', ["epoch", "period"]);                               % pass in computed groups rather than labels from which we have to compute them? for saving computational time,
ip.addParameter('outfolder', []);                            % pass this to set the outfolder, instead of deriving it from cache-specific methods called on cacheToDisk parameters

