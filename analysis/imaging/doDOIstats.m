%This file uses shiftData data to compare widefield data across
%conditions using backgroundgratings stimulus
clear all
close all
profile on
tic
%%

%CHOOSE FILES WITH THE DATA IN THEM
datafiles = {'SalinePreGratings', ...  %1
            'SalinePostGratings', ...  %2
            'DOIPreGratings', ...      %3
            'DOIPostGratings', ...     %4
            'LisuridePreGratings', ... %5
            'LisuridePostGratings'};    %6

%CHOOSE FILE WITH POINTS FROM analyzeWidefieldDOI & SET NAMES
load('SalinePoints'); %pre-made points for visual areas used in original analysis
areanames = {'V1','LM','AL','RL','AM','PM','P'};
load mapOverlay

% groupcycavg = nan(260,260,100,10,length(datafiles)); %make for up to 10 animals per condition
% groupfit = nan(260,260,17,10,length(datafiles));
% 
% tic
% for i= 1:length(datafiles) %collates all conditions (numbered above)
%     load(datafiles{i},'fit','cycavg');%load data
%     for n = 1:size(cycavg,4)
%         groupcycavg(:,:,:,n,i) = cycavg(:,:,:,n);
%         groupfit(:,:,:,n,i) = fit(:,:,:,n); 
%     end
% end
% toc

totaln = 38;
lowsfbk = zeros(totaln*25,10);
lowsfbkp = zeros(totaln*25,10);
lowsfp = zeros(totaln*25,10);
highsfbk = zeros(totaln*25,10);
highsfbkp = zeros(totaln*25,10);
highsfp = zeros(totaln*25,10);
xtune = zeros(totaln*3,10);
ytune = zeros(totaln*2,10);
sftune = zeros(totaln*2,10);

c1 = 1; %counters for each embedded loop
c2 = 1;
c3 = 1;
c4 = 1;
for i = 1:length(datafiles) %for each condition
    load(datafiles{i},'cycavg')
    for j = 1:size(cycavg,4) %for each animal
        for k = 1:25%concatenate low sf bk only
            lowsfbk(c1,1) = cycavg(x(1),y(1),k,j);
            lowsfbk(c1,2) = cycavg(x(2),y(2),k,j);
            lowsfbk(c1,3) = cycavg(x(3),y(3),k,j);
            lowsfbk(c1,4) = cycavg(x(4),y(4),k,j);
            lowsfbk(c1,5) = cycavg(x(5),y(5),k,j);
            lowsfbk(c1,6) = cycavg(x(6),y(6),k,j);
            lowsfbk(c1,7) = cycavg(x(7),y(7),k,j);
            lowsfbk(c1,8) = k;
            lowsfbk(c1,9) = j;
            lowsfbk(c1,10) = i;
            c1 = c1 + 1;
        end
        for k = 26:50%concatenate low sf bk + p
            lowsfbkp(c2,1) = cycavg(x(1),y(1),k,j);
            lowsfbkp(c2,2) = cycavg(x(2),y(2),k,j);
            lowsfbkp(c2,3) = cycavg(x(3),y(3),k,j);
            lowsfbkp(c2,4) = cycavg(x(4),y(4),k,j);
            lowsfbkp(c2,5) = cycavg(x(5),y(5),k,j);
            lowsfbkp(c2,6) = cycavg(x(6),y(6),k,j);
            lowsfbkp(c2,7) = cycavg(x(7),y(7),k,j);
            lowsfbkp(c2,8) = k;
            lowsfbkp(c2,9) = j;
            lowsfbkp(c2,10) = i;
            c2 = c2 + 1;
        end
        for k = 51:75
            highsfbk(c3,1) = cycavg(x(1),y(1),k,j);
            highsfbk(c3,2) = cycavg(x(2),y(2),k,j);
            highsfbk(c3,3) = cycavg(x(3),y(3),k,j);
            highsfbk(c3,4) = cycavg(x(4),y(4),k,j);
            highsfbk(c3,5) = cycavg(x(5),y(5),k,j);
            highsfbk(c3,6) = cycavg(x(6),y(6),k,j);
            highsfbk(c3,7) = cycavg(x(7),y(7),k,j);
            highsfbk(c3,8) = k;
            highsfbk(c3,9) = j;
            highsfbk(c3,10) = i;
            c3 = c3 + 1;
        end
        for k = 76:100
            highsfbkp(c4,1) = cycavg(x(1),y(1),k,j);
            highsfbkp(c4,2) = cycavg(x(2),y(2),k,j);
            highsfbkp(c4,3) = cycavg(x(3),y(3),k,j);
            highsfbkp(c4,4) = cycavg(x(4),y(4),k,j);
            highsfbkp(c4,5) = cycavg(x(5),y(5),k,j);
            highsfbkp(c4,6) = cycavg(x(6),y(6),k,j);
            highsfbkp(c4,7) = cycavg(x(7),y(7),k,j);
            highsfbkp(c4,8) = k;
            highsfbkp(c4,9) = j;
            highsfbkp(c4,10) = i;
            c4 = c4 + 1;
        end
    end
