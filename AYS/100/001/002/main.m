% Univariate analysis of LRCP radiomic features to separate + vs -
Experiment.StartNewSection('Analysis');

% load features
vsFeatureValueCodes = ["FV-102-001-001","FV-102-001-002","FV-102-001-005","FV-102-001-006","FV-102-001-007","FV-102-001-008","FV-102-001-009"];
sLabelsCode = "LBL-101-001-001";

oFeatureValues = ExperimentManager.GetLabelledFeatureValues(...
    vsFeatureValueCodes,...
    sLabelsCode);

% analyze
vdPValuePerRadiomicFeature = zeros(1, oFeatureValues.GetNumberOfFeatures());

vbIsPositive = oFeatureValues.GetLabels() == oFeatureValues.GetPositiveLabel();

for dFeatureIndex=1:oFeatureValues.GetNumberOfFeatures()
    oFeature = oFeatureValues(:,dFeatureIndex);
    vdFeatureValues = oFeature.GetFeatures();
    vdPValuePerRadiomicFeature(dFeatureIndex) = ranksum(vdFeatureValues(vbIsPositive), vdFeatureValues(~vbIsPositive));
end

% Save p-values
FileIOUtils.SaveMatFile(fullfile(Experiment.GetResultsDirectory(), 'P-Values for VUMC- vs VUMC+ Per Radiomic Feature.mat'), ...
    'vdPValuePerRadiomicFeature', vdPValuePerRadiomicFeature);

[vdCorrelationCoefficientCutoffValues, m2bKeepRadiomicFeatureMasksPerCutoffPerFeature] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-100-002-001'), '01 Analysis', 'P-Values, Correlation Coefficients, and Removal Masks per Feature.mat'),...
    'vdCorrelationCoefficientCutoffValues', 'm2bKeepRadiomicFeatureMasksPerCutoffPerFeature');

dCutoff = 0.25;

vbNotVolumeCorrelated = m2bKeepRadiomicFeatureMasksPerCutoffPerFeature(vdCorrelationCoefficientCutoffValues == dCutoff,:);

disp("# features p<0.05: " + string(sum(vdPValuePerRadiomicFeature<0.05)));
disp("# features p<0.05 (not volume correlated @ 0.25): " + string(sum(vdPValuePerRadiomicFeature<0.05 & vbNotVolumeCorrelated)));
disp("# features p<0.05 (volume correlated @ 0.25):     " + string(sum(vdPValuePerRadiomicFeature<0.05 & ~vbNotVolumeCorrelated)));