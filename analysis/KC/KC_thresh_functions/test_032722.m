find(loBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs(1,com,i) == 1)

% make a vector starting at con = 0 and ending at the lowest con where df/f is sig
% diff from con=0
xs = [0,min(find(loBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs(1,:,i) == 1))]

% plot(rand(5,1))
%   sigline([2,4])
%sigline([2,3],'p=0.05')

figure
plot(com+1,hiRun_mnCRF_acrossSess_AllDurAllPts(i,com+1),'r*','LineWidth',1.1)
formatSpec = 'p=%0.4f'
p_val = sprintf(formatSpec,hiBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs(2,com,i))

sigline(xs,'p=0.0083')