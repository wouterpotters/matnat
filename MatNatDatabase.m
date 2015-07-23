classdef MatNatDatabase < handle
    % MatNatDatabase Contains the database of subjects and data on an XNAT
    % server
    %
    %     Licence
    %     -------
    %     Part of MatNat. https://github.com/tomdoel/matnat
    %     Author: Tom Doel, 2015.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    properties (Access = private)
        RestClient
        Config
        Projects
    end
    
    methods
        function obj = MatNatDatabase(restClient)
            obj.RestClient = restClient;
        end
        
        function projects = getProjects(obj)
            if isempty(obj.Projects)
                obj.populateProjects;
            end
            projects = obj.Projects;
        end
    end
    
    methods (Access = private)
        function populateProjects(obj)
            obj.Projects = obj.RestClient.getProjectList;
        end
    end
end