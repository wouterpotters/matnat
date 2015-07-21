classdef MatNatSession < handle
    % MatNatSession An object representing an XNAT session
    %
    %     Licence
    %     -------
    %     Part of MatNat. https://github.com/tomdoel/matnat
    %     Author: Tom Doel, 2015.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %        
    
    properties (SetAccess = private)
        Label
        Id
    end
    
    methods (Static)
        function obj = createMatNatSessionFromServerObject(serverObject)
            % Creates a MatNatSession based on the project information
            % structure returned from the XNAT server
            
            obj = MatNatSession;
            obj.setOptionalProperty(serverObject, 'Label', 'label');
            obj.setOptionalProperty(serverObject, 'Id', 'ID');
        end
        
    end
    
    methods (Access = private)
        function setOptionalProperty(obj, serverObject, propertyName, serverPropertyName)
            if isfield(serverObject, serverPropertyName)
                obj.(propertyName) = serverObject.(serverPropertyName);
            end
        end
    end
    
end

