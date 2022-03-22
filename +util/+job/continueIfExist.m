function continueIfExist(jobVarName, iVarName)

execute =...
{'\n if exist("\s","var") && ~isempty(\s{\s})'
        '\n continue'
'\n end'};

execute{1} = sprintf(execute{1}, jobVarName, iVarName);
execute{2} = sprintf(execute{2});
execute{3} = sprintf(execute{3});

evalin('caller', [execute{:}]);
