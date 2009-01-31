function readKlustakwikContResult(basepath)


	fid = fopen('c:\temp\resp3.txt','r');
	
	%first line of output is nr of clusters
	nrOfClusters = str2num ( fgets(fid) );

	%clu #1 is noise cluster,dont use (eg =0)
	
	clu=zeros(size(waveforms,1) ,1);
	i=1;
	while feof(fid)==false
    		line = fgets(fid);
    		clu(i) = str2num(line);
    		i=i+1;
	end
	fclose(fid);
	
	clu=clu-1; %noise cluster is now =0

	%remove clusters that are bad/too small etc?
	

    
clusterNr=[];

    
    
  	i=1;
	while feof(fid)==false
    		line = fgets(fid);
    		clusterNr(i) = str2num(line);
    		i=i+1;
	end
	fclose(fid);
