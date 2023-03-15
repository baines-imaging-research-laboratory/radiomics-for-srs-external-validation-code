Experiment.StartNewSection('Analysis');

vdPatientIds = FileIOUtils.LoadMatFile(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('VALID-003'), '01 Validation', 'Validated Patient IDs.mat'), 'vdPatientIds');

% patients are already selected to ensure correct SRS fx (only 1 or 3 fx),
% not on exclusion list, at least one f/u MRI, so only need to select BMs
% that are parenchymnal and not surgical beds
vdPatientIdPerSample = [];
vdBMNumberPerSample = [];

dNumIncorrectPrescription = 0;
dNumNonParenchymal = 0;
dNumSurgicalCavity = 0;

for dPatientIndex=1:length(vdPatientIds)
    oPatient = Patient.LoadFromDatabase(vdPatientIds(dPatientIndex));
    disp(oPatient.GetStudyId());
    
    dNumBMs = oPatient.GetNumberOfBrainMetastases();
    vbIncludeBM = true(dNumBMs,1);
    
    voPrescriptionPerBM = oPatient.GetFirstBrainRadiationCourse().GetPrescriptionPerBrainMetastasis();
    voPreRadiationRadiologyPerBM = oPatient.GetPreRadiationRadiologyAssessment().GetBrainMetastasisRadiologyAssessmentPerBrainMetastasis();
    
    bPatientHasSurgicalCavity = false;
    
    for dBMNumber=1:dNumBMs
        oPrescription = voPrescriptionPerBM(dBMNumber);
        dNumFx = oPrescription.GetNumberOfFractions();
        
        oPreRadiationRadiology = voPreRadiationRadiologyPerBM(dBMNumber);
                
        % - must have received 1 or 3 fx
        if dNumFx ~= 1 && dNumFx ~= 3
            vbIncludeBM(dBMNumber) = false;
            dNumIncorrectPrescription = dNumIncorrectPrescription + 1;     
            
            disp("Not 1 or 3 fx: BM " + string(dBMNumber));
        end
        
        % - must not be a post-resection cavity
        if oPreRadiationRadiology.IsSurgicalCavityPresent()
            vbIncludeBM(dBMNumber) = false;
            dNumSurgicalCavity = dNumSurgicalCavity + 1;   
            
            bPatientHasSurgicalCavity = true;
            
            disp("Surgical cavity: BM " + string(dBMNumber));
        end
        
        % - must be parenchymal
        if ~oPreRadiationRadiology.IsParenchymal()
            vbIncludeBM(dBMNumber) = false;
            dNumNonParenchymal = dNumNonParenchymal + 1;            
            
            disp("Non-parenchymal: BM " + string(dBMNumber));
        end
    end
    
    if ~bPatientHasSurgicalCavity
        vdBMNumbersToInclude = find(vbIncludeBM);
        
        vdPatientIdPerSample = [vdPatientIdPerSample; repmat(oPatient.GetStudyId(), length(vdBMNumbersToInclude), 1)];
        vdBMNumberPerSample = [vdBMNumberPerSample; vdBMNumbersToInclude];
    end
end

% write patient IDs and BM numbers to Excel file
sPatientAndBMIDFilepath = fullfile(Experiment.GetResultsDirectory(), "SRS Analysis Cohort Sample IDs.xlsx");

vsHeaders = ["Patient ID" "BM #"];

writematrix(vsHeaders, sPatientAndBMIDFilepath, 'Range', 'A1');
writematrix(vdPatientIdPerSample, sPatientAndBMIDFilepath, 'Range', 'A2');
writematrix(vdBMNumberPerSample, sPatientAndBMIDFilepath, 'Range', 'B2');

FileIOUtils.SaveMatFile(fullfile(Experiment.GetResultsDirectory(), "SRS Analysis Cohort Sample IDs.mat"), 'vdPatientIdPerSample', vdPatientIdPerSample, 'vdBMNumberPerSample', vdBMNumberPerSample);
