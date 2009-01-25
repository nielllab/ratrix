function runKlustakwikCont(basepath, channelNr, pcaMode)

cd(basepath);

if pcaMode
    %call klustawik
    !KlustaKwik.exe kl 1 -UseFeatures 1111111111 -MinClusters 3 -MaxClusters 30    
else
    
end

