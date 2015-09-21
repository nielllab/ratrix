%do cycavg deconvolution for each individual animal using pts file
for n = 1:size(cycavg,4)
    for area = 1:length(areanames)
        for s = 1:6
            if s==1
                d = squeeze(mean(mean(cycavg(x(area)+range,y(area)+range,1:25,n),2),1));
                repd = repmat(d,[10 1]);
                dconvd = deconvg6s(repd'+0.5,0.1);
                dcon = dconvd(:,6*length(d):(7*length(d)-1));
                dcon = dcon - min(dcon);
                d = d - min(d);
                indcycavg(1:25,n,area,i) = d;
                inddeconcycavg(1:25,n,area,i) = dcon';
            elseif s==2
                d = squeeze(mean(mean(cycavg(x(area)+range,y(area)+range,26:50,n),2),1));
                repd = repmat(d,[10 1]);
                dconvd = deconvg6s(repd'+0.5,0.1);
                dcon = dconvd(:,6*length(d):(7*length(d)-1));
                dcon = dcon - min(dcon);
                d = d - min(d);
                indcycavg(26:50,n,area,i) = d;
                inddeconcycavg(26:50,n,area,i) = dcon';
            elseif s==3
                d = squeeze(mean(mean(cycavg(x(area)+range,y(area)+range,26:50,n),2),1)) - squeeze(mean(mean(cycavg(x(area)+range,y(area)+range,1:25,n),2),1));
                repd = repmat(d,[10 1]);
                dconvd = deconvg6s(repd'+0.5,0.1);
                dcon = dconvd(:,6*length(d):(7*length(d)-1));
                dcon = dcon - min(dcon);
                d = d - min(d);
                indcycavg(51:75,n,area,i) = d;
                inddeconcycavg(51:75,n,area,i) = dcon';
            elseif s==4
                d = squeeze(mean(mean(cycavg(x(area)+range,y(area)+range,51:75,n),2),1));
                repd = repmat(d,[10 1]);
                dconvd = deconvg6s(repd'+0.5,0.1);
                dcon = dconvd(:,6*length(d):(7*length(d)-1));
                dcon = dcon - min(dcon);
                d = d - min(d);
                indcycavg(76:100,n,area,i) = d;
                inddeconcycavg(76:100,n,area,i) = dcon';
            elseif s==5
                d = squeeze(mean(mean(cycavg(x(area)+range,y(area)+range,76:100,n),2),1));
                repd = repmat(d,[10 1]);
                dconvd = deconvg6s(repd'+0.5,0.1);
                dcon = dconvd(:,6*length(d):(7*length(d)-1));
                dcon = dcon - min(dcon);
                d = d - min(d);
                indcycavg(101:125,n,area,i) = d;
                inddeconcycavg(101:125,n,area,i) = dcon';
            elseif s==6
                d = squeeze(mean(mean(cycavg(x(area)+range,y(area)+range,76:100,n),2),1)) - squeeze(mean(mean(cycavg(x(area)+range,y(area)+range,51:75,n),2),1));
                repd = repmat(d,[10 1]);
                dconvd = deconvg6s(repd'+0.5,0.1);
                dcon = dconvd(:,6*length(d):(7*length(d)-1));
                dcon = dcon - min(dcon);
                d = d - min(d);
                indcycavg(126:150,n,area,i) = d;
                inddeconcycavg(126:150,n,area,i) = dcon';
            end            
        end
    end
end