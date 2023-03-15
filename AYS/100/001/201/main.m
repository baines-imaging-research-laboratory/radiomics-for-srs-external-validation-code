% Univariate analysis of VUMC and LRCP clinical features to separate VUMC
% vs LRCP
Experiment.StartNewSection('Analysis');

% load features
vsFeatureValueCodes_VUMC = "FV-101-004-001";
sLabelsCode_VUMC = "LBL-101-001-001";

oFeatureValues_VUMC = ExperimentManager.GetLabelledFeatureValues(...
    vsFeatureValueCodes_VUMC,...
    sLabelsCode_VUMC);


vsFeatureValueCodes_LRCP = "FV-003-002-001A";
sLabelsCode_LRCP = "LBL-002-002-001A";

oFeatureValues_LRCP = ExperimentManager.GetLabelledFeatureValues(...
    vsFeatureValueCodes_LRCP,...
    sLabelsCode_LRCP);

vbIsPositive = [...
    oFeatureValues_VUMC.GetLabels() == oFeatureValues_VUMC.GetPositiveLabel();
    oFeatureValues_LRCP.GetLabels() == oFeatureValues_LRCP.GetPositiveLabel()];

% analyze
vdCentrePValuePerClinicalFeature = zeros(1, oFeatureValues_VUMC.GetNumberOfFeatures());
vdLabelPValuePerClinicalFeature = zeros(1, oFeatureValues_VUMC.GetNumberOfFeatures());

vbIsVUMC = [true(oFeatureValues_VUMC.GetNumberOfSamples(),1); false(oFeatureValues_LRCP.GetNumberOfSamples(),1)];

% Sex
% - binary
disp(">> Sex");
oSex_VUMC = oFeatureValues_VUMC(:,oFeatureValues_VUMC.GetFeatureNames() == "Sex");
vdSex_VUMC = oSex_VUMC.GetFeatures();

oSex_LRCP = oFeatureValues_LRCP(:,oFeatureValues_LRCP.GetFeatureNames() == "Sex");
vdSex_LRCP = oSex_LRCP.GetFeatures();

[~,~,dPVal] = crosstab(vbIsVUMC, [vdSex_VUMC; vdSex_LRCP]);
vdCentrePValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "Sex") = dPVal;

disp("Centre P-value: " + string(dPVal));

[~,~,dPVal] = crosstab(vbIsPositive, [vdSex_VUMC; vdSex_LRCP]);
vdLabelPValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "Sex") = dPVal;

disp("+ vs - P-value: " + string(dPVal));

% Age (Years)
% - continuous
disp(">> Age");
oAge_VUMC = oFeatureValues_VUMC(:,oFeatureValues_VUMC.GetFeatureNames() == "Age (Years)");
vdAge_VUMC = oAge_VUMC.GetFeatures();

oAge_LRCP = oFeatureValues_LRCP(:,oFeatureValues_LRCP.GetFeatureNames() == "Age (Years)");
vdAge_LRCP = oAge_LRCP.GetFeatures();

dPVal = ranksum(vdAge_VUMC, vdAge_LRCP);
vdCentrePValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "Age (Years)") = dPVal;

disp("Centre P-value: " + string(dPVal));

vdAge = [vdAge_VUMC; vdAge_LRCP];

dPVal = ranksum(vdAge(vbIsPositive), vdAge(~vbIsPositive));
vdLabelPValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "Age (Years)") = dPVal;

disp("+ vs - P-value: " + string(dPVal));





% Primary Cancer Site
% - 4 categories
disp(">> Primary Cancer Site");
oPrimaryCancerSite_VUMC = oFeatureValues_VUMC(:,oFeatureValues_VUMC.GetFeatureNames() == "Primary Cancer Site");
vdPrimaryCancerSite_VUMC = oPrimaryCancerSite_VUMC.GetFeatures();

oPrimaryCancerSite_LRCP = oFeatureValues_LRCP(:,oFeatureValues_LRCP.GetFeatureNames() == "Primary Cancer Site");
vdPrimaryCancerSite_LRCP = oPrimaryCancerSite_LRCP.GetFeatures();

[~,~,dPVal] = crosstab(vbIsVUMC, [vdPrimaryCancerSite_VUMC; vdPrimaryCancerSite_LRCP]);
vdCentrePValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "Primary Cancer Site") = dPVal;

disp("Centre P-value: " + string(dPVal));

[~,~,dPVal] = crosstab(vbIsPositive, [vdPrimaryCancerSite_VUMC; vdPrimaryCancerSite_LRCP]);
vdLabelPValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "Primary Cancer Site") = dPVal;

disp("+ vs - P-value: " + string(dPVal));



% Primary Cancer Histopathology Type
% - 4 categories
disp(">> Primary Cancer Histopathology");
oPrimaryCancerHistopathology_VUMC = oFeatureValues_VUMC(:,oFeatureValues_VUMC.GetFeatureNames() == "Primary Cancer Histopathology Type");
vdPrimaryCancerHistopathology_VUMC = oPrimaryCancerHistopathology_VUMC.GetFeatures();

oPrimaryCancerHistopathology_LRCP = oFeatureValues_LRCP(:,oFeatureValues_LRCP.GetFeatureNames() == "Primary Cancer Histopathology Type");
vdPrimaryCancerHistopathology_LRCP = oPrimaryCancerHistopathology_LRCP.GetFeatures();

