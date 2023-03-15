Experiment.StartNewSection('Experiment Assets');

oLabelledFeatureValues = FileIOUtils.LoadMatFile('E:\Users\ddevries\VUMC BM\Experiments\LBL\201 [2021-12-07_14.44.40]\Results\01 Experiment Assets\LBL-201 [CentralLibrary].mat', 'oLabelledFeatureValues');

vbIsProgression = oLabelledFeatureValues.GetLabels() == oLabelledFeatureValues.GetPositiveLabel();

vsFeatureNames = "Dummy Variable";
m2dFeatures = zeros(oLabelledFeatureValues.GetNumberOfSamples(),1);

viGroupIds = uint16(oLabelledFeatureValues.GetGroupIds());
viSubGroupIds = uint16(oLabelledFeatureValues.GetSubGroupIds());

% adjust Patient IDs to ensure VUMC and LRCP IDs don't overlap
viGroupIds = viGroupIds + uint16(10000); 

vsUserDefinedSampleStrings = string(viGroupIds) + "-" + string(viSubGroupIds);

oRecord = CustomFeatureExtractionRecord("LBL-101-001-001", "In-field Progression unified across VUMC and LRCP", m2dFeatures);

oLabelledFeatureValues = LabelledFeatureValuesByValue(...
    m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames,...
    uint8(vbIsProgression), uint8(1), uint8(0),...
    'FeatureExtractionRecord', oRecord);

disp("Num +: " + string(sum(vbIsProgression)));
disp("Num -: " + string(sum(~vbIsProgression)));

oLBL = Labels("LBL-101-001-001");

oLBL.SaveLabelledFeatureValuesAsMat(oLabelledFeatureValues);
oLBL.Save();