function F = folder(animal, datatype, varargin)
% FOLDER returns the folder to process nd-Branched cell files at

% ALIAS
DETERMINE = -1;
YES = 1;
NO = 0;
if nargin < 2
    datatype="";
end

ip = inputParser;
ip.KeepUnmatched = true;
ip.addParameter('folder', string([]), @(x) isstring(x) || ischar(x))
ip.addParameter('folderIsRelative',DETERMINE) % deprecated, but kept to not break old functions
ip.addParameter('folderIsExplicit',DETERMINE); % newer version of  isRelative
ip.addParameter('animalFolder', DETERMINE); % if animal name is passed, we could either use it or not, or we can let this function decide if to use if it sees a real animal name listed in animaldef
ip.parse(varargin{:});
Opt = ip.Results;

% CODE TO ALLOW DEPRECATED OPTION
if Opt.folderIsRelative == YES
    Opt.folderIsExplicit = false;
end
if Opt.folderIsExplicit == DETERMINE
    if ~isempty(Opt.folder)
        Opt.folderIsExplicit = YES;
    end
end

if ~isempty(datatype)
    switch datatype
        case {'cgramc','cgramcnew'}
            datatypeFolder = 'chronux_eeg';
        case {'lfp','eeg','theta','delta','beta','gamma','eegref','ripple','rippleref','thetaref','deltaref'}
            datatypeFolder = 'EEG';
        case {'raw','mda','mdatab','deepinsight','deepinsightUnfilt'}
            datatypeFolder = 'RAW';
        case {'diotable','event','events','maze'}
            datatypeFolder = 'DIO';
        case {'callback'}
            datatypeFolder = 'callback';
        case {'replaydecode'} % added 04/21
            datatypeFolder = 'ReplayResults';
        otherwise
            datatypeFolder = [];
    end
end

if Opt.folderIsExplicit == YES
    F = Opt.folder;
else

    % Possible animal folder
    if  Opt.animalFolder == YES
        animalInfo = animaldef(animal);
        animalFolder = animalInfo{2};
    elseif  Opt.animalFolder == DETERMINE
        if ~isempty(animal)
            try
                animalInfo = animaldef(animal);
                Opt.animalFolder = YES;
                animalFolder = animalInfo{2};
            catch
                error('Animal folder lookup failed');
            end
        else
            %Opt.animalFolder = NO;
            %animalFolder = [];
            error('Animal folder not found');
        end
    end

    % complete folder
    if Opt.folderIsExplicit == NO % relative folder
        F = fullfile(animalFolder, Opt.folder); % if animal folder empty, will be relative to this folder
    else
        F = fullfile(animalFolder, datatypeFolder);
    end
end
    
