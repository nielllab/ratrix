function doTimeHists(r)
for i=1:size(r.serverRegister,1)
subplot(size(r.serverRegister,1),1,i)
    hist(r.serverRegister{i,4},50)
    
end
