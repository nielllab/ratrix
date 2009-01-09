function [samples stats]=BayesSDT(D);

% Bayesian Inference For Six Equal-Variance Gaussian Signal Detection Theory Parameters
%
% [samples stats] = BayesSDT(D)
%
% D is a structured variable, with the following fields
%
% D.ndatasets is the number of data sets to be analyzed.
% D.sdt. This is a matrix with the rows representing data sets, and the columns representing signal detection data counts. The four columns correspond to hits, false alarms, misses, and correct rejections respectively.
% D.nsamples is the number of posterior samples to generate.
% D.nbins is the number of bins to use in drawing histograms of the posterior densities.
% D.labels is a character array with a string label for each dataset.
% D.linecolor is a character array with a Matlab color for each data set, using the standard Matlab plot colors.
% D.linestyle is a character array with a Matlab color for each data set, using the standard Matlab line styles.
% D.linewidth is an array of positive numbers containing line widths for each data set.
% D.dcheck is a vector of 0 and 1 entries for each data set, indicating whether or not the d parameter should be analyzed.
% D.hcheck is a vector of 0 and 1 entries for each data set, indicating whether or not the h parameter should be analyzed.
% D.fcheck is a vector of 0 and 1 entries for each data set, indicating whether or not the f parameter should be analyzed.
% D.kcheck is a vector of 0 and 1 entries for each data set, indicating whether or not the k parameter should be analyzed.
% D.ccheck is a vector of 0 and 1 entries for each data set, indicating whether or not the c parameter should be analyzed.
% D.bcheck is a vector of 0 and 1 entries for each data set, indicating whether or not the b parameter should be analyzed.
%
% samples is a structured variable returning the posterior samples for each parameter
% stats is a structured variable with basic descriptive statistics for the posterior samples of each parameter
%
% see also: BayesSDT_GUI
%
% Michael D. Lee, mdlee [at] uci.edu, May-16-2007

% --------------------------
% RUN WINBUGS TO DO SAMPLING
% --------------------------

% Initial Values
S.d = zeros(D.ndatasets,1);
S.c = zeros(D.ndatasets,1);
init0 = S;

% Call WinBUGS For Either Single Or Multiple Datasets
switch D.ndatasets
	case 1,
		% Data to Supply to WinBugs
		datastruct = struct('H',D.sdt(:,1),'F',D.sdt(:,2),'M',D.sdt(:,3),'C',D.sdt(:,4));
		% Sample!
		[samples, stats, structarray] = matbugs(datastruct, ...
			fullfile(pwd, 'BayesSDT_v1.txt'), ...
			'init', init0, ...
			'nChains', 1, ...
			'view', 0, 'nburnin', 0, 'nsamples', D.nsamples, ...
			'thin', 1, 'DICstatus', 0, 'refreshrate',10, ...
			'monitorParams', {'d','c','h','f','b','k'}, ...
			'Bugdir', 'C:/Program Files/WinBUGS14');
	otherwise
		datastruct = struct('H',D.sdt(:,1),'F',D.sdt(:,2),'M',D.sdt(:,3),'C',D.sdt(:,4),'NDATASETS',D.ndatasets);
		[samples, stats, structarray] = matbugs(datastruct, ...
			fullfile(pwd, 'BayesSDT_v2.txt'), ...
			'init', init0, ...
			'nChains', 1, ...
			'view', 0, 'nburnin', 0, 'nsamples', D.nsamples, ...
			'thin', 1, 'DICstatus', 0, 'refreshrate',10, ...
			'monitorParams', {'d','c','h','f','b','k'}, ...
			'Bugdir', 'C:/Program Files/WinBUGS14');
end;

% Read Back Samples
d=squeeze(samples.d);
c=squeeze(samples.c);
h=squeeze(samples.h);
f=squeeze(samples.f);
k=squeeze(samples.k);
b=squeeze(samples.b);

% ------------
% DRAW RESULTS
% ------------

