function out=stationOKForStimManager(stimManager,s)
    if isa(s,'station')
        shortest_img_list = Inf;
        for i=1:length(stimManager.trialDistribution)
            list = stimManager.trialDistribution{i};
            num_imgs = length(list{1});
            if num_imgs < shortest_img_list
                shortest_img_list = num_imgs;
            end
        end
        out = getNumPorts(s)<=1+shortest_img_list;
    else
        error('need a station object')
    end
    
end % end function