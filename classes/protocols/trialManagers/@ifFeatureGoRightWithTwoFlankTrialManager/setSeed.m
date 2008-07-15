function initialSeed=setSeed(tm,method)
%a way to set the seed 
%initialSeed=setSeed(tm,'fromClock')

switch method
    case 'seedFromClock'
        %default for v4; useful for simplicity of saving
        %good for animals side to go to
        initialSeed=sum(100*clock);
        rand('seed',initialSeed)    
        randn('seed',initialSeed)  
    case 'twisterFromClock'
        %default for v7.4+; better rands for truly random stimuli
        initialSeed=sum(100*clock);
        rand('twister',initialSeed)    
        randn('state',initialSeed)  
    otherwise
        error ('bad method');
end

% rand('seed',initialSeed)    %default for v4; old unused
% rand('state',initialSeed)   %default for v5-v7.3, used in early ratrix before 20080209
% rand('twister',initialSeed) %default for v7.4 +
%the last one we initialized is twister
%which means all rand calls will use the twister seed

%also initialize randn
% randn('seed',initialSeed)    %for v4; old unused
% randn('state',initialSeed)   %for v5-v7.3, used in early ratrix

%Draw a randn and a rand and confirm the state changes
% rn1=randn('state');
% randn
% rn2=randn('state');
% randnStateChanges=~all(rn1==rn2);
% 
% r1=rand('twister');
% rand
% r2=rand('twister');
% randStateChanges=~all(r1==r2);
% 
% if randnStateChanges & randStateChanges
%     %everything okay
% else
%     error ('don''t trust your random seed');
% end
