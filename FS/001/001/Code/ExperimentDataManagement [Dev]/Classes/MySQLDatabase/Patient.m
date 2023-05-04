classdef Patient < handle
    %Patient
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dStudyId (1,1) double
        
        dtAgeAtFirstBrainRTTreatment (1,1) calendarDuration % rounded to nearest month as to not reveal DOB given known brain RT date
        dtSurvivalTimeFromFirstBrainRTTreatment calendarDuration {ValidationUtils.MustBeEmptyOrScalar} % rounded to nearest month as to not reveal DOD given known brain RT data; can be empty if patient not deceased; if deceased status is Likely, then date of last interaction is used as a surrogate for DOD

        eDeathStatus (1,1) REDCapPatientDeathStatus
        
        eGender (1,1) REDCapGender
        
        voBrainMetastases (:,1) BrainMetastasis {ValidationUtils.MustBeInOrder(voBrainMetastases, @GetBrainMetastasisNumber, 'ascend')} = BrainMetastasis.empty(0,1)
        
        voImagingSeries (:,1) ImagingSeries
        voImagingSeriesRegistrations (:,1) ImagingSeriesRegistrations
    end
    
    properties (Constant = true, GetAccess = private)
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function dStudyId = GetStudyId(obj)
            dStudyId = obj.dStudyId;
        end
    end
    
    methods (Access = public, Static)
        
        function oPatient = GetByStudyId(dStudyId)
            arguments
                dStudyId (1,1) double
            end
            
            oPatient = Patient.GetByStudyIds(dStudyId);
        end
        
        function voPatients = GetByStudyIds(vdStudyIds)
            arguments
                vdStudyIds (:,1) double
            end
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "patients", [], "WHERE patient_study_id IN (" + strjoin(string(vdStudyIds), ", ") + ")");
            
            dNumPatients = size(tOutput,1);
            c1oPatients = cell(dNumPatients,1);
            
            for dPatientIndex=1:dNumPatients
                eDeathStatus = REDCapPatientDeathStatus.GetFromMySQLEnumCode(tOutput.deceased_status(dPatientIndex));
                
                if eDeathStatus ~= REDCapPatientDeathStatus.NotDeceased
                    dtSurvival = calmonths(tOutput.survival_time_months(dPatientIndex));
                else
                    dtSurvival = datetime.empty;
                end
                
                c1oPatients{dPatientIndex} = Patient(...
                    tOutput.patient_study_id(dPatientIndex),...
                    REDCapGender.GetFromMySQLEnumCode(tOutput.sex(dPatientIndex)),...
                    calmonths(tOutput.age_at_first_srs_srt_months(dPatientIndex)),...
                    eDeathStatus,...
                    dtSurvival,...
                    BrainMetastasis.GetFromDatabaseByPatientStudyId(tOutput.patient_study_id(dPatientIndex)));
            end
            
            voPatients = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oPatients);
        end
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
        
        function obj = Patient(dStudyId, eGender, dtAgeAtFirstBrainRTTreatment, eDeathStatus, dtSurvivalTimeFromFirstBrainRTTreatment, voBrainMetastases)
            obj.dStudyId = dStudyId;
            
            obj.dtAgeAtFirstBrainRTTreatment = dtAgeAtFirstBrainRTTreatment;
            obj.dtSurvivalTimeFromFirstBrainRTTreatment = dtSurvivalTimeFromFirstBrainRTTreatment;
            
            obj.eDeathStatus = eDeathStatus;
            
            obj.eGender = eGender;
            
            obj.voBrainMetastases = voBrainMetastases;
        end
    end
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)
    end
end

