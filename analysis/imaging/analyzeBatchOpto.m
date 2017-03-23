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


for p = 1:5

    if p==1
        use = geno == chr & region==full & pwr==11;
    elseif p==2
        use = geno == chr & region==full& pwr == 22;
    elseif p==3
        use = geno == chr & region==full & pwr == 45;
    elseif p ==4
        use = geno==chr & region ==v1;
    elseif p==5
        use = geno==gc;
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

figure
errorbar([1 2 ; 1 2 ; 1 2; 1 2; 1 2]',correct',err'); ylim([0 1]); legend({'11mW','22mW','45mW','V1','gcamp'}); ylabel('% correct')

figure
errorbar([1 2 ; 1 2 ; 1 2; 1 2; 1 2]',rtAll',rtErr'); ylim([0 1]); legend({'11mW','22mW','45mW','V1','gcamp'}); ylabel('rt');

figure
errorbar([1 2 ; 1 2 ; 1 2; 1 2; 1 2]',bias',biasErr'); ylim([0 1]); legend({'11mW','22mW','45mW','V1','gcamp'}); ylabel('bias');

