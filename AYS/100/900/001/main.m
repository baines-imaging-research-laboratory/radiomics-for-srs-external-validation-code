Experiment.StartNewSection('Figures');

sExpCode_Radiomic_TrainVUMC_TestLRCP = "EXP-100-300-002";

sExpCode_Radiomic_COMBAT_TrainVUMC_TestLRCP = "EXP-100-310-002";

sExpCode_Radiomic_Consolidated_n1_TrainVUMC_TestLRCP = "EXP-100-305-102_1";
sExpCode_Radiomic_Consolidated_TrainVUMC_TestLRCP = "EXP-100-305-102";


sExpCode_Radiomic_TrainLRCP_TestVUMC = "EXP-100-400-002";

sExpCode_Radiomic_COMBAT_TrainLRCP_TestVUMC = "EXP-100-410-002";

sExpCode_Radiomic_Consolidated_n1_TrainLRCP_TestVUMC = "EXP-100-405-102_1";
sExpCode_Radiomic_Consolidated_TrainLRCP_TestVUMC = "EXP-100-405-102";


m2dAUCValuesPerCentreSetupPerExperiment = zeros(2, 1+1+10); % 3 (clin, radio, clin+radio), 1 (radio w/ COMBAT), 9 (radio w/ consolidated features)

m2dAUCValuesPerCentreSetupPerExperiment(1,1) = GetAUCForExperiment(sExpCode_Radiomic_TrainVUMC_TestLRCP);

m2dAUCValuesPerCentreSetupPerExperiment(1,2) = GetAUCForExperiment(sExpCode_Radiomic_COMBAT_TrainVUMC_TestLRCP);

m2dAUCValuesPerCentreSetupPerExperiment(1,3) = GetAUCsForConsolidatedFeatureExperiment_n1(sExpCode_Radiomic_Consolidated_n1_TrainVUMC_TestLRCP);
m2dAUCValuesPerCentreSetupPerExperiment(1,4:end) = GetAUCsForConsolidatedFeaturesExperiment(sExpCode_Radiomic_Consolidated_TrainVUMC_TestLRCP);



m2dAUCValuesPerCentreSetupPerExperiment(2,1) = GetAUCForExperiment(sExpCode_Radiomic_TrainLRCP_TestVUMC);

m2dAUCValuesPerCentreSetupPerExperiment(2,2) = GetAUCForExperiment(sExpCode_Radiomic_COMBAT_TrainLRCP_TestVUMC);

m2dAUCValuesPerCentreSetupPerExperiment(2,3) = GetAUCsForConsolidatedFeatureExperiment_n1(sExpCode_Radiomic_Consolidated_n1_TrainLRCP_TestVUMC);
m2dAUCValuesPerCentreSetupPerExperiment(2,4:end) = GetAUCsForConsolidatedFeaturesExperiment(sExpCode_Radiomic_Consolidated_TrainLRCP_TestVUMC);


vdFigDims_cm = [12.3, 6.59];

[hFig, hLegend] = CreateBarGraph(...
    [m2dAUCValuesPerCentreSetupPerExperiment(:,1)'; [0 0]; m2dAUCValuesPerCentreSetupPerExperiment(:,2)'; [0 0]; m2dAUCValuesPerCentreSetupPerExperiment(:,3:end)'] ,...
    ["Original", " ", "COMBAT", " ", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],...
    'FontSize', 8, 'FontName', 'Arial',...
    'TexturePerVariable', ["Solid", "Solid"],...
    'BarColourPerVariable', {[1 1 1] [0 0 0]},...
    'GroupVisibility', [true false true false true true true true true true true true true true],...
    'XLabel', "",...
    'YLabel', "AUC",...
    'YTicks', 0:0.1:0.7, 'YLim', [0 0.71],...
    'FigureSize', vdFigDims_cm, 'FigureSizeUnits', 'centimeters',...
    'FillFigure', false,...
    'LegendVariableNames', ["Test Dataset: B" "Test Dataset: A"]);

hFig.Children.YMinorGrid = 'on';

saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'AUCs bar chart for train on centre, test on other centre.svg'));
saveas(hLegend, fullfile(Experiment.GetResultsDirectory(), 'AUCs bar chart legend for train on centre, test on other centre.svg'));


function dAUC = GetAUCForExperiment(sExpCode)
oTestingGuessResult = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCode), '03 Model Testing', 'Testing Artifacts.mat'),...
    'oTestingGuessResult');

dAUC = ErrorMetricsCalculator.CalculateAUC(oTestingGuessResult, 'JournalingOn', false);

end

function vdAUCs = GetAUCsForConsolidatedFeaturesExperiment(sExpCode)

vdNumFeatures = 2:10;
vdAUCs = zeros(length(vdNumFeatures),1);

for dNumFeaturesIndex=1:length(vdNumFeatures)    
    oTestingGuessResult = FileIOUtils.LoadMatFile(...
        fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCode), '02 Cutoff Evaluation', "Testing Artifacts (" + string(vdNumFeatures(dNumFeaturesIndex)) + ").mat"),...
        'oTestingGuessResult');
    
    vdAUCs(dNumFeaturesIndex) = ErrorMetricsCalculator.CalculateAUC(oTestingGuessResult, 'JournalingOn', false);
end



end

function dAUC = GetAUCsForConsolidatedFeatureExperiment_n1(sExpCode)

    oTestingGuessResult = FileIOUtils.LoadMatFile(...
        fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCode), '02 Cutoff Evaluation', "Testing Artifacts (1).mat"),...
        'oTestingGuessResult');
    
    dAUC = ErrorMetricsCalculator.CalculateAUC(oTestingGuessResult, 'JournalingOn', false);
end