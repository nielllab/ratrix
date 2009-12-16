%% qHowDoesSOAEffectRats




         subplot(1,2,1)
         dateRange= [pmmEvent('231&234-SOA')+1 now]; 
         filter{1}.type='18'; % 12 15 16 18
         [stats CI names params]= getFlankerStats({'231'},'allSOAs',[],filter,dateRange);
         doHitFAScatter(stats,CI,names,params);
         title('231-SOA')
         
         subplot(1,2,2)
         [stats CI names params]= getFlankerStats({'234'},'allSOAs',[],filter,dateRange);
         doHitFAScatter(stats,CI,names,params);
                  title('234-SOA')