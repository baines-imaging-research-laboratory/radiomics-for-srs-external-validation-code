Experiment.StartNewSection('Experiment Assets');

% load features values
oFV_VUMC = ExperimentManager.Load('FV-102-001-002');
oFeatureValues_VUMC = oFV_VUMC.GetFeatureValues();

oFV_LRCP = ExperimentManager.Load('FV-004-002-002A');
oFeatureValues_LRCP = oFV_LRCP.GetFeatureValues();


% harmonize features using COMBAT

m2dFeatures_VUMC = oFeatureValues_VUMC.GetFeatures();
m2dFeatures_LRCP = oFeatureValues_LRCP.GetFeatures();

vdCentrePerSample = [repmat(1,oFeatureValues_VUMC.GetNumberOfSamples(),1); repmat(2,oFeatureValues_LRCP.GetNumberOfSamples(),1)];

bIsParametric = false;
m2dHarmonizedData = (combat([m2dFeatures_VUMC; m2dFeatures_LRCP]', vdCentrePerSample', [], bIsParametric))';

m2dHarmonizedFeatures_VUMC = m2dHarmonizedData(1:oFeatureValues_VUMC.GetNumberOfSamples(),:);

oRecord = CustomFeatureExtractionRecord("FV-102-101-002", "Applying non-parametric per centre COMBAT harmonization", m2dHarmonizedFeatures_VUMC);

oFeatureValues = FeatureValuesByValue(...
    m2dHarmonizedFeatures_VUMC,...
    oFeatureValues_VUMC.GetGroupIds(), oFeatureValues_VUMC.GetSubGroupIds(), oFeatureValues_VUMC.GetUserDefinedSampleStrings(),...
    oFeatureValues_VUMC.GetFeatureNames() + " (COMBAT Harmonized)",...
    'FeatureExtractionRecord', oRecord);

oFV = ExperimentFeatureValues("FV-102-101-002");

oFV.SaveFeatureValuesAsMat(oFeatureValues);
oFV.Save();