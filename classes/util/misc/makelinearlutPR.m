function linlut=makelinearlutPR;
% hard wired function by Pam to invert measured monitor input/output
% and save a new hardwired inverted lut
makeplots=0; 

%sample values from FE992_LM_Tests2_070111.smr: (actually logged them: pmm 070403) -used physiology graphic card
sent=       [0      0.0667    0.1333    0.2000    0.2667    0.3333    0.4000    0.4667    0.5333  0.6000    0.6667    0.7333    0.8000    0.8667    0.9333    1.0000];
measured_R= [0.0034 0.0046    0.0077    0.0128    0.0206    0.0309    0.0435    0.0595    0.0782  0.1005    0.1260    0.1555    0.189     0.227     0.268     0.314 ];
measured_G= [0.0042 0.0053    0.0073    0.0110    0.0167    0.0245    0.0345    0.047     0.063   0.081     0.103     0.127     0.156     0.187     0.222     0.260 ];
measured_B= [0.0042 0.0051    0.0072    0.0105    0.0160    0.0235    0.033     0.0445    0.0595  0.077     0.097     0.120     0.1465    0.176     0.208     0.244 ];

bitdepth=8;
linlut=zeros(2^bitdepth,3);
R= (measured_R-min(measured_R)); R=R/max(R); % scale from 0 to 1
G= (measured_G-min(measured_G)); G=G/max(G);
B= (measured_B-min(measured_B)); B=B/max(B);  

if makeplots,
    figure, subplot(311), plot(sent,R,'ro-'), hold on
    subplot(312), plot(sent,G,'go-'), hold on
    subplot(313), plot(sent,B,'bo-'), hold on
end

linlut(1,1:3)=[0 0 0]; % by definition  
linlut(256,1:3)=[1 1 1]; % by definition 

for i=2:2^bitdepth-1, % for every desired lum btwn 0 and 1
    desired_lum=(i-1)/255;
    % find the two measured values bracketing your point and linearly
    % interpolate to get the correct sent value for the desired output
    Rbelow=max(find(R<=desired_lum)); Rabove=Rbelow+1;
    P=polyfit(R([Rbelow Rabove]), sent([Rbelow Rabove]),1); 
    linlut(i,1)=polyval(P,desired_lum);
    if makeplots, subplot(311), plot( linlut(i,1),desired_lum,'r.'),end
    
    
    % same for G gun
    Gbelow=max(find(G<desired_lum)); Gabove=Gbelow+1;
    P=polyfit(G([Gbelow Gabove]), sent([Gbelow Gabove]),1); 
    linlut(i,2)=polyval(P,desired_lum);
    if makeplots, subplot(312), plot(linlut(i,1),desired_lum,'g.'), end

    % same for B gun
    Bbelow=max(find(B<desired_lum));Babove=Bbelow+1;
    P=polyfit(B([Bbelow Babove]), sent([Bbelow Babove]),1);  
    linlut(i,3)=polyval(P,desired_lum);
    if makeplots, subplot(313), plot(linlut(i,3),desired_lum,'b.'), end
end

    
%save linlutPR linlut
