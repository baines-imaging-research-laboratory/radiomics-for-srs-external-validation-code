Experiment.StartNewSection('Figures');

sExpCode_TrainVUMC_TestLRCP = "EXP-100-305-102_1";
sExpCode_TrainLRCP_TestVUMC = "EXP-100-405-102_1";

disp("Train VUMC, Test LRCP");
PrintROCMetrics(sExpCode_TrainVUMC_TestLRCP);

disp("Train LRCP, Test VUMC");
PrintROCMetrics(sExpCode_TrainLRCP_TestVUMC);


function PrintROCMetrics(sExpCode)

vsErrorMetricsHeaders = ["Features", "AUC", "MCR", "FNR", "FPR"];
disp(vsErrorMetricsHeaders);

dNumberOfFeatures=1
    
    sExpResultsPath = ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCode);
    
    oTrainingOOBSamplesGuessResult = FileIOUtils.LoadMatFile(fullfile(sExpResultsPath, "02 Cutoff Evaluation", "Training Artifacts (" + string(dNumberOfFeatures) + ").mat"), "oOOBSamplesGuessResult");
    oTestingSamplesGuessResult = FileIOUtils.LoadMatFile(fullfile(sExpResultsPath, "02 Cutoff Evaluation", "Testing Artifacts (" + string(dNumberOfFeatures) + ").mat"), "oTestingGuessResult");
    
    vdTrainingOOBConfidences = oTrainingOOBSamplesGuessResult.GetPositiveLabelConfidences();
    vbTrainingOOBIsPositive = oTrainingOOBSamplesGuessResult.GetLabels() == oTrainingOOBSamplesGuessResult.GetPositiveLabel();
    
    [vdOOBX, vdOOBY, vdOOBT, dOOBAUC] = perfcurve(vbTrainingOOBIsPositive, vdTrainingOOBConfidences, true);
    
    vdUpperLeftDist = (vdOOBX.^2) + ((1-vdOOBY).^2);
    [~,dMinIndex] = min(vdUpperLeftDist);
    dOptThres = vdOOBT(dMinIndex);
    
    vdTestingConfidences = oTestingSamplesGuessResult.GetPositiveLabelConfidences();
    vbTestingIsPositive = oTestingSamplesGuessResult.GetLabels() == oTestingSamplesGuessResult.GetPositiveLabel();
    
    [vdROCX, vdROCY, vdROCT, dAUC] = perfcurve(vbTestingIsPositive, vdTestingConfidences, true);
    
    [~,dPointIndexForOptThres] = min(abs(vdROCT - dOptThres));
    
    % get FPR, FNR and MCR from ROC
    dFPR = vdROCX(dPointIndexForOptThres,:); % since ROC
    dTPR = vdROCY(dPointIndexForOptThres,:); % since ROC
    
    dFNR = 1-dTPR; % by defn
    dTNR = 1-dFPR; % by defn
    
    dNumPositives = sum(vbTestingIsPositive);
    dNumNegatives = sum(~vbTestingIsPositive);
    
    dFP = dFPR * dNumNegatives; % by defn
    dFN = dFNR * dNumPositives; % by defn
    
    dMCR = (dFP + dFN) ./ (dNumPositives + dNumNegatives);
    
    
    
    
    vsErrorMetrics = [...
        string(dNumberOfFeatures) + " Features",...
        string(round(dAUC,2)),...
        string(round(100*dMCR,1)),...
        string(round(100*dFNR,1)),...
        string(round(100*dFPR,1))];
    disp(vsErrorMetrics);


end
