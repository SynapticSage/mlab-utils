function result = getInfoAcrossPatterns(Patterns, varargin)


% this function returns a linearized version of the Pattern struct matrix
% by default.
% Pass in the name of the field you are interested in querying and the
% result would be the list of all Patterns with respect to that field
% You can also specify the region of interest.
% Or the specific rhythm of interest

% RETURN ONE CELL VECTOR AT A TIME

ip = inputParser;
ip.addParameter('field', []); % field of interest
% X_source, X_target
% rankRegress: cv, cvLoss, optDimReducedRankRegress, B, B_, V
% factorAnalysis: qOpt_hpc, qOpt_pfc

ip.addParameter('direction',  []); % region of interest {hpc-hpc, hpc-pfc}
ip.addParameter('pattern', []); % rhythm of interest {theta, delta, ripple, control}

ip.parse(varargin{:});
opt = ip.Results;

rankRegress = ["cv", "cvLoss", "optDimReducedRankRegress", "B", "B_", "V"];


[nPartitions, nDirections, nPatterns] = size(Patterns);

result = cell(1,nPartitions * nDirections * nPatterns);
for iPartition = 1:nPartitions
    for iDirection = 1:nDirections
        for iPattern = 1:nPatterns
            if (~isempty(opt.direction) && Patterns(iPartition, iDirection,...
                    iPattern).directionality ~= opt.direction)||...
                    (~isempty(opt.pattern) && Patterns(iPartition, iDirection,...
                    iPattern).name ~= opt.pattern)
                continue;
              
            end
            if isempty(opt.field)
                result = [result, Patterns(iPartition, iDirection, iPattern)];
            else
                % need to store them in a cell matrix, because list
                % automatically concatenates 
                if (opt.field == "X_source" || opt.field == "X_target")
                    result{three2oneD(iPartition, iDirection, iPattern,...
                                   nPartitions, nDirections, nPatterns)} = ...
                                   getfield(Patterns(iPartition,...
                                    iDirection,iPattern), opt.field);
                elseif ismember(opt.field, rankRegress)
                     result{three2oneD(iPartition, iDirection, iPattern,...
                                   nPartitions, nDirections, nPatterns)} = ...
                                   getfield(Patterns(iPartition,...
                               iDirection,iPattern).rankRegress, opt.field);
                    %                 else
                    
                end
            end
            
        end
    end
end

index = cellfun(@isempty, result) == 0;
result = result(index);

end

