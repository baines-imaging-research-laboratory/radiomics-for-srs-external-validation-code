classdef MySQLDatabase < handle
    %MySQLDatabase
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = private)
    end
    
    properties (Constant = true, GetAccess = private)
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
    end
    
    methods (Access = public, Static)
        
        function Connect()
            [sMySQLDataSourceName, sMySQLServerUsername, sMySQLServerPassword] = FileIOUtils.LoadMatFile(...
                Experiment.GetDataPath('MySQLConnectionSettings'),...
                'sMySQLDataSourceName', 'sMySQLServerUsername', 'sMySQLServerPassword');
            
            oSQLDB = database(sMySQLDataSourceName, sMySQLServerUsername, sMySQLServerPassword);
            oSQLDB.AutoCommit = 'off'; % so bad, why would this not be default
            
            global oDatabaseConnection;
            oDatabaseConnection = oSQLDB;
            
            disp('Successfully connected to database');
        end
        
        function oConnection = GetConnection()
            global oDatabaseConnection;
            
            if isempty(oDatabaseConnection)
                MySQLDatabase.Connect();
            end
            
            oConnection = oDatabaseConnection;
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static)
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