% Discriminability
% Plot Densities
if sum(D.dcheck)~=0 % If at least one dataset needs to draw d
	figure(1);clf;hold on;
	for i=1:D.ndatasets
		if D.dcheck~=0 % If this dataset needs to draw d
			switch D.ndatasets
				case 1
					maxd(i)=max(d);
					mind(i)=min(d);
				otherwise
					maxd(i)=max(d(:,i));
					mind(i)=min(d(:,i));
			end;
			step=(maxd(i)-mind(i))/(D.nbins);
			binsedge=[mind(i):step:maxd(i)];
			bins=[mind(i)+step/2:step:maxd(i)-step/2];
			switch D.ndatasets
				case 1
					count=histc(d,binsedge);
				otherwise
					count=histc(d(:,i),binsedge);
			end;
			count=count(1:end-1); % strange behavior of histc
			ph=plot(bins,count/sum(count(:)),'k-');
            
			set(ph,'color',(D.linecolor(i,:)));
			set(ph,'linestyle',(D.linestyle{i}));
			set(ph,'linewidth',D.linewidth(i));
		end; % if flag
	end; % for i
% Tidy Up
set(gca,'fontsize',14,'box','on','ytick',[]);
xlabel('Discriminability (d)','fontsize',16);
ylabel('Posterior Density','fontsize',16);
if D.ndatasets>1
	[lh oh]=legend(D.labels,'location','best');
end;
end; % if sum

% Hit Rate
% Plot Densities
if sum(D.hcheck)~=0 % If at least one dataset needs to draw h
	figure(2);clf;hold on;
	for i=1:D.ndatasets
		if D.hcheck(i)~=0 % If this dataset needs to draw h
			step=1/(D.nbins);
			binsedge=[0:step:1];
			bins=[step/2:step:1];
			switch D.ndatasets
				case 1
					count=histc(h,binsedge);
				otherwise
					count=histc(h(:,i),binsedge);
			end;
			count=count(1:end-1); % strange behavior of histc
			ph=plot(bins,count/sum(count(:)),'k-');
			set(ph,'color',(D.linecolor(i,:)));
			set(ph,'linestyle',(D.linestyle{i}));
			set(ph,'linewidth',D.linewidth(i));
		end; % if flag
	end; % for i
% Tidy Up
set(gca,'fontsize',14,'box','on','ytick',[]);
xlabel('Hit Rate (h)','fontsize',16);
ylabel('Posterior Density','fontsize',16);
if D.ndatasets>1
	[lh oh]=legend(D.labels,'location','best');
end;
end; % if sum

% False Alarm Rate
% Plot Densities
if sum(D.fcheck)~=0 % If at least one dataset needs to draw f
	figure(3);clf;hold on;
	for i=1:D.ndatasets
		if D.fcheck(i)~=0 % If this dataset needs to draw f
			step=1/(D.nbins);
			binsedge=[0:step:1];
			bins=[step/2:step:1];
			switch D.ndatasets
				case 1
					count=histc(f,binsedge);
				otherwise
					count=histc(f(:,i),binsedge);
			end;
			count=count(1:end-1); % strange behavior of histc
			ph=plot(bins,count/sum(count(:)),'k-');
            set(ph,'color',(D.linecolor(i,:)));
			set(ph,'linestyle',(D.linestyle{i}));
			set(ph,'linewidth',D.linewidth(i));
		end; % if flag
	end; % for i
% Tidy Up
set(gca,'fontsize',14,'box','on','ytick',[]);
xlabel('False Alarm Rate (f)','fontsize',16);
ylabel('Posterior Density','fontsize',16);
if D.ndatasets>1
	[lh oh]=legend(D.labels,'location','best');
end;
end; % if sum

