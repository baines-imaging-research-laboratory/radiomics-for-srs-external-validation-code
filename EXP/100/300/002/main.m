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

Experiment.EndCurrentSection();




% Train model
Experiment.StartNewSection('Model Training');

if ~isempty(oRadiomicDataSet_Training)
    % - Correlation filter
    oFeatureFilter = oFS.CreateFeatureSelector();
    oFeatureFilter.SelectFeatures(oRadiomicDataSet_Training, 'JournalingOn', true);
    vbRadiomicFeatureMask = oFeatureFilter.GetFeatureMask();
    
    % - Apply correlation filter to training dataset
    oRadiomicDataSet_Training = oRadiomicDataSet_Training(:,vbRadiomicFeatureMask);

    if ~isempty(oClinicalDataSet_Training)
        oTrainingDataSet = [oRadiomicDataSet_Training, oClinicalDataSet_Training];
    else
        oTrainingDataSet = oRadiomicDataSet_Training;
    end
else
    vbRadiomicFeatureMask = [];

    oTrainingDataSet = oClinicalDataSet_Training;
end
    
% - Perform hyper-parameter optimization
oHyperParameterOptimizer = oHPO.CreateHyperParameterOptimizer(oOFN, oTrainingDataSet);
oClassifier = oMDL.CreateModel(oHyperParameterOptimizer, 'JournalingOn', true);
dHyperParameterOptimizationAUC = 1 - oClassifier.GetHyperParameterOptimizer().GetObjectiveFunctionValueAtOptimalHyperParameters();

% - Train and evaluate classifier
oRNG = RandomNumberGenerator();

oRNG.PreLoopSetup(1);
oRNG.PerLoopIndexSetup(1);

oTrainedClassifier = oClassifier.Train(oTrainingDataSet, 'JournalingOn', true);
oOOBSamplesGuessResult = oTrainedClassifier.GuessOnOutOfBagSamples();

oRNG.PerLoopIndexTeardown;
oRNG.PostLoopTeardown;

% - Save artifacts to disk
FileIOUtils.SaveMatFile(...
    fullfile(Experiment.GetResultsDirectory(), 'Training Artifacts.mat'),...
    'vbRadiomicFeatureMask', vbRadiomicFeatureMask,...
    'oTrainedClassifier', oTrainedClassifier,...
    'dHyperParameterOptimizationAUC', dHyperParameterOptimizationAUC,...
    'oTrainedClassifier', oTrainedClassifier,...
    'vdFeatureImportanceScores', oTrainedClassifier.GetFeatureImportanceFromOutOfBagSamples(),...
    'oOOBSamplesGuessResult', oOOBSamplesGuessResult,...
    '-v7', '-nocompression');

Experiment.EndCurrentSection();




% Test model
Experiment.StartNewSection('Model Testing');

if ~isempty(oRadiomicDataSet_Testing)
    % - Apply training data set correlation filter mask to testing set
    oRadiomicDataSet_Testing = oRadiomicDataSet_Testing(:,vbRadiomicFeatureMask);

    if ~isempty(oClinicalDataSet_Testing)
        oTestingDataSet = [oRadiomicDataSet_Testing, oClinicalDataSet_Testing];
    else
        oTestingDataSet = oRadiomicDataSet_Testing;
    end
else
    oTestingDataSet = oClinicalDataSet_Testing;
end

% - Perform testing
oTestingGuessResult = oTrainedClassifier.Guess(oTestingDataSet);

% - Calculate error metrics
ErrorMetricsCalculator.CalculateAUC(oTestingGuessResult, 'JournalingOn', true);

% - Save guess result
FileIOUtils.SaveMatFile(...
    fullfile(Experiment.GetResultsDirectory(), 'Testing Artifacts.mat'),...
    'oTestingGuessResult', oTestingGuessResult,...
    '-v7', '-nocompression');

Experiment.EndCurrentSection();


function [oClinicalDataSet, oRadiomicDataSet] = LoadDataSets(vsClinicalFeatureValueCodes, vsRadiomicFeatureValueCodes, sLabelsCode)

oClinicalDataSet = ExperimentManager.GetLabelledFeatureValues(...
    vsClinicalFeatureValueCodes,...
    sLabelsCode);

oRadiomicDataSet = ExperimentManager.GetLabelledFeatureValues(...
    vsRadiomicFeatureValueCodes,...
    sLabelsCode);

end