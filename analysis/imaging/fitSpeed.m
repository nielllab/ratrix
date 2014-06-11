% function fitSpeed(fname);
% load(fname,'sp','dfof_bg');


dbstop if error
conv_range=10;
thresh =30;
sp_smooth = conv(sp,[zeros(conv_range+1,1); ones(conv_range,1)]/conv_range,'same');

figure
plot(sp);
hold on
plot(sp_smooth,'g')

dfof_bg=double(dfof_bg(:,:,1:length(sp)));

alpha = mean(dfof_bg(:,:,sp_smooth>thresh),3)-mean(dfof_bg(:,:,sp_smooth<thresh),3);
f= figure
imagesc(alpha);

%alpha_rep = repmat(alpha,[1 1 length(sp)]);
clear s
s(1,1,:) = sp_smooth>thresh;



df_nomove = dfof_bg - repmat(alpha,[1 1 length(sp)]).* repmat(s,[size(dfof_bg,1) size(dfof_bg,2) 1]);


[rawmap rawcycMap fullMov] =phaseMap(dfof_bg,10,10,1);
    rawmap(isnan(rawmap))=0;
   f=figure
   imshow(polarMap(rawmap));
   
   [rawmapnomove rawcycMapnomove fullMov] =phaseMap(df_nomove,10,10,1);
    rawmapnomove(isnan(rawmapnomove))=0;
   f=figure
   imshow(polarMap(rawmapnomove));

   dffig = figure
       imagesc(df_nomove(:,:,1));
   
   for i = 1:5
       figure(f)
       [y x] = ginput(1); x= round(x); y= round(y);
       figure
       plot(squeeze(df_nomove(x,y,:)));
       hold on
       plot(squeeze(dfof_bg(x,y,:)),'g');
       plot(0.4*sp/max(sp),'r')
   end

   t = 1:length(sp);
   tround = ceil((mod(t-1,100)+1)/10)
   
   warning off
   df = imresize(dfof_bg,0.5);
   
   betamap = zeros(size(df,1),size(df,2));
   alphamap = betamap;
   phasemap = betamap;
   ampmap = betamap;
  clear tcourse
  for t = 1:10;
       tcourse(t,:) = conv(double(tround==t),ones(10,1)/10,'same');
   end
%    tcourse(1,1:5)=1;
%    tcourse(10,95:100)=1;
   tcourse = tcourse-0.1;
   figure
   imagesc(tcourse)
       clear err b p
   for x = 1:size(df,1)
      x
      tic
      for y = 1:size(df,2)
          
           for beta = 1:10;
               
               resp = squeeze(df(x,y,:))';
               p(1,:) = double(sp_smooth>thresh);
               for t= 1:5;
                   p(1+t,:) = (1+ (beta/2)*double(sp_smooth>thresh)).*tcourse(t,:);
               end
               p(12,:)=1;
               [b{beta} bint r] = regress(resp',p');
               err(beta) = norm(r);
           end
           [m ind] = min(err);
           betamap(x,y) = (1+ (ind/4));
           alphamap(x,y) = b{ind}(1);
           [m ind] = max(b{beta}(2:11));
           phasemap(x,y) = ind;
          ampmap(x,y)=m- min(b{beta}(2:11));
      end
       toc
   end
   
 
   figure
   imagesc(betamap);
   title('beta = gain')
   figure
   imagesc(alphamap);
   title('alpha = running offset')
   figure
   imagesc(phasemap);
   title('response phase');
  f= figure
   imagesc(ampmap);
   title('response amplitude')
  
 
   
for i =1:10;
    figure(f)
    [y x] = ginput(1); x= round(x); y= round(y);
    figure
    plot(squeeze(dfof_bg(x,y,:))); hold on
    plot((sp_smooth>thresh)*alpha(x,y),'r');
     plot(squeeze(df_nomove(x,y,:)),'g');
     legend('raw','movment','no move')
 
   
     tic
     for beta = 1:10;
        
         resp = squeeze(dfof_bg(x,y,:))';
         p(1,:) = double(sp_smooth>thresh);
         for t= 1:10;
             p(1+t,:) = (1+ ((beta)/4)*double(sp_smooth>thresh)).*(double(tround==t)-0.1);
         end
         p(12,:)=1;
         [b{beta} bint r] = regress(resp',p');               
        err(beta) = norm(r);
     end
    toc
     [m ind] = min(err);
     params = b{ind}
     beta = (ind)/4
     
       figure
         plot(p'*params);
         hold on
         plot(resp,'g')

 figure
 plot(squeeze(rawcycMap(x,y,5:10:100)));
 hold on
 plot(squeeze(rawcycMapnomove(x,y,5:10:100)),'r');
 plot(params(2:11),'g')
end
    