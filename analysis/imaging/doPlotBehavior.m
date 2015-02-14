%%% doPlotBehavior

load('/backup/compiled behavior/mapOverlay.mat'); %load reference map


%load learning subjects data ('allsubj', 'shiftBehav', 'alldata', 'numTrialsPercond' )
% learnSub(1) = load('/home/nlab/ratrix/analysis/imaging/first pass analysis 012015/0.4 - 0.75 resp/g62j8lt.mat');
% learnSub(2) = load('/home/nlab/ratrix/analysis/imaging/first pass analysis 012015/0.4 - 0.75 resp/G62m1lt.mat');
% learnSub(3) = load('/home/nlab/ratrix/analysis/imaging/first pass analysis 012015/0.4 - 0.75 resp/G62l1lt.mat');

learnSub(1) = load('/home/nlab/ratrix/analysis/imaging/first pass analysis 012015/0.4 - 0.6 resp/g62j8lt.mat');
learnSub(2) = load('/home/nlab/ratrix/analysis/imaging/first pass analysis 012015/0.4 - 0.6 resp/g62m1lt.mat');
%learnSub(3) = load('/home/nlab/ratrix/analysis/imaging/first pass analysis 012015/0.4 - 0.6 resp/g62l1lt.mat');



i=1; % which learnSub
j=1; % which day of behavior
k=1; %which behavior condition 1:4
labels = {'correct','incorrect','left','right' 'all trials'}; %condition labels



%compute average response over early and late learning
for i = 1:length(learnSub) %for each subject loaded up
%figure
for k=1 %:4 %cycle through conditions 
  na = 0; nb=0; nc=0; avgbehavEarly=0; avgbehavLate=0; avgbehavAll=0; b=[];c=[]; last=length(learnSub(i).shiftBehav);
      %initialize counts for trial totals for relevent conditions 
        sum_conditionE = 0; sum_totalE = 0; sum_allE = 0;sum_conditionL = 0; sum_totalL = 0; sum_allL = 0; sum_conditionAll = 0; sum_totalAll = 0; sum_allAll = 0;
        
  
    for j=(last-2):last %Compute Avg for earliest 3 sessions within a behavior subject
        
    if ~isempty(learnSub(i).shiftBehav{j}{k})
        b = learnSub(i).shiftBehav{j}{k};
        avgbehavEarly = avgbehavEarly+b(:,:,:);
        nb= nb+1; 
                  %make count for trials of Early sessions      
        scE= learnSub(i).numTrialsPercond{j}{k}; %sum trials that fit criteria for each condition
        stE = learnSub(i).numTrialsPercond{j}{1}+learnSub(i).numTrialsPercond{j}{2}; %sum total trials within set time window
        all_trialsE = learnSub(i).numTrialsPercond{j}{5};%sum total trials any time respons
        
        sum_conditionE = sum_conditionE +scE;
        sum_totalE = sum_totalE + stE;
        sum_allE = sum_allE + all_trialsE;
    end 
    end
    
    for j =1:3 %Comput Avg for last 3 sessions within a behavior subject
        
    if ~isempty(learnSub(i).shiftBehav{j}{k})
        c = learnSub(i).shiftBehav{j}{k};
        avgbehavLate = avgbehavLate+c(:,:,:);
        nc= nc+1;  
                          %make count for trials of Late sessions      
        scL= learnSub(i).numTrialsPercond{j}{k}; %sum trials that fit criteria for each condition
        stL = learnSub(i).numTrialsPercond{j}{1}+learnSub(i).numTrialsPercond{j}{2}; %sum total trials within set time window
        all_trialsL = learnSub(i).numTrialsPercond{j}{5};%sum total trials any time respons
        
        sum_conditionL = sum_conditionL +scL;
        sum_totalL = sum_totalL + stL;
        sum_allL = sum_allL + all_trialsL;
    end 
    end
    
    for j=1:last %Compute Avg all sessions within a behavior subject
        
    if ~isempty(learnSub(i).shiftBehav{j}{k})
        b = learnSub(i).shiftBehav{j}{k};
        avgbehavAll = avgbehavAll+b(:,:,:);
        na= na+1; 
                  %make count for trials of Early sessions      
        scAll= learnSub(i).numTrialsPercond{j}{k}; %sum trials that fit criteria for each condition
        stAll = learnSub(i).numTrialsPercond{j}{1}+learnSub(i).numTrialsPercond{j}{2}; %sum total trials within set time window
        all_trialsAll = learnSub(i).numTrialsPercond{j}{5};%sum total trials any time respons
        
        sum_conditionAll = sum_conditionAll +scAll;
        sum_totalAll = sum_totalAll + stAll;
        sum_allAll = sum_allAll + all_trialsAll;
    end 
    end    
 
