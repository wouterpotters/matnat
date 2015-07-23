classdef MatNatSubject < MatNatBase
    % MatNatSubject An object representing an XNAT subject
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
    end
    
    properties (Access = private)
        RestClient
        Sessions
    end

    methods
        function obj = MatNatSubject(restClient)
            obj.RestClient = restClient;
        end
        
        function sessions = getSessions(obj)
            if isempty(obj.Sessions)
                obj.populateSessions;
            end
            sessions = obj.Sessions;
        end        
    end
    
    methods (Access = private)
        function populateSessions(obj)
            obj.Sessions = obj.RestClient.getSessionList(obj.ProjectId, obj.Label);
        end
    end
    
    methods (Static)
        function obj = createFromServerObject(restClient, serverObject, projectId)
            % Creates a MatNatSubject based on the prosubjectject information
            % structure returned from the XNAT server
            
            obj = MatNatSubject(restClient);
            obj.ProjectId = projectId;
            obj.Label = MatNatBase.getOptionalProperty(serverObject, 'label');
            obj.Id = MatNatBase.getOptionalProperty(serverObject, 'ID');
        end  
    end
end

