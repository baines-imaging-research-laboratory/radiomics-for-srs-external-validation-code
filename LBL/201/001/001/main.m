Experiment.StartNewSection('Experiment Assets');

% load features values
oLBL_LRCP = ExperimentManager.Load('LBL-002-002-001A');
oLabelledFeatureValues_LRCP = oLBL_LRCP.GetLabelledFeatureValues();

oLBL_VUMC = ExperimentManager.Load('LBL-101-001-001');
oLabelledFeatureValues_VUMC = oLBL_VUMC.GetLabelledFeatureValues();

% Create new feature values object
oRecord = CustomFeatureExtractionRecord("LBL-201-001-001", oLabelledFeatureValues_VUMC.GetFeatureExtractionRecord(1).GetFeatureExtractionRecordPortions.GetDescription(), [oLabelledFeatureValues_VUMC.GetFeatures(); oLabelledFeatureValues_LRCP.GetFeatures()]);

oLabelledFeatureValues = LabelledFeatureValuesByValue(...
    [oLabelledFeatureValues_VUMC.GetFeatures(); oLabelledFeatureValues_LRCP.GetFeatures()],...
    [oLabelledFeatureValues_VUMC.GetGroupIds(); oLabelledFeatureValues_LRCP.GetGroupIds()], [oLabelledFeatureValues_VUMC.GetSubGroupIds(); oLabelledFeatureValues_LRCP.GetSubGroupIds()], [oLabelledFeatureValues_VUMC.GetUserDefinedSampleStrings(); oLabelledFeatureValues_LRCP.GetUserDefinedSampleStrings()],...
    oLabelledFeatureValues_VUMC.GetFeatureNames(),...
    [oLabelledFeatureValues_VUMC.GetLabels(); oLabelledFeatureValues_LRCP.GetLabels()], oLabelledFeatureValues_VUMC.GetPositiveLabel(), oLabelledFeatureValues_VUMC.GetNegativeLabel(),...    
    'FeatureExtractionRecord', oRecord);

oLBL = Labels("LBL-201-001-001");

oLBL.SaveLabelledFeatureValuesAsMat(oLabelledFeatureValues);
oLBL.Save();