avgbehavAll = avgbehavAll/na;
avgbehavAllCond{i}{k} = avgbehavAll;
    
avgbehavEarly = avgbehavEarly/nb;
avgbehavEarlyCond{i}{k} = avgbehavEarly;

avgbehavLate = avgbehavLate/nc;
avgbehavLateCond{i}{k} = avgbehavLate;
    
  figure('name', [learnSub(i).allsubj{1}  labels{k} ' average Early sessions(3)' ] )
        for t= 1:6  %for time = 100ms(t=8) to 600ms(t=13) post stim onset plot session activity
                subplot(2,3,t); 
                data = (squeeze(avgbehavEarlyCond{i}{k}(:,:,t+7)));
                h= imshow(mat2im(data,jet,[0 0.20]));
                hold on
                plot(ypts,xpts,'w.','Markersize',1);
                set(gca,'LooseInset',get(gca,'TightInset')) 
        end
             title([num2str(sum_conditionE) ' of ' num2str(sum_totalE) ' of ' num2str(sum_allE) ]);
 

          figure('name', [learnSub(i).allsubj{1}  labels{k} ' average Late sessions(3)' ] )
        for t= 1:6  %for time = 100ms(t=8) to 600ms(t=13) post stim onset plot session activity
                subplot(2,3,t); 
                data = (squeeze(avgbehavLateCond{i}{k}(:,:,t+7)));
                h= imshow(mat2im(data,jet,[0 0.20]));
                hold on
                plot(ypts,xpts,'w.','Markersize',1);
                set(gca,'LooseInset',get(gca,'TightInset')) 
        end
             title([num2str(sum_conditionL) ' of ' num2str(sum_totalL) ' of ' num2str(sum_allL) ]);
     
          figure('name', [learnSub(i).allsubj{1}  labels{k} ' average All sessions(' num2str(last) ')' ] )
        for t= 1:6  %for time = 100ms(t=8) to 600ms(t=13) post stim onset plot session activity
                subplot(2,3,t); 
                data = (squeeze(avgbehavAllCond{i}{k}(:,:,t+7)));
                h= imshow(mat2im(data,jet,[0 0.20]));
                hold on
                plot(ypts,xpts,'w.','Markersize',1);
                set(gca,'LooseInset',get(gca,'TightInset')) 
        end
             title([num2str(sum_conditionAll) ' of ' num2str(sum_totalAll) ' of ' num2str(sum_allAll) ]);     
 
end;
end;



%plots 3 timepoints for each session each animal
for i = 1:length(learnSub) %for each subject loaded up
%figure
for k=1 %:4 %cycle through conditions  
for j = 1:length(learnSub(i).shiftBehav) %for each session within a behavior subject
   if ~isnan (learnSub(i).shiftBehav{j}{k}(1,1)) 
    figure('name', [learnSub(i).allsubj{1}  labels{k} ' session' num2str(j) ] )

    for t= 1:3  %for time = 300ms(t=10) to 500ms(t=12) post stim onset plot session activity
        subplot(1,3,t); 
        data = (squeeze(learnSub(i).shiftBehav{j}{k}(:,:,t+9)));
        h= imshow(mat2im(data,jet,[0 0.20]));
        hold on
        plot(ypts,xpts,'w.','Markersize',1);
        set(gca,'LooseInset',get(gca,'TightInset')) 
    end
    
    elseif  isnan (learnSub(i).shiftBehav{j}{k}(1,1))
      sprintf ('no trials meet criteria')
      sprintf([learnSub(i).allsubj{1}  labels{k} ' session' num2str(j) ] )
   end  
