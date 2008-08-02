permStorePath = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\subjects\';
for rat = 269:270
    display(int2str(rat)); pause(0);
    ratDataPath = [permStorePath  int2str(rat) '\' ]; %maybe change this???
    direcList = dir(ratDataPath);
    
    for i = 1:length(direcList)
        if(~any(strcmp({'.','..'},direcList(i).name)))
            display(direcList(i).name); pause(0);
            load(fullfile(permStorePath,int2str(rat),direcList(i).name));
            for j = 1:length(trialRecords)
                trialRecords(j).subjectsInBox = {int2str(rat)};
            end
            try
                trialRecords = rmfield(trialRecords,'subjectInBox');
            catch
                'above does not have subjectInBox'
            end
            save(fullfile(permStorePath,int2str(rat),direcList(i).name),'trialRecords');
        end
    end
end