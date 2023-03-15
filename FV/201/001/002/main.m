Experiment.StartNewSection('Experiment Assets');

% load features values
oFV_LRCP = ExperimentManager.Load('FV-004-002-002A');
oFeatureValues_LRCP = oFV_LRCP.GetFeatureValues();

oFV_VUMC = ExperimentManager.Load('FV-102-001-002');
oFeatureValues_VUMC = oFV_VUMC.GetFeatureValues();

% Create new feature values object
oRecord = CustomFeatureExtractionRecord("FV-201-001-002", oFeatureValues_VUMC.GetFeatureExtractionRecord(1).GetFeatureExtractionRecordPortions.GetDescription(), [oFeatureValues_VUMC.GetFeatures(); oFeatureValues_LRCP.GetFeatures()]);

oFeatureValues = FeatureValuesByValue(...
    [oFeatureValues_VUMC.GetFeatures(); oFeatureValues_LRCP.GetFeatures()],...
    [oFeatureValues_VUMC.GetGroupIds(); oFeatureValues_LRCP.GetGroupIds()], [oFeatureValues_VUMC.GetSubGroupIds(); oFeatureValues_LRCP.GetSubGroupIds()], [oFeatureValues_VUMC.GetUserDefinedSampleStrings(); oFeatureValues_LRCP.GetUserDefinedSampleStrings()],...
    oFeatureValues_VUMC.GetFeatureNames(),...
    'FeatureExtractionRecord', oRecord);

oFV = ExperimentFeatureValues("FV-201-001-002");

oFV.SaveFeatureValuesAsMat(oFeatureValues);
oFV.Save();