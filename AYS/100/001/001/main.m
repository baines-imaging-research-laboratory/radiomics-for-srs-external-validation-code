% Univariate analysis of VUMC clinical features to separate + vs -
Experiment.StartNewSection('Analysis');

% load features
vsFeatureValueCodes = "FV-101-004-001";
sLabelsCode = "LBL-101-001-001";

oFeatureValues = ExperimentManager.GetLabelledFeatureValues(...
    vsFeatureValueCodes,...
    sLabelsCode);

% analyze
vdPValuePerClinicalFeature = zeros(1, oFeatureValues.GetNumberOfFeatures());

vbIsPositive = oFeatureValues.GetLabels() == oFeatureValues.GetPositiveLabel();

% Sex
% - binary
disp(">> Sex");
oSex = oFeatureValues(:,oFeatureValues.GetFeatureNames() == "Sex");
vdSex = oSex.GetFeatures();

[~,~,dPVal] = crosstab(vbIsPositive, vdSex);
vdPValuePerClinicalFeature(oFeatureValues.GetFeatureNames() == "Sex") = dPVal;

disp("Female: " + string(sum(vdSex==1)) + " (" + string(round(100*sum(vbIsPositive(vdSex==1))/sum(vdSex==1),1)) + "%)");
disp("Male: " + string(sum(vdSex==0)) + " (" + string(round(100*sum(vbIsPositive(vdSex==0))/sum(vdSex==0),1)) + "%)");
disp("P-value: " + string(dPVal));
disp(" ");


% Age (Years)
% - continuous
disp(">> Age");
oAge = oFeatureValues(:, oFeatureValues.GetFeatureNames() == "Age (Years)");
vdAge = oAge.GetFeatures();

dPVal = ranksum(vdAge(vbIsPositive), vdAge(~vbIsPositive));
vdPValuePerClinicalFeature(oFeatureValues.GetFeatureNames() == "Age (Years)") = dPVal;

disp("Median: " + string(median(vdAge)));
disp("Range: " + string(min(vdAge)) + "-" + string(max(vdAge)));
disp("P-value: " + string(dPVal));
disp(" ");

% Primary Cancer Site
% - 4 categories
disp(">> Primary Cancer Site");
oPrimaryCancerSite = oFeatureValues(:, oFeatureValues.GetFeatureNames() == "Primary Cancer Site");
vdPrimaryCancerSite = oPrimaryCancerSite.GetFeatures();

[~,~,dPVal] = crosstab(vbIsPositive, vdPrimaryCancerSite);
vdPValuePerClinicalFeature(oFeatureValues.GetFeatureNames() == "Primary Cancer Site") = dPVal;

disp("Lung: " + string(sum(vdPrimaryCancerSite==0)) + " (" + string(round(100*sum(vbIsPositive(vdPrimaryCancerSite==0))/sum(vdPrimaryCancerSite==0),1)) + "%)");
disp("Breast: " + string(sum(vdPrimaryCancerSite==1)) + " (" + string(round(100*sum(vbIsPositive(vdPrimaryCancerSite==1))/sum(vdPrimaryCancerSite==1),1)) + "%)");
disp("Skin: " + string(sum(vdPrimaryCancerSite==2)) + " (" + string(round(100*sum(vbIsPositive(vdPrimaryCancerSite==2))/sum(vdPrimaryCancerSite==2),1)) + "%)");
disp("Other: " + string(sum(vdPrimaryCancerSite==3)) + " (" + string(round(100*sum(vbIsPositive(vdPrimaryCancerSite==3))/sum(vdPrimaryCancerSite==3),1)) + "%)");

disp("P-value: " + string(dPVal));
disp(" ");

% Primary Cancer Histopathology Type
% - 4 categories
disp(">> Primary Cancer Histopathology");
oPrimaryCancerHistopathology = oFeatureValues(:, oFeatureValues.GetFeatureNames() == "Primary Cancer Histopathology Type");
vdPrimaryCancerHistopathology = oPrimaryCancerHistopathology.GetFeatures();

[~,~,dPVal] = crosstab(vbIsPositive, vdPrimaryCancerHistopathology);
vdPValuePerClinicalFeature(oFeatureValues.GetFeatureNames() == "Primary Cancer Histopathology Type") = dPVal;

