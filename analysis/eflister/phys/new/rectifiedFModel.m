function data=rectifiedFModel(ts,f0,f1,harmonics)
if size(harmonics,2)~=2
    error('need amp and phase for each optional harmonic -- harmoincs should be n x 2')
end

data=f0*ones(size(ts));

for i=1:size(harmonics,1)
    data=data + harmonics(i,1)*sin(ts*i*f1*2*pi  + harmonics(i,2));
end
data(data<0)=0;
end