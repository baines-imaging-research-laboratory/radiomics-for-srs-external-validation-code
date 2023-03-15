Experiment.StartNewSection('Experiment Assets');

oFV = ExperimentManager.Load('FV-003-001-004');
oFeatureValues = oFV.GetFeatureValues();

vsFeatureNames = oFeatureValues.GetFeatureNames();

% Gender (1: female)
oGender = oFeatureValues(:,vsFeatureNames == "Gender");
vbIsFemale = oGender.GetFeatures();

% Age (years)
oAge = oFeatureValues(:,vsFeatureNames == "Age (Years)");
vdAge_years = oAge.GetFeatures();

% Primary Site (0: lung, 1: breast, 2: skin, 3: other)
oPrimarySite = oFeatureValues(:,vsFeatureNames == "Primary Cancer Site");
vdPrimarySiteCodes = oPrimarySite.GetFeatures();

vdPrimarySite = 3*ones(size(vdPrimarySiteCodes)); % all set to "other" code

vdPrimarySite(vdPrimarySiteCodes == 1) = 0; % lung
vdPrimarySite(vdPrimarySiteCodes == 2) = 1; % breast
vdPrimarySite(vdPrimarySiteCodes == 4) = 2; % skin

% Primary Cancer Histopathology Type (0: adeno, 1: squamous, 2: NSCLC other, 3: melanoma, 4: other)
oPrimaryHistopathology = oFeatureValues(:,vsFeatureNames == "Primary Cancer Histopathology Type");
vdPrimaryHistopathologyCodes = oPrimaryHistopathology.GetFeatures();

vdPrimaryHistopathology = 4*ones(size(vdPrimaryHistopathologyCodes)); % all set to "other" code

vdPrimaryHistopathology(vdPrimaryHistopathologyCodes == 1 | vdPrimaryHistopathologyCodes == 7 | vdPrimaryHistopathologyCodes == 12 | vdPrimaryHistopathologyCodes == 13) = 0; % NSCLC adeno, adeno, renal, or mammary

vdPrimaryHistopathology(vdPrimaryHistopathologyCodes == 2 | vdPrimaryHistopathologyCodes == 8) = 1; % NSCLC squamous or squamous

vdPrimaryHistopathology(vdPrimaryHistopathologyCodes == 3 | vdPrimaryHistopathologyCodes == 4) = 2; % NSCLC large cell or NSCLC other

vdPrimaryHistopathology(vdPrimaryHistopathologyCodes == 6) = 3; % Melanoma

% Systemic Therapy (1: yes)
oChemotherapyStatus = oFeatureValues(:,vsFeatureNames == "Chemotherapy Status");
oHormoneTherapyStatus = oFeatureValues(:,vsFeatureNames == "Hormone Therapy Status");
oTargetedTherapyStatus = oFeatureValues(:,vsFeatureNames == "Targeted Therapy Status");
oImmunotherapyStatus = oFeatureValues(:,vsFeatureNames == "Immunotherapy Status");

vbSystemicTherapy = ...
    logical(oChemotherapyStatus.GetFeatures()) |...
    logical(oHormoneTherapyStatus.GetFeatures()) |...
    logical(oTargetedTherapyStatus.GetFeatures()) |...
    logical(oImmunotherapyStatus.GetFeatures());

% GTV volume (cc)
vdPatientIds = oFeatureValues.GetGroupIds();
vdBMNumbers = oFeatureValues.GetSubGroupIds();

vdGTVVolume = zeros(size(vdPatientIds));

vdUniquePatientIds = unique(vdPatientIds);

for dPatientIndex=1:length(vdUniquePatientIds)
    dPatientId = vdUniquePatientIds(dPatientIndex);
    disp(dPatientId);
    
    oPatient = Patient.LoadFromDatabase(dPatientId);
    
    vdBMNumbersForPatient = vdBMNumbers(vdPatientIds == dPatientId);
    dNumBMs = length(vdBMNumbersForPatient);
    
    vdGTVVolumesForBMs = zeros(dNumBMs,1);
    
    oROIs = oPatient.LoadProcessedRegionsOfInterest('ROIPP-003-001-000');
    
    for dBMIndex=1:dNumBMs
        dROINumber = oROIs.GetRegionOfInterestNumberByRegionOfInterestName(oPatient.GetFirstBrainRadiationCourse().GetPrescriptionForBrainMetastasis(vdBMNumbersForPatient(dBMIndex)).GetGTVStructureName());
        
        m3bMask = oROIs.GetMaskByRegionOfInterestNumber(dROINumber);
        dNumVoxels = sum(m3bMask(:));
        
        vdGTVVolumesForBMs(dBMIndex) = dNumVoxels * prod(oROIs.GetImageVolumeGeometry().GetVoxelDimensions_mm()) / 1000; % / 1000 to get cc from mm3
    end
    
    vdGTVVolume(vdPatientIds == dPatientId) = vdGTVVolumesForBMs;
end

% Dose (Gy)
oDose = oFeatureValues(:,vsFeatureNames == "Dose (Gy)");
vdDose_Gy = oDose.GetFeatures();

% Fractions
oFractions = oFeatureValues(:,vsFeatureNames == "Fractions");
vdFractions = oFractions.GetFeatures();


% create features matrix and name vector
m2dFeatures = [vbIsFemale, vdAge_years, vdPrimarySite, vdPrimaryHistopathology, vbSystemicTherapy, vdGTVVolume, vdDose_Gy, vdFractions];

vsFeatureNames = ["Sex", "Age (Years)",  "Primary Cancer Site", "Primary Cancer Histopathology Type", "Systemic Therapy Status", "GTV Volume (cc)", "Dose (Gy)", "Fractions"];
vbFeatureIsCategorical = [true false true true true false false false];


% get sample IDs
viGroupIds = oFeatureValues.GetGroupIds();
viSubGroupIds = oFeatureValues.GetSubGroupIds();

vsUserDefinedSampleStrings = string(viGroupIds) + "-" + string(viSubGroupIds);

% create feature values    
oRecord = CustomFeatureExtractionRecord("FV-003-002-001", "Pre-treatment clinical features unified across VUMC and LRCP", m2dFeatures);

oFeatureValues = FeatureValuesByValue(...
    m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames,...
    'FeatureIsCategorical', vbFeatureIsCategorical,...
    'FeatureExtractionRecord', oRecord);

oFV = ExperimentFeatureValues("FV-003-002-001");

oFV.SaveFeatureValuesAsMat(oFeatureValues);
oFV.Save();