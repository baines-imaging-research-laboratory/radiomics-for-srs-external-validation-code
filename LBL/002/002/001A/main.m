Experiment.StartNewSection('Experiment Assets');

% load features values
oLBL = ExperimentManager.Load('LBL-002-002-001');
oLabelledFeatureValues = oLBL.GetLabelledFeatureValues();

% load sample selection
[vdPatientIds, vdBMNumbers] = FileIOUtils.LoadMatFile(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-004-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.mat'), 'vdPatientIdPerSample', 'vdBMNumberPerSample');

vbKeepSample = false(oLabelledFeatureValues.GetNumberOfSamples(),1);

for dSelectSampleIndex=1:length(vdPatientIds)
    vbMatch = vdPatientIds(dSelectSampleIndex) == oLabelledFeatureValues.GetGroupIds() & vdBMNumbers(dSelectSampleIndex) == oLabelledFeatureValues.GetSubGroupIds();
    
    if any(vbMatch)
        vbKeepSample(vbMatch) = true;
    end
end

oLabelledFeatureValues = oLabelledFeatureValues(vbKeepSample,:);

% Create new feature values object
oRecord = CustomFeatureExtractionRecord("LBL-002-002-001A", "In-field Progression", oLabelledFeatureValues.GetFeatures());

oLabelledFeatureValues = LabelledFeatureValuesByValue(...
    oLabelledFeatureValues.GetFeatures(), oLabelledFeatureValues.GetGroupIds(), oLabelledFeatureValues.GetSubGroupIds(), oLabelledFeatureValues.GetUserDefinedSampleStrings(), oLabelledFeatureValues.GetFeatureNames(),...
    oLabelledFeatureValues.GetLabels(), oLabelledFeatureValues.GetPositiveLabel(), oLabelledFeatureValues.GetNegativeLabel(),...
    'FeatureExtractionRecord', oRecord);

oLBL = Labels("LBL-002-002-001A");

oLBL.SaveLabelledFeatureValuesAsMat(oLabelledFeatureValues);
oLBL.Save();