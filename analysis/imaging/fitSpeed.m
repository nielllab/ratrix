conv_range=10;
thresh =30;
sp_smooth = conv(sp,[zeros(conv_range+1,1); ones(conv_range,1)]/conv_range,'same');

figure
plot(sp);
hold on
plot(sp_smooth,'g')

alpha = mean(dfof_bg(:,:,sp_smooth>thresh),3)-mean(dfof_bg(:,:,sp_smooth<thresh),3);
f= figure
imagesc(alpha);

%alpha_rep = repmat(alpha,[1 1 length(sp)]);
clear s
s(1,1,:) = sp_smooth>thresh;

df_nomove = dfof_bg - repmat(alpha,[1 1 length(sp)]).* repmat(s,[size(dfof_bg,1) size(dfof_bg,2) 1]);


[rawmap rawcycMap fullMov] =phaseMap(dfof_bg,10,10,0.9999);
    rawmap(isnan(rawmap))=0;
   f=figure
   imshow(polarMap(rawmap));
   
   [rawmap rawcycMap fullMov] =phaseMap(df_nomove,10,10,0.9999);
    rawmap(isnan(rawmap))=0;
   f=figure
   imshow(polarMap(rawmap));


   
for i =1:10;
    figure(f)
    [y x] = ginput(1); x= round(x); y= round(y);
    figure
    plot(squeeze(dfof_bg(x,y,:))); hold on
    plot((sp_smooth>thresh)*alpha(x,y),'r');,
 figure
 plot(squeeze(dfof_bg(x,y,:)) - (sp_smooth>thresh)'*alpha(x,y),'b')
 hold on
 plot(squeeze(df_nomove(x,y,:)),'g')
 
 figure
 plot(squeeze(rawcycMap(x,y,:)));
end
    