Experiment.StartNewSection('Experiment Assets');

% load features values
oFV = ExperimentManager.Load('FV-004-002-005');
oFeatureValues = oFV.GetFeatureValues();

% load sample selection
[vdPatientIds, vdBMNumbers] = FileIOUtils.LoadMatFile(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-004-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.mat'), 'vdPatientIdPerSample', 'vdBMNumberPerSample');

vbKeepSample = false(oFeatureValues.GetNumberOfSamples(),1);

for dSelectSampleIndex=1:length(vdPatientIds)
    vbMatch = vdPatientIds(dSelectSampleIndex) == oFeatureValues.GetGroupIds() & vdBMNumbers(dSelectSampleIndex) == oFeatureValues.GetSubGroupIds();
    
    if any(vbMatch)
        vbKeepSample(vbMatch) = true;
    end
end

oFeatureValues = oFeatureValues(vbKeepSample,:);

% Create new feature values object
oRecord = CustomFeatureExtractionRecord("FV-004-002-005A", oFeatureValues.GetFeatureExtractionRecord(1).GetFeatureExtractionRecordPortions.GetDescription(), oFeatureValues.GetFeatures());

oFeatureValues = FeatureValuesByValue(...
    oFeatureValues.GetFeatures(), oFeatureValues.GetGroupIds(), oFeatureValues.GetSubGroupIds(), oFeatureValues.GetUserDefinedSampleStrings(), oFeatureValues.GetFeatureNames(),...
    'FeatureIsCategorical', oFeatureValues.IsFeatureCategorical(),...
    'FeatureExtractionRecord', oRecord);

oFV = ExperimentFeatureValues("FV-004-002-005A");

oFV.SaveFeatureValuesAsMat(oFeatureValues);
oFV.Save();