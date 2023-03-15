Experiment.StartNewSection('Loading Experiment Assets');

% load experiment asset codes
[...
    vsClinicalFeatureValueCodes_Training, vsRadiomicFeatureValueCodes_Training, sLabelsCode_Training,...
    vsClinicalFeatureValueCodes_Testing, vsRadiomicFeatureValueCodes_Testing, sLabelsCode_Testing,...
    sModelCode, sHPOCode, sObjFcnCodeForHPO, sFeatureSelectorCode] = ...
    ExperimentManager.LoadExperimentManifestCodesMatFile();

% load experiment assets
[oClinicalDataSet_Training, oRadiomicDataSet_Training] = LoadDataSets(vsClinicalFeatureValueCodes_Training, vsRadiomicFeatureValueCodes_Training, sLabelsCode_Training);
[oClinicalDataSet_Testing, oRadiomicDataSet_Testing] = LoadDataSets(vsClinicalFeatureValueCodes_Testing, vsRadiomicFeatureValueCodes_Testing, sLabelsCode_Testing);

oOFN = ExperimentManager.Load(sObjFcnCodeForHPO); % OOB Samples AUC
oFS = ExperimentManager.Load(sFeatureSelectorCode); % Correlation Filter
oHPO = ExperimentManager.Load(sHPOCode); % Custom Bayesian HPO
oMDL = ExperimentManager.Load(sModelCode); % Random decision forest

[m2bFeatureMaskPerCutoffPerFeature, vdNumberOfFeaturesPerCutoff] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-100-111-101'), "01 Analysis", "Feature Importance Masks.mat"),...
    'm2bFeatureMaskPerCutoffPerFeature',...
    'vdNumberOfFeaturesPerCutoff');

vdNumberOfFeaturesCutoffsToRun = 1;
dNumCutoffsToRun = length(vdNumberOfFeaturesCutoffsToRun);

Experiment.EndCurrentSection();


Experiment.StartNewSection('Cutoff Evaluation');

vdAUCPerCutoff = zeros(dNumCutoffsToRun,1);


dNumberOfFeaturesAtCutoff = 1;

vbCutoffMask = m2bFeatureMaskPerCutoffPerFeature(vdNumberOfFeaturesPerCutoff == dNumberOfFeaturesAtCutoff, :);

% Train model

if ~isempty(oRadiomicDataSet_Training)
    
    if ~isempty(oClinicalDataSet_Training)
        oTrainingDataSet = [oRadiomicDataSet_Training, oClinicalDataSet_Training];
    else
        oTrainingDataSet = oRadiomicDataSet_Training;
    end
else
    vbRadiomicFeatureMask = [];
    
    oTrainingDataSet = oClinicalDataSet_Training;
end

oTrainingDataSet = oTrainingDataSet(:,vbCutoffMask);

% - Perform hyper-parameter optimization
oHyperParameterOptimizer = oHPO.CreateHyperParameterOptimizer(oOFN, oTrainingDataSet);
oClassifier = oMDL.CreateModel(oHyperParameterOptimizer, 'JournalingOn', false);
dHyperParameterOptimizationAUC = 1 - oClassifier.GetHyperParameterOptimizer().GetObjectiveFunctionValueAtOptimalHyperParameters();

% - Train and evaluate classifier
oRNG = RandomNumberGenerator();

oRNG.PreLoopSetup(1);
oRNG.PerLoopIndexSetup(1);

oTrainedClassifier = oClassifier.Train(oTrainingDataSet, 'JournalingOn', false);
oOOBSamplesGuessResult = oTrainedClassifier.GuessOnOutOfBagSamples();

oRNG.PerLoopIndexTeardown;
oRNG.PostLoopTeardown;

% - Save artifacts to disk
FileIOUtils.SaveMatFile(...
    fullfile(Experiment.GetResultsDirectory(), ['Training Artifacts (', num2str(round(dNumberOfFeaturesAtCutoff,2)), ').mat']),...
    'vbFeatureImportanceCutoffMask', vbCutoffMask,...
    'oTrainedClassifier', oTrainedClassifier,...
    'dHyperParameterOptimizationAUC', dHyperParameterOptimizationAUC,...
    'oTrainedClassifier', oTrainedClassifier,...
    'vdFeatureImportanceScores', oTrainedClassifier.GetFeatureImportanceFromOutOfBagSamples(),...
    'oOOBSamplesGuessResult', oOOBSamplesGuessResult,...
    '-v7', '-nocompression');





% Test model
if ~isempty(oRadiomicDataSet_Testing)
    if ~isempty(oClinicalDataSet_Testing)
        oTestingDataSet = [oRadiomicDataSet_Testing, oClinicalDataSet_Testing];
    else
        oTestingDataSet = oRadiomicDataSet_Testing;
    end
else
    oTestingDataSet = oClinicalDataSet_Testing;
end

oTestingDataSet = oTestingDataSet(:,vbCutoffMask);

% - Perform testing
oTestingGuessResult = oTrainedClassifier.Guess(oTestingDataSet);

% - Calculate error metrics
vdAUCPerCutoff(1) = ErrorMetricsCalculator.CalculateAUC(oTestingGuessResult, 'JournalingOn', false);

% - Save guess result
FileIOUtils.SaveMatFile(...
    fullfile(Experiment.GetResultsDirectory(), ['Testing Artifacts (', num2str(round(dNumberOfFeaturesAtCutoff,2)), ').mat']),...
    'oTestingGuessResult', oTestingGuessResult,...
    '-v7', '-nocompression');



for dCutoffIndex=1:dNumCutoffsToRun
    dNumberOfFeaturesAtCutoff = vdNumberOfFeaturesCutoffsToRun(dCutoffIndex);
    
    Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel(...
        ['Cut-off ' num2str(round(dNumberOfFeaturesAtCutoff,2))],...
        num2str(vdAUCPerCutoff(dCutoffIndex))));
end

Experiment.EndCurrentSection();


function [oClinicalDataSet, oRadiomicDataSet] = LoadDataSets(vsClinicalFeatureValueCodes, vsRadiomicFeatureValueCodes, sLabelsCode)

oClinicalDataSet = ExperimentManager.GetLabelledFeatureValues(...
    vsClinicalFeatureValueCodes,...
    sLabelsCode);

oRadiomicDataSet = ExperimentManager.GetLabelledFeatureValues(...
    vsRadiomicFeatureValueCodes,...
    sLabelsCode);

end