classdef MatNatProject < handle
    % MatNatProject An object representing an XNAT project
    %
    %     Licence
    %     -------
    %     Part of MatNat. https://github.com/tomdoel/matnat
    %     Author: Tom Doel, 2015.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %        
    
    properties (SetAccess = private)
        Name
        Id
        SecondaryId
        Description
    end
    
    methods (Static)
        function obj = createMatNatProjectFromServerObject(serverObject)
            % Creates a MatNatProject based on the project information
            % structure returned from the XNAT server
            
            obj = MatNatProject;
            obj.setOptionalProperty(serverObject, 'Name', 'name');
            obj.setOptionalProperty(serverObject, 'Id', 'id');
            obj.setOptionalProperty(serverObject, 'SecondaryId', 'secondary_id');
            obj.setOptionalProperty(serverObject, 'Description', 'description');
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

