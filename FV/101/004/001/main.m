Experiment.StartNewSection('Experiment Assets');

oFeatureValues = FileIOUtils.LoadMatFile('E:\Users\ddevries\VUMC BM\Experiments\FV\500\104 [2022-10-31_20.38.14]\Results\01 Experiment Assets\FV-500-104 [CentralLibrary].mat', 'oFeatureValues');

vsFeatureNames = oFeatureValues.GetFeatureNames();

% Sex (1: female)
oGender = oFeatureValues(:,vsFeatureNames == "Gender");
vbIsFemale = oGender.GetFeatures() == 1;

% Age (years)
oAge = oFeatureValues(:,vsFeatureNames == "Age");
vdAge_years = oAge.GetFeatures();

% Primary Site (0: lung, 1: breast, 2: skin, 3: other)
oPrimarySite = oFeatureValues(:,vsFeatureNames == "Primary Cancer Site");
vdPrimarySiteCodes = oPrimarySite.GetFeatures();

vdPrimarySite = 3*ones(size(vdPrimarySiteCodes)); % all set to "other" code

vdPrimarySite(vdPrimarySiteCodes == 1) = 0; % lung
vdPrimarySite(vdPrimarySiteCodes == 2) = 1; % breast
vdPrimarySite(vdPrimarySiteCodes == 5) = 2; % skin

% Primary Cancer Histopathology Type (0: adeno, 1: squamous, 2: NSCLC other, 3: melanoma, 4: other)
oPrimaryHistopathology = oFeatureValues(:,vsFeatureNames == "Primary Cancer Histology");
vdPrimaryHistopathologyCodes = oPrimaryHistopathology.GetFeatures();

vdPrimaryHistopathology = 4*ones(size(vdPrimaryHistopathologyCodes)); % all set to "other" code

vdPrimaryHistopathology(vdPrimaryHistopathologyCodes == 1) = 0; % Adeno Carcinoma

vdPrimaryHistopathology(vdPrimaryHistopathologyCodes == 4) = 1; % squamous Carcinoma

vdPrimaryHistopathology(vdPrimaryHistopathologyCodes == 2) = 2; % NSCLC other

vdPrimaryHistopathology(vdPrimaryHistopathologyCodes == 3) = 3; % Melanoma

% Systemic Therapy (1: yes)
oSystemicStatus = oFeatureValues(:,vsFeatureNames == "Systemic Therapy Status");
vbSystemicTherapy = logical(oSystemicStatus.GetFeatures() ~= 1);

% GTV volume (cc)
oGTVVolume = oFeatureValues(:,vsFeatureNames == "GTV Volume");
vdGTVVolume = oGTVVolume.GetFeatures();

% Dose (Gy)
oDoseAndFractionation = oFeatureValues(:,vsFeatureNames == "Dose And Fractionation");
vdDoseAndFractionationCategory = oDoseAndFractionation.GetFeatures();

vdDose_Gy = zeros(size(vdDoseAndFractionationCategory));

vdDose_Gy(vdDoseAndFractionationCategory == 1) = 15;
vdDose_Gy(vdDoseAndFractionationCategory == 2) = 18;
vdDose_Gy(vdDoseAndFractionationCategory == 3) = 21;
vdDose_Gy(vdDoseAndFractionationCategory == 4) = 24;

% Fractions
vdFractions = zeros(size(vdDoseAndFractionationCategory));

vdFractions(vdDoseAndFractionationCategory == 1) = 1;
vdFractions(vdDoseAndFractionationCategory == 2) = 1;
vdFractions(vdDoseAndFractionationCategory == 3) = 1;
vdFractions(vdDoseAndFractionationCategory == 4) = 3;


% create features matrix and name vector
m2dFeatures = [vbIsFemale, vdAge_years, vdPrimarySite, vdPrimaryHistopathology, vbSystemicTherapy, vdGTVVolume, vdDose_Gy, vdFractions];

vsFeatureNames = ["Sex", "Age (Years)",  "Primary Cancer Site", "Primary Cancer Histopathology Type", "Systemic Therapy Status", "GTV Volume (cc)", "Dose (Gy)", "Fractions"];
vbFeatureIsCategorical = [true false true true true false false false];


% get sample IDs
viGroupIds = uint16(oFeatureValues.GetGroupIds());
viSubGroupIds = uint16(oFeatureValues.GetSubGroupIds());

% adjust Patient IDs to ensure VUMC and LRCP IDs don't overlap
viGroupIds = viGroupIds + uint16(10000); 

vsUserDefinedSampleStrings = string(viGroupIds) + "-" + string(viSubGroupIds);

% create feature values    
oRecord = CustomFeatureExtractionRecord("FV-101-004-001", "Pre-treatment clinical features unified across VUMC and LRCP", m2dFeatures);

oFeatureValues = FeatureValuesByValue(...
    m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames,...
    'FeatureIsCategorical', vbFeatureIsCategorical,...
    'FeatureExtractionRecord', oRecord);

oFV = ExperimentFeatureValues("FV-101-004-001");

oFV.SaveFeatureValuesAsMat(oFeatureValues);
oFV.Save();