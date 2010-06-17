%%
for id=[227,228,230,233,234,229,231,232]
    d=getSmalls(num2str(id),[],[],false);
    x=removeSomeSmalls(d,d.step~=9 | d.currentShapedValue~=0.4 );
    disp([num2str(id) ': ' num2str(length(x.date)) ' trials'])
    disp([num2str(id) ': ' num2str(length(unique(floor(x.date)))) ' sessions'])
end


%%
%for id=[227,228,230,233,234,229,231,232]
count=0
for id=[228 227 230 233 234 139 138]
    d=getSmalls(num2str(id),[],[],false);
    count=count+1;
    for i=1:8
        x=removeSomeSmalls(d,~ismember(d.step,[i]));
        %x=removeSomeSmalls(d,~ismember(d.step,[1 2 3]));
        %x=removeSomeSmalls(d,d.step~=9 | d.currentShapedValue>0.39 );
        %x=removeSomeSmalls(d,d.step~=9 | d.currentShapedValue~=0.4 );
        disp([num2str(id) ' step ' num2str(i) ' : ' num2str(length(x.date)) ' trials;  ' num2str(length(unique(floor(x.date)))) ' sessions'])
        a(count,i)=length(x.date);
        b(count,i)=length(unique(floor(x.date)));
    end
end
%%
mean(a) %10^4*   0.0393    0.2611    0.0207    0.0737    0.5469    0.5303    0.1166    1.1075
std(a)  %10^4*   0.0674    0.3864    0.0156    0.0517    0.4521    0.4810    0.1272    1.2626


mean(b) %1.5714    6.8571    2.4286    8.0000   17.4286   13.5714    4.1429   37.1429
std(b)  %2.6992   10.0071    1.7182    5.0000   13.1385    9.6929    3.2367   47.1856



