function results=getSurgeryFields(conn,subjectID)

str=sprintf('select anchor_ap,anchor_ml,anchor_z,bregma_ap,bregma_ml,bregma_z from subjects where display_uin=''%s''',subjectID);
r=query(conn,str);

results=[];
if all(size(r)==[1 6])
    % replace emptys with nans
    for i=1:length(r)
        if isempty(r{i})
            r{i}=nan;
        end
    end
    results.anchorAP=r{1};
    results.anchorML=r{2};
    results.anchorZ=r{3};
    results.bregmaAP=r{4};
    results.bregmaML=r{5};
    results.bregmaZ=r{6};
else
%     warning('failed to get surgery fields');
end

end