% Univariate analysis of VUMC and LRCP radiomic features to separate VUMC
% vs LRCP
Experiment.StartNewSection('Analysis');

% load features
vsFeatureValueCodes_VUMC = ["FV-102-001-001","FV-102-001-002","FV-102-001-005","FV-102-001-006","FV-102-001-007","FV-102-001-008","FV-102-001-009"];
sLabelsCode_VUMC = "LBL-101-001-001";

oFeatureValues_VUMC = ExperimentManager.GetLabelledFeatureValues(...
    vsFeatureValueCodes_VUMC,...
    sLabelsCode_VUMC);


vsFeatureValueCodes_LRCP = ["FV-004-002-001A","FV-004-002-002A","FV-004-002-005A","FV-004-002-006A","FV-004-002-007A","FV-004-002-008A","FV-004-002-009A"];
sLabelsCode_LRCP = "LBL-002-002-001A";

oFeatureValues_LRCP = ExperimentManager.GetLabelledFeatureValues(...
    vsFeatureValueCodes_LRCP,...
    sLabelsCode_LRCP);


% analyze
vdCentrePValuePerRadiomicFeature = zeros(1, oFeatureValues_VUMC.GetNumberOfFeatures());
vdLabelPValuePerRadiomicFeature = zeros(1, oFeatureValues_VUMC.GetNumberOfFeatures());

vbIsPositive = [...
    oFeatureValues_VUMC.GetLabels() == oFeatureValues_VUMC.GetPositiveLabel();
    oFeatureValues_LRCP.GetLabels() == oFeatureValues_LRCP.GetPositiveLabel()];

for dFeatureIndex=1:oFeatureValues_VUMC.GetNumberOfFeatures()
    oFeature_VUMC = oFeatureValues_VUMC(:,dFeatureIndex);
    vdFeatureValues_VUMC = oFeature_VUMC.GetFeatures();
    
    oFeature_LRCP = oFeatureValues_LRCP(:,dFeatureIndex);
    vdFeatureValues_LRCP = oFeature_LRCP.GetFeatures();
    
    vdCentrePValuePerRadiomicFeature(dFeatureIndex) = ranksum(vdFeatureValues_VUMC, vdFeatureValues_LRCP);
    
    vdFeatureValues = [vdFeatureValues_VUMC; vdFeatureValues_LRCP];
    
    vdLabelPValuePerRadiomicFeature(dFeatureIndex) = ranksum(vdFeatureValues(vbIsPositive), vdFeatureValues(~vbIsPositive));
end




% Save p-values
FileIOUtils.SaveMatFile(fullfile(Experiment.GetResultsDirectory(), 'P-Values for VUMC vs LRCP Per Radiomic Feature.mat'), ...
    'vdCentrePValuePerRadiomicFeature', vdCentrePValuePerRadiomicFeature,...
    'vdLabelPValuePerRadiomicFeature', vdLabelPValuePerRadiomicFeature);

[vdCorrelationCoefficientCutoffValues_VUMC, m2bKeepRadiomicFeatureMasksPerCutoffPerFeature_VUMC] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-100-002-001'), '01 Analysis', 'P-Values, Correlation Coefficients, and Removal Masks per Feature.mat'),...
    'vdCorrelationCoefficientCutoffValues', 'm2bKeepRadiomicFeatureMasksPerCutoffPerFeature');

[vdCorrelationCoefficientCutoffValues_LRCP, m2bKeepRadiomicFeatureMasksPerCutoffPerFeature_LRCP] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-100-002-002'), '01 Analysis', 'P-Values, Correlation Coefficients, and Removal Masks per Feature.mat'),...
    'vdCorrelationCoefficientCutoffValues', 'm2bKeepRadiomicFeatureMasksPerCutoffPerFeature');

dCutoff = 0.25;

vbVolumeCorrelated_VUMC = ~m2bKeepRadiomicFeatureMasksPerCutoffPerFeature_VUMC(vdCorrelationCoefficientCutoffValues_VUMC == dCutoff,:);
vbVolumeCorrelated_LRCP = ~m2bKeepRadiomicFeatureMasksPerCutoffPerFeature_LRCP(vdCorrelationCoefficientCutoffValues_LRCP == dCutoff,:);

vbVolumeCorrelated = vbVolumeCorrelated_VUMC | vbVolumeCorrelated_LRCP;

disp("# features p<0.05: " + string(sum(vdCentrePValuePerRadiomicFeature<0.05)));
disp("# features p<0.05 (not volume correlated @ 0.25): " + string(sum(vdCentrePValuePerRadiomicFeature<0.05 & ~vbVolumeCorrelated)));
disp("# features p<0.05 (volume correlated @ 0.25):     " + string(sum(vdCentrePValuePerRadiomicFeature<0.05 & vbVolumeCorrelated)));