Experiment.StartNewSection('Figures');

sExpCode_TrainVUMC_TestLRCP = "EXP-100-305-102";
sExpCode_TrainLRCP_TestVUMC = "EXP-100-405-102";

[vdROCX_TrainVUMC_TestLRCP, vdROCY_TrainVUMC_TestLRCP, dAUC_TrainVUMC_TestLRCP, dMCR_TrainVUMC_TestLRCP, dFNR_TrainVUMC_TestLRCP, dFPR_TrainVUMC_TestLRCP, dOptimalThresholdPointIndex_TrainVUMC_TestLRCP] = GenerateROCMetrics(sExpCode_TrainVUMC_TestLRCP);
[vdROCX_TrainLRCP_TestVUMC, vdROCY_TrainLRCP_TestVUMC, dAUC_TrainLRCP_TestVUMC, dMCR_TrainLRCP_TestVUMC, dFNR_TrainLRCP_TestVUMC, dFPR_TrainLRCP_TestVUMC, dOptimalThresholdPointIndex_TrainLRCP_TestVUMC] = GenerateROCMetrics(sExpCode_TrainLRCP_TestVUMC);

hFig = figure();
hold('on');
axis('square');

vdFigDims_cm = [8.6 6.6];

hFig.Units = 'centimeters';

vdPos = hFig.Position;
vdPos(3:4) = vdFigDims_cm;
hFig.Position = vdPos;

hChance = plot([0 1], [0, 1], '--k', 'LineWidth', 1.5);

hROC_TrainVUMC_TestLRCP = PlotROC(vdROCX_TrainVUMC_TestLRCP, vdROCY_TrainVUMC_TestLRCP, [0.5 0.5 0.5]);
hROC_TrainLRCP_TestVUMC = PlotROC(vdROCX_TrainLRCP_TestVUMC, vdROCY_TrainLRCP_TestVUMC, [0 0 0]);

PlotROCOperatingPoint(vdROCX_TrainVUMC_TestLRCP, vdROCY_TrainVUMC_TestLRCP, dOptimalThresholdPointIndex_TrainVUMC_TestLRCP, [0.5 0.5 0.5]);
PlotROCOperatingPoint(vdROCX_TrainLRCP_TestVUMC, vdROCY_TrainLRCP_TestVUMC, dOptimalThresholdPointIndex_TrainLRCP_TestVUMC, [0 0 0]);


ylim([0-0.01, 1+0.01]);
xlim([0-0.01, 1+0.01]);

xticks(0:0.1:1);
yticks(0:0.1:1);

grid('on');

ylabel('True Positive Rate');
xlabel('False Positive Rate');

hAxes = gca;

hAxes.FontSize = 8;
hAxes.FontName = 'Arial';



saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'ROCs Across Testing Configs (No Legend).svg'));

legend([hROC_TrainVUMC_TestLRCP, hROC_TrainLRCP_TestVUMC, hChance], "Train on VUMC, Test on LRCP", "Train on LRCP, Test on VUMC", "No Skill", "Location", 'southeast');

saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'ROCs Across Testing Configs (With Legend).svg'));
savefig(hFig, fullfile(Experiment.GetResultsDirectory(), 'ROCs Across Testing Configs.fig'));

close(hFig);

vsErrorMetricsHeaders = ["Features", "AUC", "MCR", "FNR", "FPR"];
vsErrorMetrics_TrainVUMC_TestLRCP = [...
    "Train on VUMC, Test on LRCP",...
    string(round(dAUC_TrainVUMC_TestLRCP,2)),... 
    string(round(100*dMCR_TrainVUMC_TestLRCP,1)),...
    string(round(100*dFNR_TrainVUMC_TestLRCP,1)),...
    string(round(100*dFPR_TrainVUMC_TestLRCP,1))];
vsErrorMetrics_TrainLRCP_TestVUMC = [...
    "Train on LRCP, Test on VUMC",...
    string(round(dAUC_TrainLRCP_TestVUMC,2)),... 
    string(round(100*dMCR_TrainLRCP_TestVUMC,1)),...
    string(round(100*dFNR_TrainLRCP_TestVUMC,1)),...
    string(round(100*dFPR_TrainLRCP_TestVUMC,1))];

disp([vsErrorMetricsHeaders; vsErrorMetrics_TrainVUMC_TestLRCP; vsErrorMetrics_TrainLRCP_TestVUMC]);


function [vdROCX, vdROCY, dAUC, dMCR, dFNR, dFPR, dPointIndexForOptThres] = GenerateROCMetrics(sExpCode)

sExpResultsPath = ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCode);

oTrainingOOBSamplesGuessResult = FileIOUtils.LoadMatFile(fullfile(sExpResultsPath, "02 Cutoff Evaluation", "Training Artifacts (3).mat"), "oOOBSamplesGuessResult");
oTestingSamplesGuessResult = FileIOUtils.LoadMatFile(fullfile(sExpResultsPath, "02 Cutoff Evaluation", "Testing Artifacts (3).mat"), "oTestingGuessResult");

vdTrainingOOBConfidences = oTrainingOOBSamplesGuessResult.GetPositiveLabelConfidences();
vbTrainingOOBIsPositive = oTrainingOOBSamplesGuessResult.GetLabels() == oTrainingOOBSamplesGuessResult.GetPositiveLabel();

[vdOOBX, vdOOBY, vdOOBT, dOOBAUC] = perfcurve(vbTrainingOOBIsPositive, vdTrainingOOBConfidences, true);

vdUpperLeftDist = (vdOOBX.^2) + ((1-vdOOBY).^2);
[~,dMinIndex] = min(vdUpperLeftDist);
dOptThres = vdOOBT(dMinIndex);

vdTestingConfidences = oTestingSamplesGuessResult.GetPositiveLabelConfidences();
vbTestingIsPositive = oTestingSamplesGuessResult.GetLabels() == oTestingSamplesGuessResult.GetPositiveLabel();

[vdROCX, vdROCY, vdROCT, dAUC] = perfcurve(vbTestingIsPositive, vdTestingConfidences, true);

[~,dPointIndexForOptThres] = min(abs(vdROCT - dOptThres));

% get FPR, FNR and MCR from ROC
dFPR = vdROCX(dPointIndexForOptThres,:); % since ROC
dTPR = vdROCY(dPointIndexForOptThres,:); % since ROC

dFNR = 1-dTPR; % by defn
dTNR = 1-dFPR; % by defn

dNumPositives = sum(vbTestingIsPositive);
dNumNegatives = sum(~vbTestingIsPositive);

dFP = dFPR * dNumNegatives; % by defn
dFN = dFNR * dNumPositives; % by defn

dMCR = (dFP + dFN) ./ (dNumPositives + dNumNegatives);


end

function hROC = PlotROC(vdROCX, vdROCY,  vdColour)

hROC = plot(vdROCX, vdROCY, '-', 'Color', vdColour, 'LineWidth', 2.5);

end

function PlotROCOperatingPoint(vdROCX, vdROCY, dOptimalThresholdPointIndex, vdColour)

plot(vdROCX(dOptimalThresholdPointIndex), vdROCY(dOptimalThresholdPointIndex), 'Marker', 'o', 'MarkerSize', 5, 'Color', vdColour, 'LineWidth',2.5, 'MarkerFaceColor', [1 1 1]);

end