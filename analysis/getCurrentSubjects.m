function [subjects heatStrs stationStrs]=getCurrentSubjects(rack);
%RETURNS a matrix of subjectID that is stations x heats

%rack=1;

conn=dbConn;
heats=getHeats(conn);

heatStrs= {};
assignments={};
for i=1:length(heats)
    if ~ismember(heats{i}.name,{'Test','Black'})
        heatStrs{end+1}=heats{i}.name;
        assignments{end+1}=getAssignments(conn,rack,heats{i}.name);
        for j=1:length(assignments{end})
            stationPosition=double(assignments{end}{j}.station_id)-double('A')+1;
            subjects{stationPosition,i}=assignments{end}{j}.subject_id;
        end
    end
end

% s=getStationsOnRack(conn,rack); %this has the stationPosition info ...
closeConn(conn);

%get the names
for i=1:size(subjects,1)
    stationStrs{i}=[num2str(rack) char(((i)+double('A')-1)')];
end



% % HEAT       %1        %2       %3        %4     %overnight
% subjects={'rat_213','rat_215','rat_216','rat_195','rat_144';... %3  upper-left
%           'rat_214','rat_219','rat_217','rat_218','rat_220';... %11 upper-right
%           'rat_221','rat_222','rat_102','rat_106','rat_196';... %1  middle-left
%           'rat_115','rat_116','rat_117','rat_130','rat_114';... %9  middle-right
%           'rat_132','rat_133','rat_138','rat_139','rat_128';... %2  lower-left
%           'rat_134','rat_135','rat_136','rat_137','rat_131'};   %4  lower-right

% % HEAT       %1        %2       %3        %4     %overnight
% subjects={'rat_140','rat_141','rat_142','rat_195','rat_144';... %3  upper-left
%           'rat_145','rat_146','rat_147','rat_148','rat_129';... %11 upper-right
%           'rat_112','rat_126','rat_102','rat_106','rat_196';... %1  middle-left
%           'rat_115','rat_116','rat_117','rat_130','rat_114';... %9  middle-right
%           'rat_132','rat_133','rat_138','rat_139','rat_128';... %2  lower-left
%           'rat_134','rat_135','rat_136','rat_137','rat_131'};   %4  lower-right

% subjects={'rat_140','rat_141','rat_142','rat_143','rat_144';... %3  upper-left
%         'rat_145','rat_146','rat_147','rat_148','rat_129';... %11 upper-right
%         'rat_112','rat_126','rat_102','rat_106','rat_127';... %1  middle-left
%         'rat_115','rat_116','rat_117','rat_130','rat_114';... %9  middle-right
%         'rat_132','rat_133','rat_138','rat_139','rat_128';... %2  lower-left
%         'rat_134','rat_135','rat_136','rat_137','rat_131'};   %4  lower-right
