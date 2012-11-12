function [r rewardSizeULorMS requestRewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound updateRM] = ...
    calcReinforcement(r,trialRecords, subject)

updateRM=0;
tic
try %this takes ~80ms and happens on every request and reward, consider just doing it once at the beginning of sessions?
    conn = dbConn;
    name = subject{1};
    q = ['SELECT reward FROM subject WHERE name=''' name ''''];
    results = query(conn,q);
    closeConn(conn);
    if results{1} ~= r.rewardSizeULorMS
        r.rewardSizeULorMS = results{1};
        updateRM=1;
        fprintf('*** updating reward size from db\n')
    else
        fprintf('*** reward size already matches db\n')
    end
catch ex
    ex
    try
        closeConn(conn);
    end
    fprintf('bailing on db reward\n')
end
toc
[rewardSizeULorMS requestRewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound] = ...
    calcCommonValues(r,r.rewardSizeULorMS,getRequestRewardSizeULorMS(r));