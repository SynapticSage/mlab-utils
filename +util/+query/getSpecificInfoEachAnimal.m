function result = getSpecificInfoEachAnimal(megatable, animal, field)

% this function combines getInfoAcrossPatterns and getInfoEachAnimal to
% yield a list that contains a field of interest to query on

% example: getSpecificInfoEachAnimal(megatable, JS15, "OptDim") would
% return all the optimal RRR degress of JS15 in the megatbale

animalinfo = plots.getInfoEachOptionTuple(megatable, "animal", animal);

numToExamine = size(animalinfo,1);
result = [];

for i = 1:numToExamine
    currPatterns = table2array(animalinfo(i,2));
    result = [result, plots.getInfoAcrossPatterns(table2array(currPatterns), "field",field)];
end

end

