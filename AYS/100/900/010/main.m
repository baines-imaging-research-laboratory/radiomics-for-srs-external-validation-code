Experiment.StartNewSection('Figures');

sExpCode_Clinical = "EXP-100-300-001";
sExpCode_Radiomic = "EXP-100-310-002";
sExpCode_ClinicalAndRadiomic = "EXP-100-310-003";

[vdROCX_ClinicalOnly, vdROCY_ClinicalOnly, dAUC_ClinicalOnly, dMCR_ClinicalOnly, dFNR_ClinicalOnly, dFPR_ClinicalOnly, dOptimalThresholdPointIndex_ClinicalOnly] = GenerateROCMetrics(sExpCode_Clinical);
[vdROCX_RadiomicsOnly, vdROCY_RadiomicsOnly, dAUC_RadiomicsOnly, dMCR_RadiomicsOnly, dFNR_RadiomicsOnly, dFPR_RadiomicsOnly, dOptimalThresholdPointIndex_RadiomicsOnly] = GenerateROCMetrics(sExpCode_Radiomic);
[vdROCX_ClinicalAndRadiomic, vdROCY_ClinicalAndRadiomic, dAUC_ClinicalAndRadiomic, dMCR_ClinicalAndRadiomic, dFNR_ClinicalAndRadiomic, dFPR_ClinicalAndRadiomic, dOptimalThresholdPointIndex_ClinicalAndRadiomic] = GenerateROCMetrics(sExpCode_ClinicalAndRadiomic);

hFig = figure();
hold('on');
axis('square');

vdFigDims_cm = [8.6 6.6];

hFig.Units = 'centimeters';

vdPos = hFig.Position;
vdPos(3:4) = vdFigDims_cm;
hFig.Position = vdPos;

hChance = plot([0 1], [0, 1], '--k', 'LineWidth', 1.5);

%hROC_ClincalOnly = PlotROC(vdROCX_ClinicalOnly, vdROCY_ClinicalOnly, [0.75 0.75 0.75]);
hROC_RadiomicOnly = PlotROC(vdROCX_RadiomicsOnly, vdROCY_RadiomicsOnly, [0.5 0.5 0.5]);
%hROC_ClinicalAndRadiomic = PlotROC(vdROCX_ClinicalAndRadiomic, vdROCY_ClinicalAndRadiomic, [0 0 0]);

%PlotROCOperatingPoint(vdROCX_ClinicalOnly, vdROCY_ClinicalOnly, dOptimalThresholdPointIndex_ClinicalOnly, [0.75 0.75 0.75]);
PlotROCOperatingPoint(vdROCX_RadiomicsOnly, vdROCY_RadiomicsOnly, dOptimalThresholdPointIndex_RadiomicsOnly, [0.5 0.5 0.5]);
%PlotROCOperatingPoint(vdROCX_ClinicalAndRadiomic, vdROCY_ClinicalAndRadiomic, dOptimalThresholdPointIndex_ClinicalAndRadiomic, [0 0 0]);


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



saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'ROCs Across Available Features (No Legend).svg'));

legend([hROC_RadiomicOnly], "Radiomic ", "Location", 'southeast');

saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'ROCs Across Available Features (With Legend).svg'));
savefig(hFig, fullfile(Experiment.GetResultsDirectory(), 'ROCs Across Available Features.fig'));

close(hFig);

vsErrorMetricsHeaders = ["Features", "AUC", "MCR", "FNR", "FPR"];
vsErrorMetricsClinicalOnly = [...
    "Clinical Only",...
    string(round(dAUC_ClinicalOnly,2)),... 
    string(round(100*dMCR_ClinicalOnly,1)),...
    string(round(100*dFNR_ClinicalOnly,1)),...
    string(round(100*dFPR_ClinicalOnly,1))];
vsErrorMetricsRadiomicsOnly = [...
    "Radiomics Only",...
    string(round(dAUC_RadiomicsOnly,2)),... 
    string(round(100*dMCR_RadiomicsOnly,1)),...
    string(round(100*dFNR_RadiomicsOnly,1)),...
    string(round(100*dFPR_RadiomicsOnly,1))];
vsErrorMetricsClinicalAndRadiomic = [...
    "Clinical & Radiomics",...
    string(round(dAUC_ClinicalAndRadiomic,2)),... 
    string(round(100*dMCR_ClinicalAndRadiomic,1)),...
    string(round(100*dFNR_ClinicalAndRadiomic,1)),...
    string(round(100*dFPR_ClinicalAndRadiomic,1))];

disp([vsErrorMetricsHeaders; vsErrorMetricsClinicalOnly; vsErrorMetricsRadiomicsOnly; vsErrorMetricsClinicalAndRadiomic]);


function [vdROCX, vdROCY, dAUC, dMCR, dFNR, dFPR, dPointIndexForOptThres] = GenerateROCMetrics(sExpCode)

sExpResultsPath = ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCode);

oTrainingOOBSamplesGuessResult = FileIOUtils.LoadMatFile(fullfile(sExpResultsPath, "02 Model Training", "Training Artifacts.mat"), "oOOBSamplesGuessResult");
oTestingSamplesGuessResult = FileIOUtils.LoadMatFile(fullfile(sExpResultsPath, "03 Model Testing", "Testing Artifacts.mat"), "oTestingGuessResult");

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