%
%exports data and runs klustakwik on it
%
%exportMode: 1 -> PCA, 2-> raw
%
%this requires klustakwik.exe in c:\temp ; change this if necessary
%
%urut/nov05
function exportToKlusta(basepath, channelNr, spikes, exportMode)

if exportMode==1
    [pc,score,latent,tsquare] = princomp(spikes);
    nrDatapoints=10; %first 10 PCs
else
    nrDatapoints=size(spikes,2); %all 
    score=spikes;
end

%export
fid = fopen([basepath 'kl.fet.' num2str(channelNr)],'w+');
fprintf(fid,[num2str(nrDatapoints) '\n']);
for k=1:length(spikes)
        fprintf(fid,'%s\n', num2str(score(k,1:nrDatapoints)));        
end  
fclose(fid);

cd('c:\temp');

allFeatures='';
for i=1:nrDatapoints
    allFeatures=[allFeatures '1'];    
end

eval(['!KlustaKwik.exe kl ' num2str(channelNr) ' -UseFeatures ' allFeatures ' -MinClusters 3 -MaxClusters 30']);

