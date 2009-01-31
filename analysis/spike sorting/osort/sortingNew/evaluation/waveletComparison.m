%run rodrigos algorithm for comparison

channel=10;

spikes=newSpikesPositive;

handles.par.features = 'wav';               %choice of spike features
handles.par.inputs = 10;                    %number of inputs to the clustering
handles.par.scales = 4;                     %scales for wavelet decomposition
handles.par.fname = ['data_ch' num2str(channel)]; 

handles.par.num_temp = 20;                  %number of temperatures
handles.par.mintemp = 0;                    %minimum temperature
handles.par.maxtemp = 0.2;                  %maximum temperature
handles.par.tempstep = 0.01;                %temperature step
handles.par.stab = 0.8;                     %stability condition for selecting the temperature
handles.par.SWCycles = 100;                 %number of montecarlo iterations
handles.par.KNearNeighb = 11;               %number of nearest neighbors
handles.par.min_clus_abs = 30;              %minimum cluster size (absolute value)
handles.par.min_clus_rel = 0.01;            %minimum cluster size (relative to the total nr. of spikes)



num_temp = 20;          %number of temperature values
min_clus = 50;          %minimum cluster size for considering a phase transition or saving
stab = 0.8;             %stability of the cluster size with temperature increase

% CALCULATES INPUTS TO THE CLUSTERING ALGORITHM. 
inspk = wave_features(spikes,handles);              %takes wavelet coefficients.
inspk_aux = inspk;

cd('c:\temp\matlabwork')
save data inspk_aux -ascii
[clu, tree] = run_cluster(handles);
%[temp] = find_temp_new(tree,handles);

all_temp=zeros(1,64);

% Selects the temperature.
aux =diff(tree(:,5));   % Changes in the first cluster size
aux1=diff(tree(:,6));   % Changes in the second cluster size
temp = 2;               % Default value in case no more than one cluster appears.
for t=1:num_temp-1;
    % A threshold larger than min_clus in the first 2 clusters means that other cluster appeared.
    if aux(t) < -min_clus & aux1(t) > min_clus 
        if tree(t+2,6) >= stab * tree(t+1,6)   %Also requires some stability of the 2nd cluster.
            temp=t+1;         
            break           % Assumes that clusters appear at the same temperature.
        end
    end
end
all_temp(1)=temp;


% Get clusters and plot spikes
class1=find(clu(all_temp(1),3:end)==0);
class2=find(clu(all_temp(1),3:end)==1);
class3=find(clu(all_temp(1),3:end)==2);
class4=find(clu(all_temp(1),3:end)==3);
class5=find(clu(all_temp(1),3:end)==4);
                
nspk=size(spikes,1);
clusterr=zeros(nspk,2);
                if length(class1) > min_clus
                    clusterr(class1(:),1)=1;
                end
                if length(class2) > min_clus
                    clusterr(class2(:),1)=2;
                end
                if length(class3) > min_clus
                    clusterr(class3(:),1)=3;
                end
                if length(class4) > min_clus
                    clusterr(class4(:),1)=4;
                end
                if length(class5) > min_clus
                    clusterr(class5(:),1)=5;
                end