function doPrime(s)


if strcmp(s.rewardMethod, 'localPump')
    if ~ s.localPumpInited
        s.localPump=initLocalPump(s.localPump,s,s.parallelPortAddress);
        s.localPumpInited=true;
    end


    mlVol=3; %should be put into definition of localPump + constructor
    %could make method  s.localPump=doPrime(s.localPump);
    for i=1:getNumPorts(s)
        s.localPump=resetPosition(s.localPump);

        valves=zeros(1,getNumPorts(s));
        valves(i)=1;
        valves=logical(valves);

        s.localPump=doReward(s.localPump,mlVol,valves,false);
    end
    s.localPump=resetPosition(s.localPump);

else
    warning('prime requested for non-localPump station')
end