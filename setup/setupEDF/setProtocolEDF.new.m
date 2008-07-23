%rack 2 (cockpits) %all on free drinks, then easiest possible go to side (some grating, some image, some dots), then tilt discrim
% A     B     C          D     E     F
{      '180' '161'                     } %red
%       im     im

{      '160' '163'                     } %orange
%       im    im

{      '186' '202'                     } %yellow
%       d     d

{      '162' '203'                     } %green
%       g(i)  g

{'159' '164' '204'                     } %blue
% g     g(i)  g

{'185' '179'                           } %violet
% d     d


%rack 3 (boxes)
% A     B     C          D     E     F           G     H     I
{'263' '189' '190'      '191' '192' '181'       '182' '187' '188'} %orange
%       rb    rb         rb    rb(i) rc          rc    rc    rc

{'264' '165' '166'      '167' '168' '177'       '178' '183' '184'} %yellow
%       f     f          f     f     bt          bt    bt    bt

{'265' '173' '174'      '175' '176' '169'       '170' '171' '172'} %green
%       xm    xm         xm    xm

{'266' '193' '194'      '249' '250' '251'       '252' '253' '254'} %blue


{'159' '255' '256'      '257' '258' '259'       '260' '261' '262'} %violet


note need to add rack 2 test rats





rackNum=getRackIDFromIP;


rackNum=2;
asgns=[];
conn=dbConn;
heats=getHeats(conn);
for i=1:length(heats)
    assignments=getAssignments(conn,rackNum,heats{i}.name);
    for j=1:length(assignments)
        if isempty(asgns)
            asgns=assignments{j};
        else
            asgns(end+1)=assignments{j};
        end
    end
end
closeConn(conn);

asgns=asgns(ismember({asgns.owner},{'eflister' 'bsriram' 'pmeier'})); %162, 164 curently pmeier, 173-176 bsriram

for i=1:length(subIDs)
    ind=find(strcmp(subIDs{i},{asgns.subject_id}));
    if length(ind)==1
        switch asgns(ind).experiment
            case 'Box Transfer'
                'bt'
            case 'Cross Modal'
                'cm'
            case 'Flicker'
                'f'
            case 'Rel Block'
                'rb'
            case 'Rel Cue'
                'rc'
            case 'Testing'
                't'
            case 'Tube Physiology'
                'tp'
            case 'Tube Transfer'
                'tt'
            otherwise
                subIDs{i}
                asgns(ind).experiment
                error('didn''t recognize experiment for subject')
        end
    else
        subIDs{i}
        ind
        error('didn''t find unique subject id in db assignments for this rack')
    end
end