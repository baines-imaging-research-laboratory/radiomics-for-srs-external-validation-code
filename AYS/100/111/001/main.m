Experiment.StartNewSection('Analysis');

sVUMCFeatureImportanceAnalysisCode = "AYS-100-100-002";
sLRCPFeatureImportanceAnalysisCode = "AYS-100-101-002";

vdNormalizedAverageFeatureScores_VUMC = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sVUMCFeatureImportanceAnalysisCode), '01 Analysis', 'Feature Importance.mat'),...
    'vdNormalizedAverageFeatureScores');

vdNormalizedAverageFeatureScores_LRCP = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sLRCPFeatureImportanceAnalysisCode), '01 Analysis', 'Feature Importance.mat'),...
    'vdNormalizedAverageFeatureScores');

vdFeatureImportanceScoreCutoffs = 0.05:0.05:0.95;
dNumCutoffs = length(vdFeatureImportanceScoreCutoffs);

m2bFeatureMaskPerCutoffPerFeature = false(dNumCutoffs, length(vdNormalizedAverageFeatureScores_VUMC));

for dCutoffIndex=1:dNumCutoffs
    m2bFeatureMaskPerCutoffPerFeature(dCutoffIndex,:) = vdNormalizedAverageFeatureScores_VUMC >= vdFeatureImportanceScoreCutoffs(dCutoffIndex) & vdNormalizedAverageFeatureScores_LRCP >= vdFeatureImportanceScoreCutoffs(dCutoffIndex);
end

FileIOUtils.SaveMatFile(...
    fullfile(Experiment.GetResultsDirectory(), "Feature Importance Masks.mat"),...
    'm2bFeatureMaskPerCutoffPerFeature', m2bFeatureMaskPerCutoffPerFeature,...
    'vdFeatureImportanceScoreCutoffs', vdFeatureImportanceScoreCutoffs);
