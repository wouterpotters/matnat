classdef MatNatSession < MatNatBase
    % MatNatSession An object representing an XNAT session
    %
    %     Licence
    %     -------
    %     Part of MatNat. https://github.com/tomdoel/matnat
    %     Author: Tom Doel, 2015.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %        
    
    properties (SetAccess = protected)
        Label
        Id
        ProjectId
        SubjectLabel
    end
    
    properties (Access = private)
        RestClient
        Scans
    end
    
    methods
        function obj = MatNatSession(restClient)
            obj.RestClient = restClient;
        end
        
        function scans = getScans(obj)
            if isempty(obj.Scans)
                obj.populateScans;
            end
            scans = obj.Scans;
        end
    end

    methods (Access = private)
        function populateScans(obj)
            obj.Scans = obj.RestClient.getScanList(obj.ProjectId, obj.SubjectLabel, obj.Label);
        end
    end
        
    methods (Static)
        function obj = createFromServerObject(restClient, serverObject, projectId, subjectLabel)
            % Creates a MatNatSession based on the information
            % structure returned from the XNAT server
            
            obj = MatNatSession(restClient);
            obj.ProjectId = projectId;
            obj.SubjectLabel = subjectLabel;
            obj.Label = MatNatBase.getOptionalProperty(serverObject, 'label');
            obj.Id = MatNatBase.getOptionalProperty(serverObject, 'ID');
        end
    end
end

