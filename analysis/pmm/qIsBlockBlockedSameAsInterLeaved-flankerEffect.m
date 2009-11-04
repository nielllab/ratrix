%compare blocked vs. paper rats



%subjects={'228','227','230','233','234','138','139'}; %in paper
%subjects={'228','227','230','233','234','138','139'}; %have blocked data post paper
%subjects={'227', '229', '230', '237', '232', '233'}; %many flank types, 5 contrasts
%subjects={'138','139', '228','277'}; %many flanks, one contrast  -- can these be directly compared to interleaved trials?


            
            
         %%
         
         analysisDate=datenum('12-Oct-2009');  %the day this was analayzed
         %%
         subjects={'138','139', '228','277'}; %many flanks, one contrast  -- can these be directly compared to interleaved trials?
         subjects={'139','138','228'}; %many flanks, one contrast  -- can these be directly compared to interleaved trials?
         dateRange= [pmmEvent('startBlocking10rats')+2 analysisDate];
         standardFlankerPaperPlot(14,subjects,dateRange);
         
         %%
         standardFlankerPaperPlot(4,{'139','138','228'},[]);  % like the pap
         
         %%  warning: this combines the effect for all contrasts, .25-->1.0
         
         %subjects={'227', '229', '230', '237', '232', '233'}; %many flank
         %types, 5 contrasts
         subjects={'233','227', '230'};  % removed rats not in main paper, '229', '237'', '232'
         dateRange= [pmmEvent('startBlocking10rats')+2 analysisDate];
         standardFlankerPaperPlot(15,subjects,dateRange);
         
         
         %%
         standardFlankerPaperPlot(4,subjects,[]);  % like the paper