function X = getQuantile(X)
% Applies a rank to X and then determines the fraction each element is into
% that rank.

quantile_X = [(1:numel(X))', X(:)]; % left column encodes original order
quantile_X = sortrows(quantile_X, 2); % sort by values
quantile_X = [quantile_X, (1:numel(X))']; % right most column now encodes the rank of each element
quantile_X = sortrows(quantile_X, 1); % now restore the original order and return the percent rank
X = quantile_X(:, 3)/size(quantile_X, 1);
