function newtimes = preallocateBehaviorShifts(shifts, beh, groups, varargin)
% Creates our shifted behavior times per shuffle, per neuron
%
% TODO add the yarsev shift type

ip = inputParser;
ip.addParameter('maxSize_timeVector', 1000);
ip.addParameter('neuronChunk', 80);
ip.addParameter('shifttype', 'circshift');
ip.addParameter('checksumUnique', false);
ip.addParameter('debug', false);
ip.parse(varargin{:})
Opt = ip.Results;

[S, N, ~] = size(shifts);
newtimes = repmat(shiftdim(beh.time,-2), [S, N]); % make an Shifts x Neuron x Time new record of shifted times
tic

iscircshift = strcmp(Opt.shifttype, 'circshift');
disp("Using shift type = " + Opt.shifttype);

for s = progress(1:S, 'Title', 'Preallocating shuffle times') % whole shuffle sets of time
    if Opt.debug
        GG = progress(groups.uGroups', 'Title', 'G');
    else
        GG = groups.uGroups';
    end
    for g = GG % pockets of times matching properties
        groupselect = groups.time.groups==g;
        scale = mean(diff(beh.time(groupselect)));
        vector_of_timeshifts = round(shifts(s,:,g)/scale)'; %FIXME not unique? needs to be ?

        if iscircshift
            if sum(groupselect) < Opt.maxSize_timeVector
                newtimes(s,:,groupselect) = util.vector.circshift(beh.time(groupselect), vector_of_timeshifts);
            else
                % ISSUE WITH CIRCSHIFT POCKETS ..
                % DIFFERENT SHUFFLE THAN THE ABOVE .. This creates little micropockets of shuffle)
                % Break the problem into digenstible chunks
                %indices = find(groupselect);
                %for ii = 1:Opt.maxSize_timeVector:length(indices)
                %    subindices = ii:min(ii+Opt.maxSize_timeVector-1, length(indices));
                %    newtimes(s,:,subindices) = util.vector.circshift(beh.time(subindices), vector_of_timeshifts);
                %end
                neurons = 1:Opt.neuronChunk:size(shifts,2);
                for neuron = 1:numel(neurons)
                    N = neuron:min(neuron+Opt.neuronChunk-1, numel(neurons));
                    newtimes(s, N, groupselect) = util.vector.circshift(beh.time(groupselect)', vector_of_timeshifts(N));
                end
            end
        else % LINEAR INDEX MOVEMENT
            keyboard; % untested!
            newtimes(s,:,groupselect) = beh.time(groupselect + vector_of_timeshifts);

            
            %NOTE : I do not have implented the shuffle in yatrsev dotson
            %where indices shift up to the edge of a boundary and disappear
        end

    end
    % If we need to check whether all of the times are unique or not
    if Opt.checksumUnique
       uniqueness = arrayfun(@(n) util.isunique(newtimes(s, n, :)),...
           1:size(newtimes, 2), 'UniformOutput', true);
       if ~any(uniqueness)
           error('Times not unique for neurons %d', find(uniqueness));
       end
    end
end
toc
