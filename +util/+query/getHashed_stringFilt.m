function out = getHashed_stringFilt(T, filtstring)

if numel(filtstring) > 1
    filtstring = join(filtstring," & ");
end

filtstring = replace(filtstring, '$','T.');
evalstring = sprintf("T(%s, :)", filtstring);
disp("Filtering with:")
disp(evalstring);
disp('');
out = eval(evalstring);
