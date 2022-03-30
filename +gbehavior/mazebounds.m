function bounds = mazebounds(beh)
% returns bounds in x and y


    x = beh.pos(:,1);
    y = beh.pos(:,2);

    bounds.x = [min(x) max(x)];
    bounds.y = [min(y) max(y)];

