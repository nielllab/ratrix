function out=getStepNumFromRemoteRatrix()

rootPath='C:\pmeier'; 
warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath(fullfile(rootPath, 'Ratrix','classes')));
warning('on','MATLAB:dispatcher:nameConflict')
    
stationIP{1}='192.168.0.101';
stationIP{2}='192.168.0.102';
stationIP{3}='192.168.0.103';
stationIP{4}='192.168.0.104';
stationIP{9}='192.168.0.109';
stationIP{11}='192.168.0.111';

count=0;
for j=1:size(stationIP,2)
    if ~isempty(stationIP{j})

        load(sprintf('\\\\%s\\c\\pmeier\\Ratrix\\ServerData\\db.mat',stationIP{j}))
        subjectIDs=getSubjectIDs(r)

        for i=1:size(subjectIDs,2)
            count=count+1;
            s=getSubjectFromID(r,subjectIDs(i));
            [p step ] =getProtocolAndStep(s);
            steps{count,1}=subjectIDs{i};
            steps{count,2}=step;
            
        end
    end
end


[a order]=unique(steps(:,1));
if size(unique(a),1)+sum(strcmp('test',steps(:,1)))+sum(strcmp('test2',steps(:,1)))>size(steps,1)
%okay because all the repeated rats are justy the test on each station
else
    steps(order,:)
    error('rats may be defined in 2 stations at once:  check that')
end
    
out=steps(order,:);
