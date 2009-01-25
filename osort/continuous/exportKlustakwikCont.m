%
%export continously recorded datapoints to klustakwik
%
%urut/april04
function exportKlustakwikCont ( basepath, spikes, channelNr )

%export
fid = fopen([basepath 'kl.fet.' num2str(channelNr)],'w+');
fprintf(fid,[num2str(size(spikes,2)) '\n']);
for k=1:size(spikes)
    fprintf(fid,'%s\n', num2str(spikes(k,:)));        
end  
fclose(fid);