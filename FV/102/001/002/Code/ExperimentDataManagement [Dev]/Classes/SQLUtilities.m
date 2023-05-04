classdef SQLUtilities
    %SQLUtilities
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = SQLUtilities()        
        end
    end
    
    
    methods (Access = public, Static)
        
        function oSQLDB = ConnectToMySQLDatabase()
            
            [sMySQLDataSourceName, sMySQLServerUsername, sMySQLServerPassword] = FileIOUtils.LoadMatFile(...
                Experiment.GetDataPath('MySQLConnectionSettings'),...
                'sMySQLDataSourceName', 'sMySQLServerUsername', 'sMySQLServerPassword');
            
            oSQLDB = database(sMySQLDataSourceName, sMySQLServerUsername, sMySQLServerPassword);
            oSQLDB.AutoCommit = 'off'; % so bad, why would this not be default
        end
        
        function dIDOfInsertedRow = InsertIntoDatabase(oSQLDB, sTable, vsSQLColumnsToInsert, c1xSQLValuesToInsert)
            arguments
                oSQLDB (1,1) database.odbc.connection
                sTable (1,1) string
                vsSQLColumnsToInsert (1,:) string
                c1xSQLValuesToInsert (1,:) cell
            end
                        
            sColumns = strjoin(vsSQLColumnsToInsert, ", ");
            
            dNumValues = length(c1xSQLValuesToInsert);
            vsValues = strings(1, dNumValues);
            
            for dValueIndex=1:dNumValues
                xValue = c1xSQLValuesToInsert{dValueIndex};
                
                if islogical(xValue)
                    if xValue
                        vsValues(dValueIndex) = "TRUE";
                    else
                        vsValues(dValueIndex) = "FALSE";
                    end
                elseif isnumeric(xValue)
                    vsValues(dValueIndex) = string(xValue);
                elseif isstring(xValue)
                    vsValues(dValueIndex) = "'" + strrep(xValue, '\', '\\') + "'";
                    
                elseif isdatetime(xValue)
                    vsValues(dValueIndex) = string(datestr(xValue, "'yyyy-mm-dd'"));
                else
                    error(...
                        'SQLUtilities:InsertIntoDatabase:InvalidValueType',...
                        'Value must be string or numeric.');
                end
            end
            
            
            sValues = strjoin(vsValues, ", ");
            
            oSQLDB.execute("INSERT INTO " + sTable + " (" + sColumns + ") VALUES (" + sValues + ")");
            
            tOutput = oSQLDB.select('SELECT LAST_INSERT_ID()');
            dIDOfInsertedRow = double(tOutput.LAST_INSERT_ID__);
        end
        
        function tOutput = SelectFromDatabase(oSQLDB, sTable, vsSQLColumnsToInclude, sWhereQuery)
            if isempty(vsSQLColumnsToInclude)
                sColumns = "*";
            else
                sColumns = strjoin(vsSQLColumnsToInclude, ", ");
            end
            
            tOutput = oSQLDB.select("SELECT " + sColumns + " FROM " + sTable + " " + sWhereQuery);
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

