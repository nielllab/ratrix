%%% batch version of getRegionsLobe
%%% loops over all files for a given stim type, and if boundaries aren't
%%% defined, calls getRegionsLobe
%%% cmn 2019


stimname = 'sin gratings'
[sbx_fname acq_fname mat_fname] = compileFilenames('For Batch File.xlsx',stimname);

redoAll = 1;
nRegions = input('how many regions? ');

for i = 1:length(mat_fname)
    
    clear xb
    if exist(mat_fname{i},'file')
        load(mat_fname{i},'xb');
        if redoAll | ~exist('xb','var');
            getRegionsLobe(mat_fname{i},nRegions);
        else
            sprintf('already done %s',mat_fname{i})
        end
    else
        sprintf('need to analyze %s',mat_fname{i})
    end
    
end