[~,~,dPVal] = crosstab(vbIsVUMC, [vdPrimaryCancerHistopathology_VUMC; vdPrimaryCancerHistopathology_LRCP]);
vdCentrePValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "Primary Cancer Histopathology Type") = dPVal;

disp("Centre P-value: " + string(dPVal));

[~,~,dPVal] = crosstab(vbIsPositive, [vdPrimaryCancerHistopathology_VUMC; vdPrimaryCancerHistopathology_LRCP]);
vdLabelPValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "Primary Cancer Histopathology Type") = dPVal;

disp("+ vs - P-value: " + string(dPVal));


% Systemic Therapy Status
% - binary
disp(">> Systemic Therapy");
oSystemicTherapyStatus_VUMC = oFeatureValues_VUMC(:,oFeatureValues_VUMC.GetFeatureNames() == "Systemic Therapy Status");
vdSystemicTherapyStatus_VUMC = oSystemicTherapyStatus_VUMC.GetFeatures();

oSystemicTherapyStatus_LRCP = oFeatureValues_LRCP(:,oFeatureValues_LRCP.GetFeatureNames() == "Systemic Therapy Status");
vdSystemicTherapyStatus_LRCP = oSystemicTherapyStatus_LRCP.GetFeatures();

[~,~,dPVal] = crosstab(vbIsVUMC, [vdSystemicTherapyStatus_VUMC; vdSystemicTherapyStatus_LRCP]);
vdCentrePValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "Systemic Therapy Status") = dPVal;

disp("Centre P-value: " + string(dPVal));

[~,~,dPVal] = crosstab(vbIsPositive, [vdSystemicTherapyStatus_VUMC; vdSystemicTherapyStatus_LRCP]);
vdLabelPValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "Systemic Therapy Status") = dPVal;

disp("+ vs - P-value: " + string(dPVal));


% GTV Volume (cc)
% - continuous
disp(">> Volume");
oGTVVolume_VUMC = oFeatureValues_VUMC(:,oFeatureValues_VUMC.GetFeatureNames() == "GTV Volume (cc)");
vdGTVVolume_VUMC = oGTVVolume_VUMC.GetFeatures();

oGTVVolume_LRCP = oFeatureValues_LRCP(:,oFeatureValues_LRCP.GetFeatureNames() == "GTV Volume (cc)");
vdGTVVolume_LRCP = oGTVVolume_LRCP.GetFeatures();

dPVal = ranksum(vdGTVVolume_VUMC, vdGTVVolume_LRCP);
vdCentrePValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "GTV Volume (cc)") = dPVal;

disp("Centre P-value: " + string(dPVal));

vdGTVVolume = [vdGTVVolume_VUMC; vdGTVVolume_LRCP];

dPVal = ranksum(vdGTVVolume(vbIsPositive), vdGTVVolume(~vbIsPositive));
vdLabelPValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "GTV Volume (cc)") = dPVal;

disp("+ vs - P-value: " + string(dPVal));


% Dose (Gy)
disp(">> Dose");
oDose_VUMC = oFeatureValues_VUMC(:,oFeatureValues_VUMC.GetFeatureNames() == "Dose (Gy)");
vdDose_VUMC = oDose_VUMC.GetFeatures();

oDose_LRCP = oFeatureValues_LRCP(:,oFeatureValues_LRCP.GetFeatureNames() == "Dose (Gy)");
vdDose_LRCP = oDose_LRCP.GetFeatures();

dPVal = ranksum(vdDose_VUMC, vdDose_LRCP);
vdCentrePValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "Dose (Gy)") = dPVal;

disp("Centre P-value: " + string(dPVal));

vdDose = [vdDose_VUMC; vdDose_LRCP];

dPVal = ranksum(vdDose(vbIsPositive), vdDose(~vbIsPositive));
vdLabelPValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "Dose (Gy)") = dPVal;

disp("+ vs - P-value: " + string(dPVal));



%Fractions
% - binary
disp(">> Fractions");
oFractions_VUMC = oFeatureValues_VUMC(:,oFeatureValues_VUMC.GetFeatureNames() == "Fractions");
vdFractions_VUMC = oFractions_VUMC.GetFeatures();

oFractions_LRCP = oFeatureValues_LRCP(:,oFeatureValues_LRCP.GetFeatureNames() == "Fractions");
vdFractions_LRCP = oFractions_LRCP.GetFeatures();

[~,~,dPVal] = crosstab(vbIsVUMC, [vdFractions_VUMC==1; vdFractions_LRCP==1]);
vdCentrePValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "Fractions") = dPVal;

disp("Centre P-value: " + string(dPVal));

[~,~,dPVal] = crosstab(vbIsPositive, [vdFractions_VUMC==1; vdFractions_LRCP==1]);
vdLabelPValuePerClinicalFeature(oFeatureValues_VUMC.GetFeatureNames() == "Fractions") = dPVal;

disp("+ vs - P-value: " + string(dPVal));




% Save p-values
FileIOUtils.SaveMatFile(fullfile(Experiment.GetResultsDirectory(), 'P-Values for VUMC vs LRCP Per Clinical Feature.mat'), ...
    'vdCentrePValuePerClinicalFeature', vdCentrePValuePerClinicalFeature,...
    'vdLabelPValuePerClinicalFeature', vdLabelPValuePerClinicalFeature);