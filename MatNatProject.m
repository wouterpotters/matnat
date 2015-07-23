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
       
    properties (Access = private)
        RestClient
        Subjects
    end
    
    methods
        function obj = MatNatProject(restClient)
            obj.RestClient = restClient;
        end
        
        function subjects = getSubjects(obj)
            if isempty(obj.Subjects)
                obj.populateSubjects;
            end
            subjects = obj.Subjects;
        end
    end
    
    methods (Access = private)
        function populateSubjects(obj)
            obj.Subjects = obj.RestClient.getSubjectList(obj.Id);
            end        
    end
    
    methods (Static)
        function obj = createFromServerObject(restClient, serverObject)
            % Creates a MatNatProject based on the project information
            % structure returned from the XNAT server
            
            obj = MatNatProject(restClient);
            obj.Name = MatNatBase.getOptionalProperty(serverObject, 'name');
            obj.Id = MatNatBase.getOptionalProperty(serverObject, 'id');
            obj.SecondaryId = MatNatBase.getOptionalProperty(serverObject, 'secondary_id');
            obj.Description = MatNatBase.getOptionalProperty(serverObject, 'description');
        end    
    end
end

