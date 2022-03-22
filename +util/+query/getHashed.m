function result = getHashed(varargin)

% this function will look up for .mat file identifiers (hash key) in the
% hashed folder and return a list of hash keys with their options
% satisfying the options

%% ask for inputs
ip = inputParser;
ip.addParameter('generateH', []);
ip.addParameter('spikeBinSize',  []);
ip.addParameter('timesPerTrial', []);
ip.addParameter('winSize', []);
ip.addParameter('sourceArea', []);
ip.addParameter('numPartition', []);
ip.addParameter("animal",[]);


ip.parse(varargin{:});
opt = ip.Results;

%% set up the examination
optionsToExamine = fieldnames(opt)';
path = ("C:\Users\BrainMaker\commsubspace\hash");
addpath("C:\Users\BrainMaker\MATLAB Drive\Shared");
cd (path)
mat = dir('*.mat');

%% get the number and field names to match
fieldToExamine = [];
numOptionsToExamine = 0;
for i = 1:numel(optionsToExamine)
       currFieldName = optionsToExamine(i);
       currFieldContent = cell2mat(currFieldName);
       if ~isempty(getfield(opt, currFieldContent))
           numOptionsToExamine = numOptionsToExamine+1;
           fieldToExamine = [fieldToExamine," ",currFieldContent];
       end
end

%% look for hash keys with matched content

result = []; 

for q = 1:length(mat)
    current = load(mat(q).name);
    Options = current.Option;
    
    allOptionsFulfilled = true;
    
    % examine each corresponding option fields
    for j = 1:numOptionsToExamine
        currFieldName = optionsToExamine(2*j);
        currFieldContent = currFieldName{:};
        
%         if isa(getfield(opt,currFieldContent), "double")
            toCompare = getfield(Options, fieldToExamine(2*j));
%         else
%             toCompare = getfield(Options, fieldToExamine(2*j));
%         end
        
        if toCompare ~= getfield(opt,fieldToExamine(2*j))
            allOptionsFulfilled = false;
        end
        
    end
    
    if allOptionsFulfilled
        result = [result; mat(q).name];
    end
    
end

end

