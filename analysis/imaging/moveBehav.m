for f = 1:length(files);
   f
   src = [datapathname files(f).behavdata(1:end-15) 'behav data.mat']
    if exist(src,'file')
        dest = sprintf('%s%s %s',pathname,files(f).expt,files(f).subj);
        if ~exist(dest,'dir')
            mkdir(dest)
            sprintf('made directory %s',dest)
        end
            movefile(src,dest)
            display('success!')
  
    else
        sprintf('no behavdata for %s',files(f).behavdata)
    end
%    input('next file? ')
end