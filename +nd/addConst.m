function results = addConst(results, constlabel, constvalue)

indices = nd.indicesMatrixForm(results);

for index = indices'
    indexCell = num2cell(index);
    results(indexCell{:}).(constlabel) = constvalue;
end
