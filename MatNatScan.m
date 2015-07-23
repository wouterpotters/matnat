classdef MatNatScan < MatNatBase
    % MatNatScan An object representing an XNAT scan
    %
    %     Licence
    %     -------
    %     Part of MatNat. https://github.com/tomdoel/matnat
    %     Author: Tom Doel, 2015.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %        
    
    properties (SetAccess = protected)
        Id
        Modality
        
        ProjectId
        SubjectLabel
        SessionLabel
    end
    
    properties (Access = private)
        RestClient
        Resources
    end
    
    methods
        function obj = MatNatScan(restClient)
            obj.RestClient = restClient;
        end
                
        function resources = getResources(obj)
            if isempty(obj.Resources)
                obj.populateResources
            end
            resources = obj.Resources;
        end
    end
    
    methods (Access = private)
        function populateResources(obj)
            obj.Resources = obj.RestClient.getResourceList(obj.ProjectId, obj.SubjectLabel, obj.SessionLabel, obj.Id);
        end
    end
    
    methods (Static)
        function obj = createFromServerObject(restClient, serverObject, projectId, subjectLabel, sessionLabel)
            % Creates a MatNatScan based on the information
            % structure returned from the XNAT server
            
            obj = MatNatScan(restClient);
            obj.ProjectId = projectId;
            obj.SubjectLabel = subjectLabel;
            obj.SessionLabel = sessionLabel;
            obj.Id = MatNatBase.getOptionalProperty(serverObject, 'ID');
            obj.Modality = MatNatModality.getModalityFromXnatString(MatNatBase.getOptionalProperty(serverObject, 'xsiType'));
        end
    end
end

