Experiment.StartNewSection('Experiment Assets');

% load features values
oFV_VUMC = ExperimentManager.Load('FV-102-001-001');
oFeatureValues_VUMC = oFV_VUMC.GetFeatureValues();

oFV_LRCP = ExperimentManager.Load('FV-004-002-001A');
oFeatureValues_LRCP = oFV_LRCP.GetFeatureValues();


% harmonize features using COMBAT

m2dFeatures_VUMC = oFeatureValues_VUMC.GetFeatures();
m2dFeatures_LRCP = oFeatureValues_LRCP.GetFeatures();

vdCentrePerSample = [repmat(1,oFeatureValues_VUMC.GetNumberOfSamples(),1); repmat(2,oFeatureValues_LRCP.GetNumberOfSamples(),1)];

bIsParametric = false;
m2dHarmonizedData = (combat([m2dFeatures_VUMC; m2dFeatures_LRCP]', vdCentrePerSample', [], bIsParametric))';

m2dHarmonizedFeatures_LRCP = m2dHarmonizedData(oFeatureValues_VUMC.GetNumberOfSamples()+1:end,:);

oRecord = CustomFeatureExtractionRecord("FV-004-102-001A", "Applying non-parametric per centre COMBAT harmonization", m2dHarmonizedFeatures_LRCP);

oFeatureValues = FeatureValuesByValue(...
    m2dHarmonizedFeatures_LRCP,...
    oFeatureValues_LRCP.GetGroupIds(), oFeatureValues_LRCP.GetSubGroupIds(), oFeatureValues_LRCP.GetUserDefinedSampleStrings(),...
    oFeatureValues_LRCP.GetFeatureNames() + " (COMBAT Harmonized)",...
    'FeatureExtractionRecord', oRecord);

oFV = ExperimentFeatureValues("FV-004-102-001A");

oFV.SaveFeatureValuesAsMat(oFeatureValues);
oFV.Save();