%This file uses shiftData data to compare widefield data across
%conditions using backgroundgratings stimulus
clear all
close all
profile on
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

count = 1; 
for i = 1:length(datafiles)
    load(datafiles{i},'cycavg')
    for j = 1:size(cycavg,4)%concatenate low sf bk only
        for k = 1:25
            lowsfbk(count,1) = cycavg(x(1),y(1),k,j);
            lowsfbk(count,2) = cycavg(x(2),y(2),k,j);
            lowsfbk(count,3) = cycavg(x(3),y(3),k,j);
            lowsfbk(count,4) = cycavg(x(4),y(4),k,j);
            lowsfbk(count,5) = cycavg(x(5),y(5),k,j);
            lowsfbk(count,6) = cycavg(x(6),y(6),k,j);
            lowsfbk(count,7) = cycavg(x(7),y(7),k,j);
            lowsfbk(count,8) = k;
            lowsfbk(count,9) = j;
            lowsfbk(count,10) = i;
            count = count + 1;
        end
    end
    for j = 1:size(cycavg,4)%concatenate low sf bk + p
        for k = 26:50
            lowsfbkp(count,1) = cycavg(x(1),y(1),k,j);
            lowsfbkp(count,2) = cycavg(x(2),y(2),k,j);
            lowsfbkp(count,3) = cycavg(x(3),y(3),k,j);
            lowsfbkp(count,4) = cycavg(x(4),y(4),k,j);
            lowsfbkp(count,5) = cycavg(x(5),y(5),k,j);
            lowsfbkp(count,6) = cycavg(x(6),y(6),k,j);
            lowsfbkp(count,7) = cycavg(x(7),y(7),k,j);
            lowsfbkp(count,8) = k;
            lowsfbkp(count,9) = j;
            lowsfbkp(count,10) = i;
            count = count + 1;
        end
    end
    for j = 1:size(cycavg,4) %concatenate high sf bk only
        for k = 51:75
            highsfbk(count,1) = cycavg(x(1),y(1),k,j);
            highsfbk(count,2) = cycavg(x(2),y(2),k,j);
            highsfbk(count,3) = cycavg(x(3),y(3),k,j);
            highsfbk(count,4) = cycavg(x(4),y(4),k,j);
            highsfbk(count,5) = cycavg(x(5),y(5),k,j);
            highsfbk(count,6) = cycavg(x(6),y(6),k,j);
            highsfbk(count,7) = cycavg(x(7),y(7),k,j);
            highsfbk(count,8) = k;
            highsfbk(count,9) = j;
            highsfbk(count,10) = i;
            count = count + 1;
        end
    end
    for j = 1:size(cycavg,4) %concatenate high sf bk + p
        for k = 76:100
            highsfbkp(count,1) = cycavg(x(1),y(1),k,j);
            highsfbkp(count,2) = cycavg(x(2),y(2),k,j);
            highsfbkp(count,3) = cycavg(x(3),y(3),k,j);
            highsfbkp(count,4) = cycavg(x(4),y(4),k,j);
            highsfbkp(count,5) = cycavg(x(5),y(5),k,j);
            highsfbkp(count,6) = cycavg(x(6),y(6),k,j);
            highsfbkp(count,7) = cycavg(x(7),y(7),k,j);
            highsfbkp(count,8) = k;
            highsfbkp(count,9) = j;
            highsfbkp(count,10) = i;
            count = count + 1;
        end
    end
end

lowsfp = lowsfbk;
lowsfp(:,1:7) = lowsfbkp(:,1:7) - lowsfbk(:,1:7); %concatenate low sf p only
highsfp = highsfbk;
highsfp(:,1:7) = highsfbkp(:,1:7) - highsfbk(:,1:7); %concatenate high sf p only

count = 1; 
for i = 1:length(datafiles)
    load(datafiles{i},'fit')
    for j = 1:size(fit,4)%concatenate x tuning
        for k = 1:3
            xtune(count,1) = fit(x(1),y(1),k,j);
            xtune(count,2) = fit(x(2),y(2),k,j);
            xtune(count,3) = fit(x(3),y(3),k,j);
            xtune(count,4) = fit(x(4),y(4),k,j);
            xtune(count,5) = fit(x(5),y(5),k,j);
            xtune(count,6) = fit(x(6),y(6),k,j);
            xtune(count,7) = fit(x(7),y(7),k,j);
            ytune(count,8) = k;
            xtune(count,9) = j;
            xtune(count,10) = i;
            count = count + 1;
        end
    end
    for j = 1:size(fit,4)%concatenate y tuning
        for k = 4:5
            ytune(count,1) = fit(x(1),y(1),k,j);
            ytune(count,2) = fit(x(2),y(2),k,j);
            ytune(count,3) = fit(x(3),y(3),k,j);
            ytune(count,4) = fit(x(4),y(4),k,j);
            ytune(count,5) = fit(x(5),y(5),k,j);
            ytune(count,6) = fit(x(6),y(6),k,j);
            ytune(count,7) = fit(x(7),y(7),k,j);
            ytune(count,8) = k;
            ytune(count,9) = j;
            ytune(count,10) = i;
            count = count + 1;
        end
    end
    for j = 1:size(fit,4)%concatenate sf tuning
        for k = 6:7
            sftune(count,1) = fit(x(1),y(1),k,j);
            sftune(count,2) = fit(x(2),y(2),k,j);
            sftune(count,3) = fit(x(3),y(3),k,j);
            sftune(count,4) = fit(x(4),y(4),k,j);
            sftune(count,5) = fit(x(5),y(5),k,j);
            sftune(count,6) = fit(x(6),y(6),k,j);
            sftune(count,7) = fit(x(7),y(7),k,j);
            sftune(count,8) = k;
            sftune(count,9) = j;
            sftune(count,10) = i;
            count = count + 1;
        end
    end
end

dir = '\\lorentz\backup\widefield\DOI experiments\Matlab Widefield Analysis';
nam = 'DOIstats';
save(fullfile(dir,nam),'lowsfbk','lowsfbkp','lowsfp',...
                        'highsfbk','highsfbkp','highsfp',...
                        'xtune','ytune','sftune',...
                        'datafiles','areanames','totaln');


profile viewer



