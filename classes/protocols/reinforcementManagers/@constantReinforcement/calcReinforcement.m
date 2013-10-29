function [r rewardSizeULorMS requestRewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound updateRM] = ...
    calcReinforcement(r,trialRecords, subject)

updateRM=0;
tic
g = GetSecs;
s = 'init';
try %this takes ~80ms and happens on every request and reward, consider just doing it once at the beginning of sessions?
    conn = dbConn;
    s = 'conn';
    r{1} = GetSecs-g;
    name = subject{1};
    s = 'name';
    q = ['SELECT reward FROM subject WHERE name=''' name ''''];
    results = query(conn,q);
    s = 'query';
    r{end+1} = GetSecs-g;
    closeConn(conn);
    s = 'close';
    r{end+1} = GetSecs-g;
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
g = GetSecs-g;
toc
[rewardSizeULorMS requestRewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound] = ...
    calcCommonValues(r,r.rewardSizeULorMS,getRequestRewardSizeULorMS(r));

if g>.3
    setpref('Internet','SMTP_Server','smtp.uoregon.edu')
    setpref('Internet','E_mail','ratrix@uoregon.edu')
    if ~exist('name','var')
        name = 'NONAME';
    end
%    emailStr=sprintf('RATRIX: db access for %s (%s): %g (%s)',name,s,g,num2str(cell2mat(r)));
 %   sendmail('erik.flister@gmail.com',emailStr,'slow db access');
end
end