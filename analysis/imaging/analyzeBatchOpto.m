batch_optoBehav;

gc=1; chr=2; full=1; v1=2;

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