end

lowsfp = lowsfbk;
lowsfp(:,1:7) = lowsfbkp(:,1:7) - lowsfbk(:,1:7); %concatenate low sf p only
highsfp = highsfbk;
highsfp(:,1:7) = highsfbkp(:,1:7) - highsfbk(:,1:7); %concatenate high sf p only
 
c1 = 1; %counters for each embedded loop
c2 = 1;
c3 = 1;
for i = 1:length(datafiles)
    load(datafiles{i},'fit')
    for j = 1:size(fit,4)%concatenate x tuning
        for k = 1:3
            xtune(c1,1) = fit(x(1),y(1),k,j);
            xtune(c1,2) = fit(x(2),y(2),k,j);
            xtune(c1,3) = fit(x(3),y(3),k,j);
            xtune(c1,4) = fit(x(4),y(4),k,j);
            xtune(c1,5) = fit(x(5),y(5),k,j);
            xtune(c1,6) = fit(x(6),y(6),k,j);
            xtune(c1,7) = fit(x(7),y(7),k,j);
            ytune(c1,8) = k;
            xtune(c1,9) = j;
            xtune(c1,10) = i;
            c1 = c1 + 1;
        end
        for k = 4:5
            ytune(c2,1) = fit(x(1),y(1),k,j);
            ytune(c2,2) = fit(x(2),y(2),k,j);
            ytune(c2,3) = fit(x(3),y(3),k,j);
            ytune(c2,4) = fit(x(4),y(4),k,j);
            ytune(c2,5) = fit(x(5),y(5),k,j);
            ytune(c2,6) = fit(x(6),y(6),k,j);
            ytune(c2,7) = fit(x(7),y(7),k,j);
            ytune(c2,8) = k;
            ytune(c2,9) = j;
            ytune(c2,10) = i;
            c2 = c2 + 1;
        end
        for k = 6:7
            sftune(c3,1) = fit(x(1),y(1),k,j);
            sftune(c3,2) = fit(x(2),y(2),k,j);
            sftune(c3,3) = fit(x(3),y(3),k,j);
            sftune(c3,4) = fit(x(4),y(4),k,j);
            sftune(c3,5) = fit(x(5),y(5),k,j);
            sftune(c3,6) = fit(x(6),y(6),k,j);
            sftune(c3,7) = fit(x(7),y(7),k,j);
            sftune(c3,8) = k;
            sftune(c3,9) = j;
            sftune(c3,10) = i;
            c3 = c3 + 1;
        end
    end
end

%get peak values for cycle averages
c1 = 1;
for i = 1:length(lowsfbk)/25
        peaklowsfbk(i,1) = max(lowsfbk(c1:c1+24,1));
        peaklowsfbk(i,2) = max(lowsfbk(c1:c1+24,2));
        peaklowsfbk(i,3) = max(lowsfbk(c1:c1+24,3));
        peaklowsfbk(i,4) = max(lowsfbk(c1:c1+24,4));
        peaklowsfbk(i,5) = max(lowsfbk(c1:c1+24,5));
        peaklowsfbk(i,6) = max(lowsfbk(c1:c1+24,6));
        peaklowsfbk(i,7) = max(lowsfbk(c1:c1+24,7));
        peaklowsfbk(i,8) = lowsfbk(c1,8);
        peaklowsfbk(i,9) = lowsfbk(c1,9);
        peaklowsfbk(i,10) = lowsfbk(c1,10);
        c1 = c1 + 25;
end

