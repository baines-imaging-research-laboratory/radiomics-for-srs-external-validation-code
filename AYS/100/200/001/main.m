Experiment.StartNewSection('Analysis');

dNumBootstraps = 250;

sExpCode = "EXP-100-500-001";

sResultsDirectory = string(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCode));
[chExpRoot,~] = FileIOUtils.SeparateFilePathAndFilename(sResultsDirectory);
sExpRoot = string(chExpRoot);

copyfile(fullfile(sExpRoot, "Experiment Manifest Codes.mat"), "Experiment Manifest Codes.mat");

% load experiment asset codes
[~, vsClinicalFeatureValueCodes, vsRadiomicFeatureValueCodes, sLabelsCode, sModelCode, sHPOCode, sObjFcnCodeForHPO, sFeatureSelectorCode] = ...
    ExperimentManager.LoadExperimentManifestCodesMatFile();

% load experiment assets
oClinicalDataSet = ExperimentManager.GetLabelledFeatureValues(...
    vsClinicalFeatureValueCodes,...
    sLabelsCode);

oRadiomicDataSet = ExperimentManager.GetLabelledFeatureValues(...
    vsRadiomicFeatureValueCodes,...
    sLabelsCode);

if ~isempty(oRadiomicDataSet)
    if ~isempty(oClinicalDataSet)
        oReferenceDataSet = [oRadiomicDataSet oClinicalDataSet];
    else
        oReferenceDataSet = oRadiomicDataSet;
    end
else
    oReferenceDataSet = oClinicalDataSet;
end

% get positive vs negative samples
vbIsPositive = oReferenceDataSet.GetLabels() == oReferenceDataSet.GetPositiveLabel();

vdGroups = [0 1]; % Group 0: VUMC, Group 1: LRCP
vdGroupPerSample = oReferenceDataSet.GetGroupIds() < 10000; 
dNumGroups = length(unique(vdGroupPerSample));

viGroupIds = oReferenceDataSet.GetGroupIds();
viSubGroupIds = oReferenceDataSet.GetSubGroupIds();

% load guess result objects
[c1oGuessResultsPerPartition, c1oOOBSamplesGuessResultsPerPartition] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCode), '02 Bootstrapped Iterations', 'Partitions & Guess Results.mat'),...
    'c1oGuessResultsPerPartition','c1oOOBSamplesGuessResultsPerPartition');

m2dConfidencePerSamplePerBootstrap = nan(oReferenceDataSet.GetNumberOfSamples(), dNumBootstraps);
m2dOOBConfidencePerSamplePerBootstrap = nan(oReferenceDataSet.GetNumberOfSamples(), dNumBootstraps);

for dBootstrapIndex=1:length(c1oGuessResultsPerPartition)
    oGuessResult = c1oGuessResultsPerPartition{dBootstrapIndex};
    
    vdPositiveConfidences = oGuessResult.GetPositiveLabelConfidences();
    
    viGuessResultGroupIds = oGuessResult.GetGroupIds();
    viGuessResultSubGroupIds = oGuessResult.GetSubGroupIds();
    
    for dSampleIndex=1:oGuessResult.GetNumberOfSamples()
        vbOriginalSampleIndex = viGuessResultGroupIds(dSampleIndex) == viGroupIds & viGuessResultSubGroupIds(dSampleIndex) == viSubGroupIds;
        
        m2dConfidencePerSamplePerBootstrap(vbOriginalSampleIndex, dBootstrapIndex) = vdPositiveConfidences(dSampleIndex);
    end
    
    
    vdOOBPositiveConfidences = c1oOOBSamplesGuessResultsPerPartition{dBootstrapIndex}.GetPositiveLabelConfidences();
    
    viOOBGuessResultGroupIds = c1oOOBSamplesGuessResultsPerPartition{dBootstrapIndex}.GetGroupIds();
    viOOBGuessResultSubGroupIds = c1oOOBSamplesGuessResultsPerPartition{dBootstrapIndex}.GetSubGroupIds();
    
    for dOriginalSampleIndex=1:oReferenceDataSet.GetNumberOfSamples()
        vdOOBSampleIndices = find(viOOBGuessResultGroupIds == viGroupIds(dOriginalSampleIndex) & viOOBGuessResultSubGroupIds == viSubGroupIds(dOriginalSampleIndex));
        
        if ~isempty(vdOOBSampleIndices)
            m2dOOBConfidencePerSamplePerBootstrap(dOriginalSampleIndex, dBootstrapIndex) = mean(vdOOBPositiveConfidences(vdOOBSampleIndices));
        end
    end
end





hFig = figure();
hold('on');

m2dAUCAndErrorPerGroup = zeros(3,dNumGroups);
m2dPRAUCAndErrorPerGroup = zeros(3,dNumGroups);

m2dFPRAndErrorPerGroup = zeros(3,dNumGroups);
m2dFNRAndErrorPerGroup = zeros(3,dNumGroups);
m2dMCRAndErrorPerGroup = zeros(3,dNumGroups);

