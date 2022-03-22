function loc = charPosition(V)

where = 'first';
charlocs = cellfun(@(x) isstring(x) || ischar(x), V);
loc = find(charlocs, 1, where);