c1 = 1;
for i = 1:length(lowsfbk)/25
        peaklowsfbkp(i,1) = max(lowsfbkp(c1:c1+24,1));
        peaklowsfbkp(i,2) = max(lowsfbkp(c1:c1+24,2));
        peaklowsfbkp(i,3) = max(lowsfbkp(c1:c1+24,3));
        peaklowsfbkp(i,4) = max(lowsfbkp(c1:c1+24,4));
        peaklowsfbkp(i,5) = max(lowsfbkp(c1:c1+24,5));
        peaklowsfbkp(i,6) = max(lowsfbkp(c1:c1+24,6));
        peaklowsfbkp(i,7) = max(lowsfbkp(c1:c1+24,7));
        peaklowsfbkp(i,8) = lowsfbkp(c1,8);
        peaklowsfbkp(i,9) = lowsfbkp(c1,9);
        peaklowsfbkp(i,10) = lowsfbkp(c1,10);
        c1 = c1 + 25;
end
c1 = 1;
for i = 1:length(lowsfbk)/25
        peaklowsfp(i,1) = max(lowsfp(c1:c1+24,1));
        peaklowsfp(i,2) = max(lowsfp(c1:c1+24,2));
        peaklowsfp(i,3) = max(lowsfp(c1:c1+24,3));
        peaklowsfp(i,4) = max(lowsfp(c1:c1+24,4));
        peaklowsfp(i,5) = max(lowsfp(c1:c1+24,5));
        peaklowsfp(i,6) = max(lowsfp(c1:c1+24,6));
        peaklowsfp(i,7) = max(lowsfp(c1:c1+24,7));
        peaklowsfp(i,8) = lowsfp(c1,8);
        peaklowsfp(i,9) = lowsfp(c1,9);
        peaklowsfp(i,10) = lowsfp(c1,10);
        c1 = c1 + 25;
end
c1 = 1;
for i = 1:length(highsfbk)/25
        peakhighsfbk(i,1) = max(highsfbk(c1:c1+24,1));
        peakhighsfbk(i,2) = max(highsfbk(c1:c1+24,2));
        peakhighsfbk(i,3) = max(highsfbk(c1:c1+24,3));
        peakhighsfbk(i,4) = max(highsfbk(c1:c1+24,4));
        peakhighsfbk(i,5) = max(highsfbk(c1:c1+24,5));
        peakhighsfbk(i,6) = max(highsfbk(c1:c1+24,6));
        peakhighsfbk(i,7) = max(highsfbk(c1:c1+24,7));
        peakhighsfbk(i,8) = highsfbk(c1,8);
        peakhighsfbk(i,9) = highsfbk(c1,9);
        peakhighsfbk(i,10) = highsfbk(c1,10);
        c1 = c1 + 25;
end

c1 = 1;
for i = 1:length(highsfbk)/25
        peakhighsfbkp(i,1) = max(highsfbkp(c1:c1+24,1));
        peakhighsfbkp(i,2) = max(highsfbkp(c1:c1+24,2));
        peakhighsfbkp(i,3) = max(highsfbkp(c1:c1+24,3));
        peakhighsfbkp(i,4) = max(highsfbkp(c1:c1+24,4));
        peakhighsfbkp(i,5) = max(highsfbkp(c1:c1+24,5));
        peakhighsfbkp(i,6) = max(highsfbkp(c1:c1+24,6));
        peakhighsfbkp(i,7) = max(highsfbkp(c1:c1+24,7));
        peakhighsfbkp(i,8) = highsfbkp(c1,8);
        peakhighsfbkp(i,9) = highsfbkp(c1,9);
        peakhighsfbkp(i,10) = highsfbkp(c1,10);
        c1 = c1 + 25;
end
c1 = 1;
for i = 1:length(highsfbk)/25
        peakhighsfp(i,1) = max(highsfp(c1:c1+24,1));
        peakhighsfp(i,2) = max(highsfp(c1:c1+24,2));
        peakhighsfp(i,3) = max(highsfp(c1:c1+24,3));
        peakhighsfp(i,4) = max(highsfp(c1:c1+24,4));
        peakhighsfp(i,5) = max(highsfp(c1:c1+24,5));
        peakhighsfp(i,6) = max(highsfp(c1:c1+24,6));
        peakhighsfp(i,7) = max(highsfp(c1:c1+24,7));
        peakhighsfp(i,8) = highsfp(c1,8);
        peakhighsfp(i,9) = highsfp(c1,9);
        peakhighsfp(i,10) = highsfp(c1,10);
        c1 = c1 + 25;
end



dir = '\\lorentz\backup\widefield\DOI experiments\Matlab Widefield Analysis';
nam = 'DOIstats';
save(fullfile(dir,nam),'lowsfbk','lowsfbkp','lowsfp',...
                        'highsfbk','highsfbkp','highsfp',...
                        'xtune','ytune','sftune',...
                        'datafiles','areanames','totaln');

toc
profile viewer



