function beh = removeduplicatetimes(beh)
% function beh = removeduplicatetimes(beh)
% 
% Removes any duplicate times in the behavior structure. Sometimes happens
% witht the behavior data coming from our camera system.

% Clean behavior
if ~util.isunique(beh.time)
    dups = util.getduplicates_logical(beh.time);
    %beh = nd.apply(beh, 'field', "*", 'lambda', @(x) x(~dups, :), 'allowLambdaFail', true);
    beh = beh(~dups, :);
end

