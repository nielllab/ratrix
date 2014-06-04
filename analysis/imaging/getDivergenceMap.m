function divmap =  getDivergenceMap(topomap);
 for m = 1:2

        map = topomap{m};
        map_all{m} = map;
        ph = angle(map);
       % keyboard
        ph(ph<0) = ph(ph<0)+2*pi;
        
        amp = abs(map);
        
        [dx dy] = gradient(ph);
        grad = dx + sqrt(-1)*dy;
        grad_amp = abs(grad);
        
        dx(grad_amp>1)=0; dy(grad_amp>1)=0;
       dx = medfilt2(dx,[3 3]); dy = medfilt2(dy, [3 3]);
        
        grad = dx + sqrt(-1)*dy;   
           
        absnorm = abs(grad);       
        absnorm(absnorm==0)=10^6;
        norm_grad{m} = grad./absnorm;   
  
        div{m} = divergence(real(norm_grad{m}),imag(norm_grad{m}));
   end
    
   divmap = abs(div{1})+abs(div{2});