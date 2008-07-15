
% This script generates the expected normal body weight growth curves
% NOTE: The data stored in the DB is the threshold growth curve, it is up to
% this script to determine the desired threshold (eg 85%)

%data for younger rats
%www.criver.com/research_models_and_services/research_models/Long_Evans_Rat_cat05.pdf
%data after week 15= p105 = 420g will be connected with a different data source
femaleMeasuredWeights = [34,68,97,123,149,166,178,191,204,212,221,229,238];
femaleMeasuredAges = [21:7:(size(y0,2)+3-1)*7];

maleMeasuredWeights = [40,80,115,165,210,260,300,330,355,375,395,410,420];  %Mean weight
maleMeasuredAges = [21:7:(size(y0,2)+3-1)*7];   %measured every week starting week 3

%additional body weight data for older rats from http://jn.nutrition.org/cgi/reprint/100/1/59.pdf
%HENRY A. SCHROEDER, MARIAN MITCHENER, ALEXIS P. NASON;
%'Zirconium, Niobium, Antimony, Vanadium and Lead in Rats: Life term studies' Journal of Nutrition,
%average of about 50 rats

femaleCorrection=22;  %this is a hack offset to avoid discontinuity, but preserve slope
femaleMeasuredWeights = [femaleMeasuredWeights ([225 239 251 263 263]+ femaleCorrection)]';
femaleMeasuredAges = [femaleMeasuredAges 120 150 180 360 540];

femaleAges = femaleMeasuredAges(1):femaleMeasuredAges(end);
femaleWeights = spline(femaleMeasuredAges,femaleMeasuredWeights,femaleAges);
femaleGenders = repmat({'F'},1,length(femaleAges));

maleCorrection=125;  %this is a hack offset to avoid discontinuity, but preserve slope
maleMeasuredWeights = [maleMeasuredWeights ([312 342 365 444 507]+ maleCorrection)]';
maleMeasuredAges = [maleMeasuredAges 120 150 180 360 540];

maleAges = maleMeasuredAges(1):maleMeasuredAges(end);
maleWeights = spline(maleMeasuredAges,maleMeasuredWeights,maleAges);
maleGenders = repmat({'M'},1,length(maleAges));


%figure(1)
%plot(femaleAges,femaleWeights,'.')
%ylabel('Weight (grams)')
%xlabel('Post natal days')
%title('Female Long Evans')


ages = [femaleAges maleAges];
weights = [femaleWeights maleWeights];
genders = [femaleGenders maleGenders];
strain_uin = 1; % 1 - Long Evans Rats

% SET THE THRESHOLD (here it is 85%
weights = weights*0.85;

conn = dbConn();
deleteStr = sprintf('DELETE FROM WEIGHTTHRESHOLD WHERE STRAIN_UIN=%d',strain_uin);
curs=exec(conn,deleteStr);
close(curs);
results=query(conn,'SELECT MAX(uin)+1 FROM WEIGHTTHRESHOLD');
if isempty(results) || length(results) ~= 1 || isempty(results{1,1}) || isnan(results{1,1})
    uin_start = 1;
else
    uin_start = results{1,1};
end
closeConn(conn);

uin_start


% 
uins = (uin_start:uin_start+length(ages)-1)';

conn = dbConn();
for i=1:size(uins)
    % UIN, STRAIN_UIN, AGE, GENDER, WEIGHT
    insertStr = sprintf('INSERT INTO WEIGHTTHRESHOLD VALUES(%d, %d, %d, ''%s'', %d)',uins(i),strain_uin,ages(i),genders{i},round(weights(i)));
    curs=exec(conn,insertStr);
    close(curs);
end
closeConn(conn);



% % If you want to export the data from this script, you can run the following
% sep = ',';
% eor = '\n';
% fid = fopen('weightthresholds.txt','w+t');
% for i=1:size(uins)
%     % UIN, STRAIN_UIN, AGE, GENDER, WEIGHT
%     row = sprintf('%d%s%d%s%d%s%s%s%d%s',uins(i),sep,strain_uin,sep,ages(i),sep,genders{i},sep,round(weights(i)),eor);
%     fprintf(fid,row);
% end
% fclose(fid);