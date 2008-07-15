function [context sideName correctName] =getSideCorrectContext(d,n,plotOn)
%matrix of logicals that is numContext X numTrials
%
% if n=1, then 
%
%incorrect left  [1  :  Nth trial]
%incorrect right [1  :  Nth trial]
%correct left    [1  :  Nth trial]
%correct right   [1  :  Nth trial]
%
%num context is number side conditions x number correct conditions
%numCorrect is a pattern of posible correct histories.
% n=  number of trials back to consider context
% If n=1, then there are only two states (incorrect or correct)
% If n=2, then there are four correct condidion patterns: 00 01 10 11
% and numSide is similarly a pattern of L or R
% If n=1, then there are only two states (L or R)
% If n=2, then, LL LR RL RR


if ~exist('d','var') || isempty('d')
    d=getSmalls('220');
    % d = compiledTrialRecords
    % d = removeSomeSmalls(d, d.trialNumber<270000)
    %  d.correctionTrial = zeros(size(d.date));
    % d.info.subject = {'102'};
end

if ~exist('n','var') || isempty('n')
    n=1;
end

if ~exist('plotOn','var') || isempty('plotOn')
    plotOn=0;
end


if n >= 2
    error('not fully written yet')
end

numSides = 2^n;
numCorrect = 2^n;
numContext = numSides * numCorrect;
[sideID, correctID] = meshgrid(0: numSides-1, 1: numCorrect);
% (sideID(:) * numCorrect + correctID(:)) % should count l:numContext


%%%%%%%%%%%%%%%%%
side = (d.response == 3); % logicals are just a quick way to get 0:1
correct = d.correct + 1; %logical +1 is a way to get 1:2
contextID = side*numCorrect + correct;
contextID = [0, contextID(1: end-1)] ; % so it refers to n=1 back
context = zeros(numContext, length(d.date));

sideName = {'L', 'R'};
correctName = {'incorrect', 'correct'};
%%%%%%%%%%%%%%%%%%%%

for i = 1:numContext
    context(i, :) = (contextID == i);
end

if plotOn
    for i = 1:numSides
        for j = 1:numCorrect
            index=(i-1)*numCorrect + j;
            %         subplot(numSides, numCorrect,index )
            doPlot('percentCorrect', removeSomeSmalls(d, ~context(index,:)), 1, numSides, numCorrect, index);
            %doPlot('plotBias', removeSomeSmalls(d, ~context(index,:)), 2, numSides, numCorrect, index);
            if j == 1
                ylabel(sideName{i})
            end
            if i == 1
                xlabel(correctName{j})
            end
        end
    end

end
