BayesSDT Software Package

May-16-2007

From the paper "Lee, M.D. (submitted). BayesSDT: Software for Bayesian Inference with Signal Detection Theory."

There are 8 files in the package.

1. This readme file.
2. BayesSDT.m, the Matlab function that does the analysis. Use "help BayesSDT" to get details.
3. BayesSDT_GUI.m, the Matlab script that implements the Graphical User Interface.
4. arrow.m, a function from Matlab Central File Exchange for drawing the arrows on the GUI.
5. buttonselect.m, a function for handling the button presses in the GUI.
6. BayesSDT_v1.txt, the WinBUGS script for single data set analysis.
7. BayesSDT_v2.txt, the WinBUGS script for multiple data set analysis.
8. sampleD, a Matlab data file with one variable, D, as a starting example analysis using the data sets in the paper.

To get started with the GUI, put all the files in the same directory, make this the current directory for MATLAB, and run the MATLAB script by typing the command "BayesSDT_GUI" (without the quotation marks).

To get started with the general function, load the sample data in sampleD, by typing "load sampleD" (without the quotation marks) and then calling the function with "[samples stats] = BayesSDT(D)" (again, without the quotation marks).

Notes:

:: July-20-2007 Please use the latest version of WinBUGS (1.4.2. works). There is a backwards compatibility issue with version 1.4.0.

-- 
Michael D. Lee
Department of Cognitive Sciences
3151 Social Sciences Plaza A
University of California, Irvine, CA 92697-5100

Email: mdlee@uci.edu
URL: http://www.socsci.uci.edu/~mdlee/
Phone: (949) 824-5074
Fax: (949) 824-2307 