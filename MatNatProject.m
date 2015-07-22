classdef MatNatProject < MatNatBase
    % MatNatProject An object representing an XNAT project
    %
    %     Licence
    %     -------
    %     Part of MatNat. https://github.com/tomdoel/matnat
    %     Author: Tom Doel, 2015.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %        
    
    properties (SetAccess = protected)
        Name
        Id
        SecondaryId
        Description
    end
    
    methods (Static)
        function obj = createFromServerObject(serverObject)
            % Creates a MatNatProject based on the project information
            % structure returned from the XNAT server
            
            obj = MatNatProject;
            obj.Name = MatNatBase.getOptionalProperty(serverObject, 'name');
            obj.Id = MatNatBase.getOptionalProperty(serverObject, 'id');
            obj.SecondaryId = MatNatBase.getOptionalProperty(serverObject, 'secondary_id');
            obj.Description = MatNatBase.getOptionalProperty(serverObject, 'description');
        end    
    end
end