title([num2str(learnSub(i).numTrialsPercond{j}{k}) ' of ' num2str(learnSub(i).numTrialsPercond{j}{1}+learnSub(i).numTrialsPercond{j}{2}) ' of ' num2str(learnSub(i).numTrialsPercond{j}{5}) ])
        
end;
end
end; 


%plots 6 timepoints for each session each animal
for i = 1:length(learnSub) %for each subject loaded up
%figure
for k=1 %:4 %cycle through conditions  
    
for j = 1:length(learnSub(i).shiftBehav) %for each session within a behavior subject
  if ~isnan (learnSub(i).shiftBehav{j}{k}(1,1)) 
    figure('name', [learnSub(i).allsubj{1}  labels{k} ' session' num2str(j)] )

    for t= 1:6  %for time = 100ms(t=8) to 600ms?(t=13) post stim onset plot session activity
        subplot(2,3,t); 
        data = (squeeze(learnSub(i).shiftBehav{j}{k}(:,:,t+7)));
        h= imshow(mat2im(data,jet,[0 0.20]));
        hold on
        plot(ypts,xpts,'w.','Markersize',1);
        set(gca,'LooseInset',get(gca,'TightInset')) 
    end
  elseif  isnan (learnSub(i).shiftBehav{j}{k}(1,1))
      sprintf ('no trials meet criteria')
      sprintf([learnSub(i).allsubj{1}  labels{k} ' session' num2str(j) ] )
   end
%title([learnSub(i).allsubj  labels{k} ' session' j] )
title([num2str(learnSub(i).numTrialsPercond{j}{k}) ' of ' num2str(learnSub(i).numTrialsPercond{j}{1}+learnSub(i).numTrialsPercond{j}{2}) ' of ' num2str(learnSub(i).numTrialsPercond{j}{5}) ])
 
end;
end;
end; 


%single timepoint of each session for given animal
for k=1 %:4 %cycle through conditions  
for i = 1:length(learnSub) 
figure ('name',[learnSub(i).allsubj{1} ' ' labels{k}, ' all sessions' ] )

for j = 1:length(learnSub(i).shiftBehav)
  if ~isnan (learnSub(i).shiftBehav{j}{k}(1,1)) 
    subplot(ceil((length(learnSub(i).shiftBehav)+1)/4),4,j+1);
    data = (squeeze(learnSub(i).shiftBehav{j}{k}(:,:,10)));
    h= imshow(mat2im(data,jet,[0 0.20]));
    hold on
    plot(ypts,xpts,'w.','Markersize',1);
    axis off
    title([num2str(learnSub(i).numTrialsPercond{j}{k}) ' of ' num2str(learnSub(i).numTrialsPercond{j}{1}+learnSub(i).numTrialsPercond{j}{2}) ' of ' num2str(learnSub(i).numTrialsPercond{j}{5}) ])
    set(gca,'LooseInset',get(gca,'TightInset'))
  elseif  isnan (learnSub(i).shiftBehav{j}{k}(1,1))
      sprintf ('no trials meet criteria')
      sprintf([learnSub(i).allsubj{1}  labels{k} ' session' num2str(j) ] )
    end
end

    subplot(ceil((length(learnSub(i).shiftBehav)+1)/4),4,1);
    data = (squeeze(avgbehavAllCond{i}{k}(:,:,10)));
    h= imshow(mat2im(data,jet,[0 0.20]));
    hold on
    plot(ypts,xpts,'w.','Markersize',1);
    axis off
    title('average map')
    set(gca,'LooseInset',get(gca,'TightInset'))

