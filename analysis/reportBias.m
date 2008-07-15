


%100 times at 100 msec, mmHg ~260, in grams

rewards=zeros(12,3);         %box ID x port num
rewards(3,:)= [1.49 0 1.61]; %left top station
rewards(1,:)= [2.11 0 2.10]; %left middle station
rewards(2,:)= [4.27 0 4.38]; %left bottom station

pctBias=100*(rewards(:,1)-rewards(:,3))./min(rewards(:,[1,3]),[],2);

stations=find(~isnan(pctBias));
for i=1:sum(~isnan(pctBias))
    st=stations(i);
    if pctBias(st)>0
        side='left ';
    elseif pctBias(st)<0
        side='right';
    else
        warning('might be equal') 
        side='xxx';
    end
    disp(sprintf('station %4g has a reward bias where the %s side is %2.2g%% greater',st,side,abs(pctBias(st))))
end
    