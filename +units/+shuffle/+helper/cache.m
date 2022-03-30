function [out, shuffle] = cache(out, singleShuffle, shuffle, prevShuff, Opt)
% Caches a table 

% Pereforms a cache opereation
switch Opt.cacheMethod
case 'matfile'
    singleShuffle = table2struct(singleShuffle, 'ToScalar', true);
    if isempty(singleShuffle)
        warning('the shuffle is empty');
    end
    out.shuffle(prevShuff, 1) = singleShuffle;
case 'parquet'
    parquetwrite(fullfile(Opt.outfolder, Opt.parquetfile(prevShuff)), singleShuffle);
case 'ram'
    shuffle{prevShuff} = singleShuffle;
otherwise
    error("Not a valid method");
end
