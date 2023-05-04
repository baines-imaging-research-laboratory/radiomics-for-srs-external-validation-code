classdef LungCancerHistopathologyReport <  MalignantHistopathologyReport
    %LungCancerHistopathologyReport
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        ePDL1Status (1,1) PDL1Status
        eALKStatus (1,1) BiomarkerStatus
        eEGFRStatus (1,1) BiomarkerStatus
        eROS1Status (1,1) BiomarkerStatus
        eBRAFStatus (1,1) BiomarkerStatus
        eKRASStatus (1,1) BiomarkerStatus
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = LungCancerHistopathologyReport(dtDate, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType, ePDL1Status, eALKStatus, eEGFRStatus, eROS1Status, eBRAFStatus, eKRASStatus)
            %obj = LungCancerHistopathologyReport(dtDate, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType, ePDL1Status, eALKStatus, eEGFRStatus, eROS1Status, eBRAFStatus, eKRASStatus)
            
            obj@MalignantHistopathologyReport(dtDate, PrimaryCancerSite.Lung, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType);            
            
            obj.ePDL1Status = ePDL1Status;
            obj.eALKStatus = eALKStatus;
            obj.eEGFRStatus = eEGFRStatus;
            obj.eROS1Status = eROS1Status;
            obj.eBRAFStatus = eBRAFStatus;
            obj.eKRASStatus = eKRASStatus;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
    end
    
    
    methods (Access = public, Static)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                       PROTECTED METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function voValidationRecords = ValidateReport(obj, oParentPatient, voValidationRecords)
            voValidationRecords = ValidateReport@MalignantHistopathologyReport(obj, oParentPatient, voValidationRecords);
            
            % - ePDL1Status
            % none
            
            % - eALKStatus
            % none
            
            % - eEGFRStatus
            % none
            
            % - eROS1Status
            % none
            
            % eBRAFStatus
            % none
            
            % eKRASStatus
            % none
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
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