% Bias k
% Plot Densities
if sum(D.kcheck)~=0 % If at least one dataset needs to draw k
	figure(4);clf;hold on;
	for i=1:D.ndatasets
		if D.kcheck(i)~=0 % If this dataset needs to draw k
			switch D.ndatasets
				case 1
					maxk(i)=max(k);
					mink(i)=min(k);
				otherwise
					maxk(i)=max(k(:,i));
					mink(i)=min(k(:,i));
			end;
			step=(maxk(i)-mink(i))/(D.nbins);
			binsedge=[mink(i):step:maxk(i)];
			bins=[mink(i)+step/2:step:maxk(i)-step/2];
			switch D.ndatasets
				case 1
					count=histc(k,binsedge);
				otherwise
					count=histc(k(:,i),binsedge);
			end;
			count=count(1:end-1); % strange behavior of histc
			ph=plot(bins,count/sum(count(:)),'k-');
            set(ph,'color',(D.linecolor(i,:)));
			set(ph,'linestyle',(D.linestyle{i}));
			set(ph,'linewidth',D.linewidth(i));
		end; % if flag
	end; % for i
% Tidy Up
set(gca,'fontsize',14,'box','on','ytick',[]);
xlabel('Criterion (k)','fontsize',16);
ylabel('Posterior Density','fontsize',16);
if D.ndatasets>1
	[lh oh]=legend(D.labels,'location','best');
end;
end; % if sum

% Bias c
% Plot Densities
if sum(D.ccheck)~=0 % If at least one dataset needs to draw c
	figure(5);clf;hold on;
	for i=1:D.ndatasets
		if D.ccheck~=0 % If this dataset needs to draw c
			switch D.ndatasets
				case 1
					maxc(i)=max(c);
					minc(i)=min(c);
				otherwise
					maxc(i)=max(c(:,i));
					minc(i)=min(c(:,i));
			end;
			step=(maxc(i)-minc(i))/(D.nbins);
			binsedge=[minc(i):step:maxc(i)];
			bins=[minc(i)+step/2:step:maxc(i)-step/2];
			switch D.ndatasets
				case 1
					count=histc(c,binsedge);
				otherwise
					count=histc(c(:,i),binsedge);
			end;
			count=count(1:end-1); % strange behavior of histc
			ph=plot(bins,count/sum(count(:)),'k-');
            set(ph,'color',(D.linecolor(i,:)));
			set(ph,'linestyle',(D.linestyle{i}));
			set(ph,'linewidth',D.linewidth(i));
		end; % if flag
	end; % for i
% Tidy Up
set(gca,'fontsize',14,'box','on','ytick',[]);
xlabel('Bias (c)','fontsize',16);
ylabel('Posterior Density','fontsize',16);
if D.ndatasets>1
	[lh oh]=legend(D.labels,'location','best');
end;
end; % if sum



% Bias b
% Plot Densities
if sum(D.bcheck)~=0 % If at least one dataset needs to draw b
	figure(6);clf;hold on;
	for i=1:D.ndatasets
		if D.bcheck(i)~=0 % If this dataset needs to draw b
			switch D.ndatasets
				case 1
					maxb(i)=max(b);
					minb(i)=min(b);
				otherwise
					maxb(i)=max(b(:,i));
					minb(i)=min(b(:,i));
			end;
			step=(maxb(i)-minb(i))/(D.nbins);
			binsedge=[minb(i):step:maxb(i)];
			bins=[minb(i)+step/2:step:maxb(i)-step/2];
			switch D.ndatasets
				case 1
					count=histc(b,binsedge);
				otherwise
					count=histc(b(:,i),binsedge);
			end;
			count=count(1:end-1); % strange behavior of histc
			ph=plot(bins,count/sum(count(:)),'k-');
            set(ph,'color',(D.linecolor(i,:)));
			set(ph,'linestyle',(D.linestyle{i}));
			set(ph,'linewidth',D.linewidth(i));
		end; % if flag
	end; % for i
% Tidy Up
set(gca,'fontsize',14,'box','on','ytick',[]);
xlabel('Bias (b)','fontsize',16);
ylabel('Posterior Density','fontsize',16);
if D.ndatasets>1
	[lh oh]=legend(D.labels,'location','best');
end;
end; % if sum