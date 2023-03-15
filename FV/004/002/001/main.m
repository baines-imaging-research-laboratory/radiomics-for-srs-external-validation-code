Experiment.StartNewSection(ExperimentManager.chExperimentAssetsSectionName);

% get Patient IDs
[vdPatientIdsPerSample, vdBMNumbersPerSample] = FileIOUtils.LoadMatFile(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-003-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.mat'), 'vdPatientIdPerSample', 'vdBMNumberPerSample');

sBaseFVValues = "FV-004-002-000";

sNewFVCode = "FV-004-002-001";
sFeatureNameMatchString = "original_firstorder";

[m2dBaseFeatureValuesPerSamplePerFeature, c1chBaseFeatureNames] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sBaseFVValues), '01 Experiment Assets', 'FeatureValuesAndNames.mat'),...
    'm2dFeatureValuesPerSamplePerFeature', 'c1chFeatureNames');
vsFeatureNames = string(c1chBaseFeatureNames);

vbSelectFeatures = contains(vsFeatureNames, sFeatureNameMatchString);
disp("Num Features: " + string(sum(vbSelectFeatures)));

oRecord = CustomFeatureExtractionRecord(sNewFVCode, "PyRadiomics features matching search string: " + sFeatureNameMatchString, m2dBaseFeatureValuesPerSamplePerFeature(:,vbSelectFeatures));

oFeatureValues = FeatureValuesByValue(...
    m2dBaseFeatureValuesPerSamplePerFeature(:,vbSelectFeatures),...
    uint16(vdPatientIdsPerSample), uint16(vdBMNumbersPerSample),...
    string(vdPatientIdsPerSample) + "-" + string(vdBMNumbersPerSample),...
    vsFeatureNames(vbSelectFeatures),...
    'FeatureExtractionRecord', oRecord);

oFV = ExperimentFeatureValues(sNewFVCode);

oFV.SaveFeatureValuesAsMat(oFeatureValues);
oFV.Save();
