classdef BrainMetastasis < handle
    %BrainMetastasis
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dBrainMetastasisNumber (1,1) double {mustBeInteger, mustBePositive, mustBeLessThanOrEqual(dBrainMetastasisNumber,10)} = 1
        
        sGTVStructureName (1,1) string
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dNumber = GetBrainMetastasisNumber(obj)
            dNumber = obj.dBrainMetastasisNumber;
        end
        
        
    end
    
    
    methods (Access = public, Static)
        
        function voBMs = GetFromDatabaseByPatientStudyId(dPatientStudyId)
            arguments
                dPatientStudyId (1,1) double
            end
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "brain_metastases", [], "WHERE fk_brain_metastases_patient_study_id IN (" + strjoin(string(dPatientStudyId), ", ") + ")");
            
            dNumBMs = size(tOutput,1);
            c1oBMs = cell(dNumBMs,1);
            
            for dBMIndex=1:dNumBMs                
                c1oBMs{dBMIndex} = BrainMetastasis(...
                    tOutput.brain_metastasis_number(dBMIndex),...
                    tOutput.gtv_structure_name(dBMIndex));
            end
            
            voBMs = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oBMs);
        end
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
        
        function obj = BrainMetastasis(dBrainMetastasisNumber, sGTVStructureName)
            obj.dBrainMetastasisNumber = dBrainMetastasisNumber;
            obj.sGTVStructureName = sGTVStructureName;
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

