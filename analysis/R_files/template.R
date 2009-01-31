library(PsychoFun) # Load routines

doplots <- TRUE

pth="xx"

d=dir(path=pth,pattern=".*.txt$")
for (f in d){
	fp <- paste(pth,"/",f,sep="")
	print(fp)	
	thisData<-read.table(fp, header=FALSE)
	print(thisData)
	
	SetUp <- PsychoSetUp(thisData,
xxInsertPriorHerexx)

# gamma(shape,scale)  (see http://en.wikipedia.org/wiki/Gamma_distribution)
# always > 0
# shape -- smaller = skewed more to the left
# scale -- smaller = bigger scale

SetUp
	
if (FALSE) {
	PlotPsychoPriors(SetUp)
}
	
# see http://www.kyb.mpg.de/publications/pdfs/pdf3170.pdf
# steps:
# 1) set sizeLeapfrog <- c(.001,.001,.001), numLeapfrog <- 100, numPts <- 100 
# 2) adjust each element of sizeLeapfrog individually to find a range that gives 60-90 percent acceptance
# 3) set all 3, find setting that keeps 60-90 percent acceptance
# 4) set numPts to desired qty of samples (including burnin)
# 5) check autocorrelations, increase numLeapfrog if necessary to reduce

#These xx'd out values will get overwritten	
sizeLeapfrog <- c(xx,xx,xx)
numLeapfrog <- xx
numPts <- xx
MCMCOutput <- MCMCSampling(SetUp, numPts, numLeapfrog, sizeLeapfrog)
	

	
	if (doplots) {
		PlotMCMCSamples(MCMCOutput)
		acf(MCMCOutput$Samples)
	}
	
	MCMC <- SummaryPsychoSamples(MCMCOutput, SetUp, makePlots = doplots)
	
	burnIn <- xx
	Samples <- MCMCOutput$Samples[-(1:burnIn),]
    AcceptRate <- MCMCOutput$AcceptRate

	#out <- paste("./outdata/",f,'.out',sep="")
	out <- paste("dataOut/",f,'.out.txt',sep="")
	print(out)

	write.table(MCMC,file=out,append=FALSE)
	write.table(Samples,file=out,append=TRUE)


	p <- format(SetUp)
	write.table(p,file=out,append=TRUE)
    write.table(AcceptRate,file=out,append=TRUE)
	dump(c("numPts","numLeapfrog","sizeLeapfrog"),file=out,append=TRUE)

}