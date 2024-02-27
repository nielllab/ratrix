gratingTitle=0; %%% titles for grating figs?
evRange = 10:20; baseRange = 1:5; %%% timepoints for evoked and baseline activity
dfofInterp(dfofInterp>1) = 1; dfofInterp(dfofInterp<-1) = -1; 

        

%%% plot timecourse of N random locations
x = rand(64,1)*(size(dfofInterp,1)-62) + 31;
y =rand(64,1)*(size(dfofInterp,2)-62) + 31;
x = round(x); y = round(y);
dx = 10;
range = -dx:dx;

x = [];y=[];
for j = 35:40:360;
    for i = 20:40:300;
        
        if min(normgreen(j+range,i+range),[],[1 2])>0.1
            x = [x;j];
            y = [y;i];
        end
    end
end

figure
imagesc(normgreen);
hold on
for i = 1:length(x)
    %plot([y(i)-dx, y(i)-dx, y(i)+dx,y(i)+dx, y(i)-dx],[x(i)-dx,x(i)+dx,x(i)+dx,x(i)-dx, x(i)-dx],'b')
    plot(y(i),x(i),'bo')
end
axis equal

clear traces
for i = 1:length(x)
    traces(:,i) = squeeze(nanmean(dfofInterp(x(i)+range,y(i)+range,:),[1 2]));
    traces(:,i) = traces(:,i)-nanmean(traces(:,i));
    if nanstd(traces(:,i))>1
        traces(:,i)=0;
    end
end

%traces = dF(10:20:end,:)';

figure
plot(traces);
xlim([0 300]); ylim([-0.5 0.5])

a = rand(length(x));
[d ind] = sort(a);


figure
%for i = 1:length(x);
ntr =16;
for i = 1:ntr
    hold on
   % plot((1:length(traces))/10-5, traces(:,i)/0.2 + length(x)-i);
    plot((1:length(traces))/10-5, traces(:,ind(i))/0.3 + i);
end
xlabel('secs');
ylabel('unit #');
ylim([0 ntr+1.5])
xlim([0 120])
fig = gcf;
fig.Renderer = 'Painter';
