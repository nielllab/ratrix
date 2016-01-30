
datafiles = {'DOITrainedAnimalsBKGRATSpre',...
            'DOITrainedAnimalsBKGRATSpost'};

avgtrialcyc = zeros(64,64,10,864,length(datafiles));        
for i= 1:length(datafiles) %collates all conditions (numbered above) 
    load(datafiles{i},'trialcyc');%load data
    avgtrialcyc(:,:,:,:,i) = trialcyc;
end

dir = 'C:\Users\nlab\Desktop\Widefield Data\DOI';
nam = 'CompareGratings';
save(fullfile(dir,nam),'allcycavg','allmnfit','areanames','datafiles','range','scscale','indcycavg','inddeconcycavg');
