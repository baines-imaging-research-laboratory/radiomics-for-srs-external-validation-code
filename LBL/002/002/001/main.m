Experiment.StartNewSection('Experiment Assets');

% get sample IDs
[vdPatientIds, vdBMNumbers] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-003-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.mat'),...
    'vdPatientIdPerSample', 'vdBMNumberPerSample');

[vbIsProgressionPerSample, vbIsRadionecrosisPerSample, vbIsAdverseRadiationEffectPerSample] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-006-006'), '01 Analysis', 'Outcomes Per Sample.mat'),...
    'vbIsProgressionPerSample',...
    'vbIsRadionecrosisPerSample',...
    'vbIsAdverseRadiationEffectPerSample');

vsFeatureNames = "Dummy Variable";
m2dFeatures = zeros(length(vdPatientIds),1);

viGroupIds = uint16(vdPatientIds);
viSubGroupIds = uint16(vdBMNumbers);

vsUserDefinedSampleStrings = string(viGroupIds) + "-" + string(viSubGroupIds);

oRecord = CustomFeatureExtractionRecord("LBL-002-002-001", "In-field Progression", m2dFeatures);

oLabelledFeatureValues = LabelledFeatureValuesByValue(...
    m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames,...
    uint8(vbIsProgressionPerSample), uint8(1), uint8(0),...
    'FeatureExtractionRecord', oRecord);

disp("Num +: " + string(sum(vbIsProgressionPerSample)));
disp("Num -: " + string(sum(~vbIsProgressionPerSample)));
disp("Num Pseudo-Progression: " + string(sum(vbIsRadionecrosisPerSample | vbIsAdverseRadiationEffectPerSample)))

oLBL = Labels("LBL-002-002-001");

oLBL.SaveLabelledFeatureValuesAsMat(oLabelledFeatureValues);
oLBL.Save();