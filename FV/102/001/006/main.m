Experiment.StartNewSection('Experiment Assets');

oFeatureValues = FileIOUtils.LoadMatFile('E:\Users\ddevries\VUMC BM\Experiments\FV\705\006B [2022-07-20_08.37.07]\Results\01 Experiment Assets\FV-705-006B [CentralLibrary].mat', 'oFeatureValues');
sRecordDescription = oFeatureValues.GetFeatureExtractionRecord(1).voFeatureExtractionRecordPortions.sDescription;

m2dFeatures = oFeatureValues.GetFeatures();

vsFeatureNames = oFeatureValues.GetFeatureNames();


% get sample IDs
viGroupIds = uint16(oFeatureValues.GetGroupIds());
viSubGroupIds = uint16(oFeatureValues.GetSubGroupIds());

% adjust Patient IDs to ensure VUMC and LRCP IDs don't overlap
viGroupIds = viGroupIds + uint16(10000); 

vsUserDefinedSampleStrings = string(viGroupIds) + "-" + string(viSubGroupIds);

% create feature values    
oRecord = CustomFeatureExtractionRecord("FV-102-001-006", sRecordDescription + " unified across VUMC and LRCP", m2dFeatures);

oFeatureValues = FeatureValuesByValue(...
    m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames,...
    'FeatureExtractionRecord', oRecord);

oFV = ExperimentFeatureValues("FV-102-001-006");

oFV.SaveFeatureValuesAsMat(oFeatureValues);
oFV.Save();