for dGroupIndex=1:dNumGroups
    c1vdConfidencesPerBootstrap = cell(dNumBootstraps,1);
    c1vdTrueLabelsPerBootstrap = cell(dNumBootstraps,1);
    
    vbNonEmptyConfidencesPerBootstrap = false(dNumBootstraps,1);
    
    c1vdOOBConfidencesPerBootstrap = cell(dNumBootstraps,1);
    c1vdOOBTrueLabelsPerBootstrap = cell(dNumBootstraps,1);
    
    vbNonEmptyOOBConfidencesPerBootstrap = false(dNumBootstraps,1);
    
    dPosLabel = oReferenceDataSet.GetPositiveLabel();
    
    vbInGroup = vdGroupPerSample == vdGroups(dGroupIndex);
        
    for dBootstrapIndex=1:dNumBootstraps
        vdConfidences = m2dConfidencePerSamplePerBootstrap(:,dBootstrapIndex);
        
        vbSampleInBootstrap = ~isnan(vdConfidences);
        
        vdConfidencesForBootstrap = vdConfidences(vbSampleInBootstrap);
        vbIsPositiveForBootstrap = vbIsPositive(vbSampleInBootstrap);
        vbInGroupForBootstrap = vbInGroup(vbSampleInBootstrap);
        
        vdConfidencesForAnalysis = vdConfidencesForBootstrap(vbInGroupForBootstrap);
        vbIsPositiveForAnalysis = vbIsPositiveForBootstrap(vbInGroupForBootstrap);
        
        
        oOOBGuessResult = c1oOOBSamplesGuessResultsPerPartition{dBootstrapIndex};
        
        vdOOBConfidences = oOOBGuessResult.GetPositiveLabelConfidences();
        vbOOBIsPositive = oOOBGuessResult.GetLabels() == oOOBGuessResult.GetPositiveLabel();
        
        viOOBGroupIds = oOOBGuessResult.GetGroupIds();
        viOOBSubGroupIds = oOOBGuessResult.GetSubGroupIds();
        
        dNumOOBSamples = oOOBGuessResult.GetNumberOfSamples();
        
        vbOOBSampleInGroup = false(dNumOOBSamples,1);
        
        for dOOBSampleIndex=1:dNumOOBSamples
            iGroupId = viOOBGroupIds(dOOBSampleIndex);
            iSubGroupId = viOOBSubGroupIds(dOOBSampleIndex);
            
            dOrigSampleIndex = find(iGroupId == viGroupIds & iSubGroupId == viSubGroupIds);
            
            vbOOBSampleInGroup(dOOBSampleIndex) = vbInGroup(dOrigSampleIndex);
        end
        
        vdOOBConfidencesForAnalysis = vdOOBConfidences(vbOOBSampleInGroup);
        vbOOBIsPositiveForAnalysis = vbOOBIsPositive(vbOOBSampleInGroup);
        
        
        % Gather raw confidences and label from all bootstraps for use
        % with Matlab's perfcurve
        c1vdConfidencesPerBootstrap{dBootstrapIndex} = vdConfidencesForAnalysis;
        c1vdTrueLabelsPerBootstrap{dBootstrapIndex} = double(vbIsPositiveForAnalysis);
        
        vbNonEmptyConfidencesPerBootstrap(dBootstrapIndex) = ~isempty(vdConfidencesForAnalysis);
        
        c1vdOOBConfidencesPerBootstrap{dBootstrapIndex} = vdOOBConfidencesForAnalysis;
        c1vdOOBTrueLabelsPerBootstrap{dBootstrapIndex} = double(vbOOBIsPositiveForAnalysis);
        
        vbNonEmptyOOBConfidencesPerBootstrap(dBootstrapIndex) = ~isempty(vdOOBConfidencesForAnalysis);
        
    end
    
    c1vdConfidencesPerBootstrap = c1vdConfidencesPerBootstrap(vbNonEmptyConfidencesPerBootstrap);
    c1vdTrueLabelsPerBootstrap = c1vdTrueLabelsPerBootstrap(vbNonEmptyConfidencesPerBootstrap);
    
    c1vdOOBConfidencesPerBootstrap = c1vdOOBConfidencesPerBootstrap(vbNonEmptyOOBConfidencesPerBootstrap);
    c1vdOOBTrueLabelsPerBootstrap = c1vdOOBTrueLabelsPerBootstrap(vbNonEmptyOOBConfidencesPerBootstrap);
    
    % Use perfcurve and non-OOB samples to calculate AUC and PRAUC
    [m2dX, m2dY, vdT, vdAUC] = perfcurve(c1vdTrueLabelsPerBootstrap, c1vdConfidencesPerBootstrap, dPosLabel, 'TVals', 0:0.001:1);
    [~, ~, ~, vdPRAUC] = perfcurve(c1vdTrueLabelsPerBootstrap, c1vdConfidencesPerBootstrap, dPosLabel, 'TVals', 0:0.001:1, 'XCrit', 'reca', 'YCrit', 'prec');
    
    m2dAUCAndErrorPerGroup(:, dGroupIndex) = vdAUC;
    m2dPRAUCAndErrorPerGroup(:, dGroupIndex) = vdPRAUC;
    
    
    
    
    % Use perfcurve and OOB samples to find optimal threshold (upper
    % left)
    [m2dOOBX, m2dOOBY, vdOOBT, vdOOBAUC] = perfcurve(c1vdOOBTrueLabelsPerBootstrap, c1vdOOBConfidencesPerBootstrap, dPosLabel, 'TVals', 0:0.001:1);
    
    vdUpperLeftDist = ((m2dOOBX(:,1)).^2) + ((1-m2dOOBY(:,1)).^2);
    [~,dMinIndex] = min(vdUpperLeftDist);
    dOptThres = vdOOBT(dMinIndex);
    
    % find the corresponding closest point on the non-OOB ROC for the
    % same threshold
    [~,dPointIndexForOptThres] = min(abs(dOptThres - vdT(:,1)));
    
    % get FPR, FNR and MCR from ROC
    vdFPR = m2dX(dPointIndexForOptThres,:); % since ROC
    vdTPR = m2dY(dPointIndexForOptThres,:); % since ROC
    
    vdFNR = 1-vdTPR; % by defn
    vdTNR = 1-vdFPR; % by defn
    
    vdFNR([2,3]) = vdFNR([3,2]); % CIs are backwards
    vdTNR([2,3]) = vdTNR([3,2]); % CIs are backwards
    
    m2dFPRAndErrorPerGroup(:, dGroupIndex) = vdFPR;
    m2dFNRAndErrorPerGroup(:, dGroupIndex) = vdFNR;
    
    dNumPos = sum(vbIsPositive == 1);
    dNumNeg = sum(vbIsPositive == 0);
    
    vdFP = vdFPR * dNumNeg; % by defn
    vdFN = vdFNR * dNumPos; % by defn
    
    vdMCR = (vdFP + vdFN) ./ (dNumPos + dNumNeg);
    m2dMCRAndErrorPerGroup(:, dGroupIndex) = vdMCR;
    
    
    
    hROC = plot(m2dX(:,1), m2dY(:,1), '-', 'LineWidth', 1.5);
    
    hPatch = patch('XData', [m2dX(:,2); flipud(m2dX(:,3))], 'YData', [m2dY(:,3); flipud(m2dY(:,2))]);
    hPatch.FaceColor = hROC.Color;
    hPatch.LineStyle = 'none';
    hPatch.FaceAlpha = 0.25;
    
    %operating point
    plot(m2dX(dPointIndexForOptThres,1), m2dY(dPointIndexForOptThres,1), 'Marker', '+', 'MarkerSize', 8, 'Color', [0 0 0], 'LineWidth', 1.5);
    
    % save data to mat file
    FileIOUtils.SaveMatFile(fullfile(Experiment.GetResultsDirectory(), "ROC and Error Metrics (Group " + string(vdGroups(dGroupIndex)) + ").mat"),...
        'm2dROCXWithCI', m2dX, 'm2dROCYWithCI', m2dY,...
        'vdOperatingPoint', [m2dX(dPointIndexForOptThres,1), m2dY(dPointIndexForOptThres,1)],...
        'vdAUCWithCI', vdAUC,...
        'vdFNRWithCI',vdFNR, 'vdFPRWithCI', vdFPR, 'vdMCRWithCI', vdMCR);
