function existance = exists(obj, index)
% Responds with logical array of true/false if the the index described is non-empty.

existance = false(1, size(index,1));
for i = 1:size(index,1)
    ind = index(i, :);
    try 
        a = ndBranch.get(obj, index);
        if ~nd.isEmpty(a)
            existance(i) = true;
        end
    end
end