end;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plots 3 timepoints for each session on 1 graph each animal
for i = 1:length(learnSub) %for each subject loaded up
figure ('name',[learnSub(i).allsubj{1} labels{k}]);

    for j = 1:length(learnSub(i).shiftBehav)  %for each session within a behavior subject
       
     if ~isnan (learnSub(i).shiftBehav{j}{k}(1,1))    
        for t= 1:3  %for time = 300ms(t=10) to 500ms(t=12) post stim onset plot session activity    
            tj= (t)+((j-1)*3); %index subplot with correct value 
            subplot(length(learnSub(i).shiftBehav)+1,3,tj);
            data = (squeeze(learnSub(i).shiftBehav{j}{k}(:,:,t+9)));
            h= imshow(mat2im(data,jet,[0 0.20]));
            hold on
            %plot(ypts,xpts,'w.','Markersize',1);
            axis off
            set(gca,'LooseInset',get(gca,'TightInset'))
                                if t == 3
                     text(0.5, 1, ['          ' num2str(learnSub(i).numTrialsPercond{j}{k}) ' trials']) 
                     text(1, 1, sprintf(['\n\n          ' num2str(learnSub(i).numTrialsPercond{j}{k}/(learnSub(i).numTrialsPercond{j}{1}+learnSub(i).numTrialsPercond{j}{2}),2)]));
                                end 
        end
  elseif  isnan (learnSub(i).shiftBehav{j}{k}(1,1))
      sprintf ('no trials meet criteria')
      sprintf([learnSub(i).allsubj{1}  labels{k} ' session' num2str(j) ] )
    end
    end;
          %plot average of trials for all sessions (could do early or late 2)
            for t= 1:3  %for time = 100ms(t=8) to 600ms(t=12) post stim onset plot session activity    
                tj= (t)+((j)*3); %index subplot with correct value 
                subplot(length(learnSub(i).shiftBehav)+1,3,tj);
                data = (squeeze(avgbehavAllCond{i}{k}(:,:,t+9)));
                h= imshow(mat2im(data,jet,[0 0.20]));
                hold on
                %plot(ypts,xpts,'w.','Markersize',1);
                axis off
                set(gca,'LooseInset',get(gca,'TightInset'))
            end
    text(1,1,'          avg') 
  %  title([learnSub(i).allsubj labels{k}]);
end;


%plots 6 timepoints for each session on 1 graph each animal
for i = 1:length(learnSub) %for each subject loaded up
figure ('name',[learnSub(i).allsubj{1} labels{k}]);

    for j = 1:length(learnSub(i).shiftBehav)  %for each session within a behavior subject
       
     if ~isnan (learnSub(i).shiftBehav{j}{k}(1,1))    
        for t= 1:6  %for time = 100ms(t=8) to 600ms(t=12) post stim onset plot session activity    
            tj= (t)+((j-1)*6); %index subplot with correct value 
            subplot(length(learnSub(i).shiftBehav)+1,6,tj);
            data = (squeeze(learnSub(i).shiftBehav{j}{k}(:,:,t+7)));
            h= imshow(mat2im(data,jet,[0 0.20]));
            hold on
            %plot(ypts,xpts,'w.','Markersize',1);
            axis off
            set(gca,'LooseInset',get(gca,'TightInset'))
                if t == 6
                     text(0.5, 1, ['          ' num2str(learnSub(i).numTrialsPercond{j}{k}) ' trials']);
                     text(1, 1, sprintf(['\n\n          ' num2str(learnSub(i).numTrialsPercond{j}{k}/(learnSub(i).numTrialsPercond{j}{1}+learnSub(i).numTrialsPercond{j}{2}),2)]));
                end     
        end
  elseif  isnan (learnSub(i).shiftBehav{j}{k}(1,1))
      sprintf ('no trials meet criteria')
      sprintf([learnSub(i).allsubj{1}  labels{k} ' session' num2str(j) ] )
     end;
    end; 
        %plot average of trials for all sessions (could do early or late 2)
            for t= 1:6  %for time = 100ms(t=8) to 600ms(t=12) post stim onset plot session activity    
                tj= (t)+((j)*6); %index subplot with correct value 
                subplot(length(learnSub(i).shiftBehav)+1,6,tj);
                data = (squeeze(avgbehavAllCond{i}{k}(:,:,t+7)));
                h= imshow(mat2im(data,jet,[0 0.20]));
                hold on
                %plot(ypts,xpts,'w.','Markersize',1);
                axis off
                set(gca,'LooseInset',get(gca,'TightInset'))
            end
                text(1,1,'          avg')    
