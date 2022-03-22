function result = getInfoEachAnimal(megatable, animal, varargin)

% this function gets relevant info for an animal from the megatable
% returns a matrix of tables {Optiontble Patterntable}
% 

result = [];
numTotalRuns = size(megatable,1);
for i = 1:numTotalRuns
    animalOptions = megatable(i,1).Optiontable;
    animalPatterns = megatable(i,2).Patterntable;
    if table2array(animalOptions(1,"animal")) == animal
        result = [result;  table(animalOptions,animalPatterns) ];
    end

end

end

