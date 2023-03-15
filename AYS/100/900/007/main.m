Experiment.StartNewSection('Figures');

sExpCode = "AYS-100-200-003";

[m2dROCXWithCI_VUMC, m2dROCYWithCI_VUMC, vdOperatingPoint_VUMC, vdAUCWithCI_VUMC, vdFNRWithCI_VUMC, vdFPRWithCI_VUMC, vdMCRWithCI_VUMC] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCode), '01 Analysis', 'ROC and Error Metrics (Group 0).mat'),...
    'm2dROCXWithCI', 'm2dROCYWithCI', 'vdOperatingPoint', 'vdAUCWithCI', 'vdFNRWithCI', 'vdFPRWithCI', 'vdMCRWithCI');

[m2dROCXWithCI_LRCP, m2dROCYWithCI_LRCP, vdOperatingPoint_LRCP, vdAUCWithCI_LRCP, vdFNRWithCI_LRCP, vdFPRWithCI_LRCP, vdMCRWithCI_LRCP] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCode), '01 Analysis', 'ROC and Error Metrics (Group 1).mat'),...
    'm2dROCXWithCI', 'm2dROCYWithCI', 'vdOperatingPoint', 'vdAUCWithCI', 'vdFNRWithCI', 'vdFPRWithCI', 'vdMCRWithCI');

hFig = figure();
hold('on');
axis('square');

vdFigDims_cm = [8.6 6.6];

hFig.Units = 'centimeters';

vdPos = hFig.Position;
vdPos(3:4) = vdFigDims_cm;
hFig.Position = vdPos;

hChance = plot([0 1], [0, 1], '--k', 'LineWidth', 1.5);

hROC_VUMC = PlotROCWithErrorBounds(m2dROCXWithCI_VUMC, m2dROCYWithCI_VUMC, [0 0 0]/255);
hROC_LRCP = PlotROCWithErrorBounds(m2dROCXWithCI_LRCP, m2dROCYWithCI_LRCP, [0 0 0]/255);

hROC_VUMC = PlotROCOperatingPoint(vdOperatingPoint_VUMC);
hROC_LRCP = PlotROCOperatingPoint(vdOperatingPoint_LRCP);

ylim([0-0.01, 1+0.01]);
xlim([0-0.01, 1+0.01]);

xticks(0:0.1:1);
yticks(0:0.1:1);

grid('on');

ylabel('True Positive Rate');
xlabel('False Positive Rate');

hAxes = gca;

hAxes.FontSize = 8;
hAxes.FontName = 'Arial';



saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'ROCs Across Available Features (No Legend).svg'));

legend([hROC_VUMC, hROC_LRCP, hChance], "VUMC", "LRCP", "No Skill", "Location", 'southeast');

saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'ROCs Per Centre (With Legend).svg'));
savefig(hFig, fullfile(Experiment.GetResultsDirectory(), 'ROCs Per Centre Features.fig'));

close(hFig);

vsErrorMetricsHeaders = ["Features", "AUC (CI)", "MCR (CI)", "FNR (CI)", "FPR (CI)"];
vsErrorMetrics_VUMC = [...
    "VUMC",...
    string(round(vdAUCWithCI_VUMC(1),2)) + " (" + string(round(mean(abs(vdAUCWithCI_VUMC(2:3) - vdAUCWithCI_VUMC(1))),2)) + ")",... 
    string(round(100*vdMCRWithCI_VUMC(1),1)) + " (" + string(round(100*mean(abs(vdMCRWithCI_VUMC(2:3) - vdMCRWithCI_VUMC(1))),1)) + ")",...
    string(round(100*vdFNRWithCI_VUMC(1),1)) + " (" + string(round(100*mean(abs(vdFNRWithCI_VUMC(2:3) - vdFNRWithCI_VUMC(1))),1)) + ")",...
    string(round(100*vdFPRWithCI_VUMC(1),1)) + " (" + string(round(100*mean(abs(vdFPRWithCI_VUMC(2:3) - vdFPRWithCI_VUMC(1))),1)) + ")"];
vsErrorMetrics_LRCP = [...
    "LRCP",...
    string(round(vdAUCWithCI_LRCP(1),2)) + " (" + string(round(mean(abs(vdAUCWithCI_LRCP(2:3) - vdAUCWithCI_LRCP(1))),2)) + ")",... 
    string(round(100*vdMCRWithCI_LRCP(1),1)) + " (" + string(round(100*mean(abs(vdMCRWithCI_LRCP(2:3) - vdMCRWithCI_LRCP(1))),1)) + ")",...
    string(round(100*vdFNRWithCI_LRCP(1),1)) + " (" + string(round(100*mean(abs(vdFNRWithCI_LRCP(2:3) - vdFNRWithCI_LRCP(1))),1)) + ")",...
    string(round(100*vdFPRWithCI_LRCP(1),1)) + " (" + string(round(100*mean(abs(vdFPRWithCI_LRCP(2:3) - vdFPRWithCI_LRCP(1))),1)) + ")"];
disp([vsErrorMetricsHeaders; vsErrorMetrics_VUMC; vsErrorMetrics_LRCP]);


function [hROC, hPatch] = PlotROCWithErrorBounds(m2dXAndError, m2dYAndError, vdColour)

hROC = plot(m2dXAndError(:,1), m2dYAndError(:,1), '-', 'Color', vdColour, 'LineWidth', 1.5);

hPatch = patch('XData', [m2dXAndError(:,2); flipud(m2dXAndError(:,3))], 'YData', [m2dYAndError(:,3); flipud(m2dYAndError(:,2))]);
hPatch.FaceColor = vdColour;
hPatch.LineStyle = 'none';
hPatch.FaceAlpha = 0.25;

end

function hOperatingPoint = PlotROCOperatingPoint(vdOperatingPoint)

hOperatingPoint = plot(vdOperatingPoint(1), vdOperatingPoint(2), 'Marker', 'o', 'MarkerSize', 5, 'Color', [0 0 0], 'LineWidth',1.5, 'MarkerFaceColor', [1 1 1]);

end