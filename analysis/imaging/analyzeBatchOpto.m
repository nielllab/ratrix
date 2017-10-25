batch_optoBehav;

gc=1; chr=2; full=1; v1=2;

use = strcmp({files.notes},'good session');

files = files(use);

for i = 1:length(files)
    i
    
    %%% get response data
    [resp(:,:,i) rt(:,i)] = analyzeOpto([trialRecpathname  files(i).subj '\' files(i).trialRec],[files(i).subj ' ' files(i).power ' ' files(i).geno ' ' files(i).SilenceArea]);
    drawnow
    
    %%% get LED power
    pwr(i) = str2num(files(i).power(1:end-2));
    
    %%% get genotype
    if strcmp(files(i).geno,'camk2 gc6')
        geno(i) = gc;
    elseif strcmp(files(i).geno,'Pv ChR2')
        geno(i) = chr;
    end
    
    %%% get silencing area
    if strcmp(files(i).SilenceArea,'full window');
        region(i) = full;
    elseif strcmp(files(i).SilenceArea,'V1');
        region(i) = v1;
    end

end


for p = 1:3

%     if p==1
%         use = geno == chr & region==full & pwr==11;   use11=use;
%     elseif p==2
%         use = geno == chr & region==full& pwr == 22;  use22=use;
    if p==1
        use = geno == chr & region==full & pwr == 45; use45=use;
    elseif p ==2
        use = geno==chr & region ==v1; V1use=use;
    elseif p==3
        use = geno==gc; gcuse=use;
    end
    
    for laser = 1:2
        %%% fraction correct
        correct(p,laser) = 0.5 * (1 - mean(resp(1,laser,use),3) + mean(resp(2,laser,use),3));
        err(p,laser) = std( 0.5 * (1 - resp(1,laser,use) + resp(2,laser,use)), [],3);
        
        %%% reaction time
        rtAll(p,laser) = mean(rt(laser,use),2);
        rtErr(p,laser)  =std(rt(laser,use),[],2);
        
        %%% bias
        b = abs(mean(resp(:,laser,use),1) -0.5); %%% bias as average difference from 0.5 left choices; abs so that biases in opposite direction don't cancel
        bias(p,laser) = 2*mean(b,3);  %%% 2x since otherwise goes from 0 - 0.5
        biasErr(p,laser) = 2*std(b,[],3);
    end
end


%put RT values in matrix where columns are experimental groups for statistical testing
%%%Light On
xCorrectOn = nan([3,13]); %fill with nan values so we have same numbers of rows
xCorrectOn(1,1:length(rt(use45)))=(0.5 * (1 - (resp(1,2,use45)) + (resp(2,2,use45))));
  xCorrectOn(2,1:length(rt(V1use))) = (0.5 * (1 - (resp(1,2,V1use)) + (resp(2,2,V1use))));
    xCorrectOn(3,1:length(rt(gcuse)))= (0.5 * (1 - (resp(1,2,gcuse)) + (resp(2,2,gcuse))));
xCorrectOn = xCorrectOn';

[p,tbl,stats]=kruskalwallis(xCorrectOn)
c = multcompare(stats)

%%%Light OFF
xCorrectOff = nan([3,13]); %fill with nan values so we have same numbers of rows
xCorrectOff(1,1:length(rt(use45)))=(0.5 * (1 - (resp(1,1,use45)) + (resp(2,1,use45))))
  xCorrectOff(2,1:length(rt(V1use))) = (0.5 * (1 - (resp(1,1,V1use)) + (resp(2,1,V1use))));
    xCorrectOff(3,1:length(rt(gcuse)))= (0.5 * (1 - (resp(1,1,gcuse)) + (resp(2,1,gcuse))));
xCorrectOff = xCorrectOff';

[p,tbl,stats]=kruskalwallis(xCorrectOff)
c = multcompare(stats)


%%%%performance by group...light on vs off
%full window
[p,tbl,stats]=kruskalwallis([xCorrectOn(:,1) xCorrectOff(:,1)])
c = multcompare(stats)
%V1only
[p,tbl,stats]=kruskalwallis([xCorrectOn(:,2) xCorrectOff(:,2)])
c = multcompare(stats)
%GCaMP controls
[p,tbl,stats]=kruskalwallis([xCorrectOn(:,3) xCorrectOff(:,3)])
c = multcompare(stats)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%put performance values in matrix where columns are experimental groups for statistical testing
xRTOff = nan([3,13]); %fill with nan values so we have same numbers of rows
xRTOff(1,1:length(rt(use45)))=rt(1,use45);   
  xRTOff(2,1:length(rt(V1use))) = rt(1,V1use);
    xRTOff(3,1:length(rt(gcuse)))= rt(1,gcuse);
xRTOff = xRTOff';

[p,tbl,stats]=kruskalwallis(xRTOff)
c = multcompare(stats)

xRTOn = nan([3,13]); %fill with nan values so we have same numbers of rows
xRTOn(1,1:length(rt(use45)))=rt(2,use45);   
  xRTOn(2,1:length(rt(V1use))) = rt(2,V1use);
    xRTOn(3,1:length(rt(gcuse)))= rt(2,gcuse);
xRTOn = xRTOn';

figure
boxplot(xRTOn)

[p,tbl,stats]=kruskalwallis(xRTOn)
c = multcompare(stats)

%%%%RT by group...light on vs off
%full window
[p,tbl,stats]=kruskalwallis([xRTOn(:,1) xRTOff(:,1)])
c = multcompare(stats)
%V1only
[p,tbl,stats]=kruskalwallis([xRTOn(:,2) xRTOff(:,2)])
c = multcompare(stats)
%GCaMP controls
[p,tbl,stats]=kruskalwallis([xRTOn(:,3) xRTOff(:,3)])
c = multcompare(stats)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
errorbar([1 2; 1 2; 1 2]',correct',err'); ylim([0 1]); legend({'45mW','V1','gcamp'}); ylabel('% correct')

figure
errorbar([1 2; 1 2; 1 2]',rtAll',rtErr'); ylim([0 1]); legend({'45mW','V1','gcamp'}); ylabel('rt');

figure
errorbar([1 2; 1 2; 1 2]',bias',biasErr'); ylim([0 1]); legend({'45mW','V1','gcamp'}); ylabel('bias');


% 
% figure
% errorbar([1 2 ; 1 2 ; 1 2; 1 2; 1 2]',correct',err'); ylim([0 1]); legend({'11mW','22mW','45mW','V1','gcamp'}); ylabel('% correct')
% 
% figure
% errorbar([1 2 ; 1 2 ; 1 2; 1 2; 1 2]',rtAll',rtErr'); ylim([0 1]); legend({'11mW','22mW','45mW','V1','gcamp'}); ylabel('rt');
% 
% figure
% errorbar([1 2 ; 1 2 ; 1 2; 1 2; 1 2]',bias',biasErr'); ylim([0 1]); legend({'11mW','22mW','45mW','V1','gcamp'}); ylabel('bias');

