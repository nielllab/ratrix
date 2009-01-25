function clu = importFromKlusta(channelNr, spikes)

fnameReturn = ['kl.clu.' num2Str(channelNr)];

if exist( fnameReturn ) ==2 
	
	%read reply
	
	fid = fopen(fnameReturn,'r');
	
	%first line of output is nr of clusters
	nrOfClusters = str2num ( fgets(fid) );

	%clu #1 is noise cluster,dont use (eg =0)
	
	clu=zeros(size(spikes,1) ,1);
	i=1;
	while feof(fid)==false
    		line = fgets(fid);
    		clu(i) = str2num(line);
    		i=i+1;
	end
	fclose(fid);
	
	clu=clu-1; %noise cluster is now =0

	
	
else
	['error, no return von klustakwik']
	stats{j}.sortingDone=false;
end




        
        
        
                