end

FileIOUtils.SaveMatFile(fullfile(Experiment.GetResultsDirectory(), 'Error Metrics Per Centre.mat'),...
    'vdGroupPerSample', vdGroupPerSample, 'vdGroups', vdGroups,...
    ...
    'vdAUCFromMeanROCPerGroup', squeeze(m2dAUCAndErrorPerGroup(1,:)),...
    'm2dAUC95ConfidenceIntervalFromMeanROCPerGroup', m2dAUCAndErrorPerGroup(2:3,:),...
    'vdPRAUCFromMeanPRCPerGroup', squeeze(m2dPRAUCAndErrorPerGroup(1,:)),...
    'm2dPRAUC95ConfidenceIntervalFromMeanPRCPerGroup', m2dPRAUCAndErrorPerGroup(2:3,:),...
    'vdMCRFromMeanROCPerGroup', squeeze(m2dMCRAndErrorPerGroup(1,:)),...
    'm2dMCR95ConfidenceIntervalFromMeanROCPerGroup', m2dMCRAndErrorPerGroup(2:3,:),...
    'vdFPRFromMeanROCPerGroup', squeeze(m2dFPRAndErrorPerGroup(1,:)),...
    'm2dFPR95ConfidenceIntervalFromMeanROCPerGroup', m2dFPRAndErrorPerGroup(2:3,:),...
    'vdFNRFromMeanROCPerGroup', squeeze(m2dFNRAndErrorPerGroup(1,:)),...
    'm2dFNR95ConfidenceIntervalFromMeanROCPerGroup', m2dFNRAndErrorPerGroup(2:3,:));