end; 



%%%%%%%%%%%%%%%%%
%GTS vs HvV

%load each task
% Task(1) = load('/home/nlab/ratrix/analysis/imaging/first pass analysis 012015/0.4 - 0.75 resp/GTS_wo_learning.mat');
% Task(2) = load('/home/nlab/ratrix/analysis/imaging/first pass analysis 012015/0.4 - 0.75 resp/HvV.mat');
% Task(3) = load('/home/nlab/ratrix/analysis/imaging/first pass analysis 012015/0.4 - 0.75 resp/naive.mat');
% Task(4) = load('/home/nlab/ratrix/analysis/imaging/first pass analysis 012015/0.4 - 0.75 resp/HvV_center.mat');

Task(1) = load('/home/nlab/ratrix/analysis/imaging/first pass analysis 012015/0.4 - 0.6 resp/GTS_wo_learning.mat');
Task(2) = load('/home/nlab/ratrix/analysis/imaging/first pass analysis 012015/0.4 - 0.6 resp/HvV.mat');
Task(3) = load('/home/nlab/ratrix/analysis/imaging/first pass analysis 012015/0.4 - 0.6 resp/naive.mat');
Task(4) = load('/home/nlab/ratrix/analysis/imaging/first pass analysis 012015/0.4 - 0.6 resp/HvV_center.mat');
Task(5) = load('/home/nlab/ratrix/analysis/imaging/first pass analysis 012015/0.4 - 0.6 resp/GTS_wo_learning_noG628lt.mat');


TaskLabels = {'GTS','HvV','naive','HvV_center', 'GTS_no_g628lt'};


n=1; %task condition


        
        
        
%plot time sequence of each task

for n=1:length(Task)
 
for k=1 %:4 %cycle through conditions (correct, incorrect, left, rigt, totaltrials)  
    figure ('name',[labels{k} ' ' TaskLabels{n}])
    %initialize counts for trial totals for relevent conditions 
        sum_condition = 0; sum_total = 0; sum_all = 0;
    
     for j=1:length(Task(n).numTrialsPercond) %for each included session     

        if isnan(Task(n).numTrialsPercond{j}{k}); %take out NaNs first, these shouldnt be generated in future
            Task(n).numTrialsPercond{j}{k}=0;
        end;
        if isnan (Task(n).numTrialsPercond{j}{1});
            Task(n).numTrialsPercond{j}{1}=0;
        end;
        if isnan (Task(n).numTrialsPercond{j}{2});
            Task(n).numTrialsPercond{j}{2}=0;
        end;
        
          %make count for trials of each condition      
        sc= Task(n).numTrialsPercond{j}{k}; %sum trials that fit criteria for each condition
        st = Task(n).numTrialsPercond{j}{1}+Task(n).numTrialsPercond{j}{2}; %sum total trials within set time window
        all_trials = Task(n).numTrialsPercond{j}{5};%sum total trials any time respons
        
        sum_condition = sum_condition +sc;
        sum_total = sum_total + st;
        sum_all = sum_all + all_trials;
     end;
     
    for t= 1:6  %timepoints t=0 to t =500ms
        subplot(2,3,t);
        data = squeeze(Task(n).alldata{1}{k}(:,:,t+7));
        h = imshow(mat2im(data,jet,[0 0.20]));
        hold on
        plot(ypts,xpts,'w.','Markersize',1);
        axis off
        set(gca,'LooseInset',get(gca,'TightInset'))
    end;
%title([labels{k} ' ' TaskLabels{n}])
 title([num2str(sum_condition) ' of ' num2str(sum_total) ' of ' num2str(sum_all) ]);
        
end;
end;

