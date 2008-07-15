function out=getRequestPorts(tm,numPorts)

out=floor((numPorts+1)/2); % allows prompts and hardware requests
%currently the center request is being used as a hack 
%out=[]; %could force no request ports when promptedNAFC, but thats annoying -pmm