function standAloneTest
setupEnvironment;

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
%rx=crossModalMakeRatrix(dataPath,true,'localTimed');
makeRatrix(dataPath,true,'localPump');

rx=ratrix(fullfile(dataPath, 'ServerData'),0); %test loading in from disk

try

    ids=getSubjectIDs(rx);
    s=getSubjectFromID(rx,ids{1});
    b=getBoxIDForSubjectID(rx,getID(s));
    st=getStationsForBoxID(rx,b);
    rx=doTrials(st(1),rx,0,[]); %0 means repeat forever
    cleanup;

catch
    lasterr
    x=lasterror
    x.stack.file
    x.stack.line
    cleanup;
    rethrow(lasterror)
end

function cleanup
sca
ListenChar(0)
ShowCursor(0)