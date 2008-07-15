function state=analyzePerContextualState(d)

%don't run on freeDrinks, must have correction Trials!

if ~exist('d', 'var')
    d.correct = [0 1 0 1 0 0 0];
    error('not yet');
end

hasCorrectionTrials = 1; % could add : if zero then ignore them
maxCorrectSameSide = 4%4; % could add : if inf then ignore state

% current state diagram:

%  state     ID
%   norm     0
% ct_L ct_R  1 2
% LC_1 RC_1  3 4
% LC_2 RC_2  5 6
%   |    |
%   v    v
% maxL maxR  2N+1 2N+2  =  9 10

numTrials = length(d.date);

maxAllowedState = 2+ 2*maxCorrectSameSide ;

% generate a vector of the current state in a markov chain
state = nan(1, numTrials);
corruptStateHistory = nan(1, numTrials);
corruptSideState=0;

for i = 1: numTrials
    if i==1
        state( i) = 0; % start with the normal trial
    else
        switch d.response(i-1)
            case 1
                prevSideLeft = 1;
            case 3
                prevSideLeft = 0;
            case -1
                % current code just uses the first value which is either 1 or 2
                corruptSideState=1;  % only get out if return to known state
                prevSideLeft = 1;
                %                 ind = max(find(ismember(d.response(1 : i-1), [1 3] ))) %find the most recent legitimate trial that correction trial might appeal to
                %                 switch d.response(ind)
                %                     case 1
                %                     prevSideLeft = 1
                %                     case 3
                %                      prevSideLeft = 0
                %                 end
            otherwise
                error('unexpected response')
        end




        prevSideLeft = (d.response(i-1) == 1); % true if left
        % warning: dual blocked ports etc. count as right?
        prevCorrect = (d.correct(i-1) == 1);

        switch state(i-1)
            case 0 % norm
                if prevCorrect
                    if prevSideLeft
                        state(i) = 3; % LC_1
                    else
                        state(i) = 4; % RC_1
                    end
                else
                    if d.correctionTrial(i) ==1 % use the coin flip that happened in the data
                        if prevSideLeft
                            state(i) = 1; % ct_L
                        else
                            state(i) = 2; % ct_R
                        end
                    else
                        state(i) = 0; % norm
                    end
                end
            case 1 % ct_L forces to right
                if d.correctionTrial(i-1) ~= 1
                    trial = i-1
                    error('there should have been a correction trial here')
                end

                if prevSideLeft
                    state(i) = 1; % stay in correction trial : ct_L
                    if prevCorrect
                        msg='must be incorrect if stay in CT';
                        state=doSketchyCT(msg,1,1,corruptSideState,state,i,d,prevSideLeft,corruptStateHistory);
                    end
                else
                    state(i) = 4; %0; % return to norm * having gone left RC
                    if ~prevCorrect
                        msg='must be correct if return to norm';
                        state=doSketchyCT(msg, 1,4,corruptSideState,state,i,d,prevSideLeft,corruptStateHistory);
                    end
                end

            case 2 % ct_R forces to left
                if d.correctionTrial(i-1) ~= 1
                    trial = i-1
                    msg='there should have been a correction trial here';
                    state=doSketchyCT(msg,2,[],corruptSideState,state,i,d,prevSideLeft,corruptStateHistory);
                end

                if prevSideLeft
                    state(i) = 3; %0; % return to norm * having gone left LC
                    if ~prevCorrect
                        msg='must be correct if return to norm';
                        state=doSketchyCT(msg,2,3,corruptSideState,state,i,d,prevSideLeft,corruptStateHistory);
                    end
                else
                    state(i) = 2; % stay in correction trial : ct_R
                    if prevCorrect
                        msg='must be incorrect if stay in CT';
                        state=doSketchyCT(msg,2,2,corruptSideState,state,i,d,prevSideLeft,corruptStateHistory);
                    end
                end

            otherwise
                if state(i-1) > maxAllowedState | state(i-1) < 0
                    state(i-1)
                    error('bad state')
                else
                    % must be a maxCorrect counter
                end

                prevLeftState = mod(state(i-1), 2); % odd states are left states



                if ceil(state(i-1)/2) -1  == maxCorrectSameSide  %different statistics when maxCorrectSameSide
                    % divide by 2 for left and right states, subtract 1 for ct

                    if prevCorrect
                        if prevSideLeft & prevLeftState
                            showStuff(d, state, corruptStateHistory,i,prevSideLeft)
                            error('not allowed because of maxPerSide');
                            
                        elseif ~prevSideLeft & ~prevLeftState
                            error('not allowed because of maxPerSide');
                        elseif prevSideLeft
                            state(i) = 3; % if you switched sides the counter resets
                        elseif ~prevSideLeft
                            state(i) = 4; % if you switched sides the counter resets
                        else
                            error('should never happen');
                        end
                    else
                        if d.correctionTrial(i) ==1 % use the coin flip that happened in the data
                            if prevSideLeft
                                state(i) = 1; % ct_L
                            else
                                state(i) = 2; % ct_R
                            end
                        else
                            state(i) = 0; % norm
                        end
                    end

                    if d.maxCorrectForceSwitch(i-1) ~= 1
                        trial = i-1;
                        error('there should have been a maxCorrectSameSide here')
                    end
                else % otherwise act like normal state, with a counter
                    if prevCorrect
                        % prevSideLeft
                        % prevLeftState
                        % state(i-1)
                        if prevSideLeft & prevLeftState
                            state(i) = state(i-1)+2; % LC_next
                        elseif ~prevSideLeft & ~prevLeftState
                            state(i) = state(i-1)+2; % RC_next
                        else
                            state(i) = 0; % if you switched sides the counter resets
                        end
                    else
                        if d.correctionTrial(i) ==1 % use the coin flip that happened in the data
                            if prevSideLeft
                                state(i) = 1; % ct_L
                            else
                                state(i) = 2; % ct_R
                            end
                        else
                            state(i) = 0; % norm
                        end
                    end
                end

        end
    end


    %exit corrupt state if possible, and log it
    if ismember(state(i),[0]) %states without history dependence  (maybe state 2 or state 4, bc response must have been a known 3=rightport)
        corruptSideState=0;
    end
    corruptStateHistory(i)=corruptSideState;
end

function showStuff(d, state, corruptStateHistory,trial,prevSideLeft)

ss=max([trial-10, 1]);

correct = d.correct(ss:trial)
side = d.response(ss:trial)
ct = d.correctionTrial(ss:trial)
state=state(ss:trial)
corrupt=corruptStateHistory(ss:trial)
trial
prevSideLeft

function state=doSketchyCT(msg,fromState,sendTo,corruptSideState,state,i,d,prevSideLeft,corruptStateHistory)

if corruptSideState
    disp(sprintf('trial: %d, from %d to %d;  %s',i,fromState,sendTo,msg))
    if ~isempty(sendTo)
        state(i) = sendTo;
    end
else
    showStuff(d, state, corruptStateHistory,i,prevSideLeft)
    error(sprintf('error on non corrupt trial: %s',msg))
end




% Determine pctCorrect and bias per state

% display