disp("Adeno: " + string(sum(vdPrimaryCancerHistopathology==0)) + " (" + string(round(100*sum(vbIsPositive(vdPrimaryCancerHistopathology==0))/sum(vdPrimaryCancerHistopathology==0),1)) + "%)");
disp("Squamous: " + string(sum(vdPrimaryCancerHistopathology==1)) + " (" + string(round(100*sum(vbIsPositive(vdPrimaryCancerHistopathology==1))/sum(vdPrimaryCancerHistopathology==1),1)) + "%)");
disp("NSCLC Other: " + string(sum(vdPrimaryCancerHistopathology==2)) + " (" + string(round(100*sum(vbIsPositive(vdPrimaryCancerHistopathology==2))/sum(vdPrimaryCancerHistopathology==2),1)) + "%)");
disp("Melanoma: " + string(sum(vdPrimaryCancerHistopathology==3)) + " (" + string(round(100*sum(vbIsPositive(vdPrimaryCancerHistopathology==3))/sum(vdPrimaryCancerHistopathology==3),1)) + "%)");
disp("Other: " + string(sum(vdPrimaryCancerHistopathology==4)) + " (" + string(round(100*sum(vbIsPositive(vdPrimaryCancerHistopathology==4))/sum(vdPrimaryCancerHistopathology==4),1)) + "%)");

disp("P-value: " + string(dPVal));
disp(" ");

% Systemic Therapy Status
% - binary
disp(">> Systemic Therapy");
oSystemicTherapyStatus = oFeatureValues(:,oFeatureValues.GetFeatureNames() == "Systemic Therapy Status");
vdSystemicTherapyStatus = oSystemicTherapyStatus.GetFeatures();

[~,~,dPVal] = crosstab(vbIsPositive, vdSystemicTherapyStatus);
vdPValuePerClinicalFeature(oFeatureValues.GetFeatureNames() == "Systemic Therapy Status") = dPVal;

disp("Yes: " + string(sum(vdSystemicTherapyStatus==1)) + " (" + string(round(100*sum(vbIsPositive(vdSystemicTherapyStatus==1))/sum(vdSystemicTherapyStatus==1),1)) + "%)");
disp("No: " + string(sum(vdSystemicTherapyStatus==0)) + " (" + string(round(100*sum(vbIsPositive(vdSystemicTherapyStatus==0))/sum(vdSystemicTherapyStatus==0),1)) + "%)");

disp("P-value: " + string(dPVal));
disp(" ");

% GTV Volume (cc)
% - continuous
disp(">> Volume");
oGTVVolume = oFeatureValues(:, oFeatureValues.GetFeatureNames() == "GTV Volume (cc)");
vdGTVVolume = oGTVVolume.GetFeatures();

dPVal = ranksum(vdGTVVolume(vbIsPositive), vdGTVVolume(~vbIsPositive));
vdPValuePerClinicalFeature(oFeatureValues.GetFeatureNames() == "GTV Volume (cc)") = dPVal;

disp("Median: " + string(median(vdGTVVolume*1000)));
disp("Range: " + string(min(vdGTVVolume*1000)) + "-" + string(max(vdGTVVolume*1000)));
disp("P-value: " + string(dPVal));
disp(" ");

% Dose (Gy)
disp(">> Dose");
oDose = oFeatureValues(:,oFeatureValues.GetFeatureNames() == "Dose (Gy)");
vdDose = oDose.GetFeatures();

dPVal = ranksum(vdDose(vbIsPositive), vdDose(~vbIsPositive));
vdPValuePerClinicalFeature(oFeatureValues.GetFeatureNames() == "Dose (Gy)") = dPVal;

disp("Median: " + string(median(vdDose)));
disp("Range: " + string(min(vdDose)) + "-" + string(max(vdDose)));
disp("P-value: " + string(dPVal));
disp(" ");

%Fractions
% - binary
disp(">> Fractions");
oFractions = oFeatureValues(:,oFeatureValues.GetFeatureNames() == "Fractions");
vdFractions = oFractions.GetFeatures();

[~,~,dPVal] = crosstab(vbIsPositive, vdFractions==1);
vdPValuePerClinicalFeature(oFeatureValues.GetFeatureNames() == "Fractions") = dPVal;

disp("1: " + string(sum(vdFractions==1)) + " (" + string(round(100*sum(vbIsPositive(vdFractions==1))/sum(vdFractions==1),1)) + "%)");
disp("3: " + string(sum(vdFractions==3)) + " (" + string(round(100*sum(vbIsPositive(vdFractions==3))/sum(vdFractions==3),1)) + "%)");

disp("P-value: " + string(dPVal));
disp(" ");











% Save p-values
FileIOUtils.SaveMatFile(fullfile(Experiment.GetResultsDirectory(), 'P-Values for VUMC- vs VUMC+ Per Clinical Feature.mat'), ...
    'vdPValuePerClinicalFeature', vdPValuePerClinicalFeature);