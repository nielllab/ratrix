%
%only count first for which
%1.1 * max(S1) > max(S2)
%1.1 * max(S2) > max(S3) 
%etc
%
%is valid
%
%mode:1 --> require decreasing amplitude
%mode:0 --> do not require decreasing amplitude
function bursts2 = quantifyBursts( bursts, spikes, assigned, useCells, mode)

bursts2=[];
burstCount=0;
for i=1:size(bursts,1)
    valid=true;

    if mode==1
        for j=1:bursts(i,1)
            if (1.05 * max( spikes(bursts(i,5)+(j-1),:) )) > (max( spikes(bursts(i,5)+(j),:) ))   %non increasing amplitude, excluding some noise
            else
                valid=false;
            end
        end
    end
    
    if valid
        
        %test whether any of this bursts contains spikes from discarded
        %neurons (non-valid neurons)
        assignedTo = assigned( bursts(i,5:6) );
        
        if length( setdiff( unique(assignedTo), [useCells 999]) ) > 0   % don't exclude noise spikes
            valid=false;
            continue;
        end
        
        %exclude "noise only" bursts (all spikes associated to noise)
        
        if unique(assignedTo)==999
            valid=false;
            continue;
        end
        
        burstCount=burstCount+1;  
        bursts2(burstCount,:) = bursts(i,:);
    end
end
