find(loBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs(1,com,i) == 1)

% make a vector starting at con = 0 and ending at the lowest con where df/f is sig
% diff from con=0
xs = [0,min(find(loBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs(1,:,i) == 1))]

% plot(rand(5,1))
%   sigline([2,4])
%sigline([2,3],'p=0.05')

figure
errorbar(x_axis,hiRun_mnCRF_acrossSess_AllDurAllPts(i,:),hiRun_stdErrCRF_acrossSess_allPts(i,:),'r','LineWidth',0.75)
hold on
plot(com+1,hiRun_mnCRF_acrossSess_AllDurAllPts(i,com+1),'r*','LineWidth',1.1)
sigstar({[1,min(find(hiBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs(1,:,i) == 1))+1]})

%formatSpec = 'p=%0.4f'
%p_val = sprintf(formatSpec,hiBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs(2,com,i))
%sigline(xs,'p=0.0083')

 x=[1,2,3,2,1];
    subplot(1,2,1)
    bar(x)
    sigstar({[1,2], [2,3], [4,5]})
    subplot(1,2,2)
    bar(x)
    sigstar({[2,3],[1,2], [4,5]})
    
    R=randn(30,2);
    R(:,1)=R(:,1)+3;
    boxplot(R)
    set(gca,'XTick',1:2,'XTickLabel',{'A','B'})
    H=sigstar({{'A','B'}},0.01);
    ylim([-3,6.5])
    set(H,'color','r')
    
    
    


figure
errorbar(x_axis,hiRun_mnCRF_acrossSess_AllDurAllPts(i,:),hiRun_stdErrCRF_acrossSess_allPts(i,:),'r','LineWidth',0.75)
hold on
plot(com+1,hiRun_mnCRF_acrossSess_AllDurAllPts(i,com+1),'r*','LineWidth',1.1)
%sigstar({[1,min(find(hiBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs(1,:,i) == 1))+1]})

clear xt
xt={'0'; '3' ; '6' ; '12' ; '25' ; '50'; '100'} ; 
set(gca,'xtick',1:7); 
set(gca,'xticklabel',xt);

formatSpec = 'p=%0.4f'
p_val = sprintf(formatSpec,hiBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs(2,com,i))

%H=sigstar({{'0','5',0.01}})
%H=sigstar({{'0','5',0.01}})
%H=sigstar({{xt{1},xt{min(find(hiBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs(1,:,i) == 1))+1}}});
% ,p_val
H=sigstar({{xt{1},xt{min(find(hiBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs(1,:,i) == 1))+1}}});
set(H,'color','r')

