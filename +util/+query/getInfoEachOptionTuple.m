function result = getInfoEachOptionTuple(megatable, varargin)

% this function looks for a specific tuple of options
% it will help examine the variables of interests
% under the same option choices across all runs

% example: plots.getInfoEachOptionTuple(TABLE, "winSize", 0.35)
% returns all the {Option, Patterns} of runs that have a winSize of 0.35

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

result = [];
numTotalRuns = size(megatable,1);
optionsToExamine = fieldnames(opt)';

numOptionsToExamine = 0;

% get the number and field names to match
fieldToExamine = [];
for i = 1:numel(optionsToExamine)
       currFieldName = optionsToExamine(i);
       currFieldContent = cell2mat(currFieldName);
       if ~isempty(getfield(opt, currFieldContent))
           numOptionsToExamine = numOptionsToExamine+1;
           fieldToExamine = [fieldToExamine," ",currFieldContent];
       end
end


for i = 1:numTotalRuns
    animalOptions = megatable(i,1).Optiontable;
    animalPatterns = megatable(i,2).Patterntable;
    allOptionsFulfilled = true;
    for j = 1:numOptionsToExamine
         currFieldName = optionsToExamine(2*j);
        currFieldContent = currFieldName{:};  

            if isa(getfield(opt,currFieldContent), "double")
                toCompare = str2double(table2array(animalOptions(1,fieldToExamine(2*j))));
            else
                toCompare = table2array(animalOptions(1,fieldToExamine(2*j)));
            end
            
            if toCompare ~= getfield(opt,fieldToExamine(2*j))
                allOptionsFulfilled = false;
            end

    end
    
    if allOptionsFulfilled
        result = [result;  table(animalOptions,animalPatterns) ];
    end
    
end

end

