classdef MatNat < handle
    % MatNat Provides an API for communicating with an XNAT server via REST calls
    %
    %     Licence
    %     -------
    %     Part of MatNat. https://github.com/tomdoel/matnat
    %     Author: Tom Doel, 2015.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %        
    
    properties (Access = private)
        sessionCookie % The JSESSIONID cookie string for this session
        config % a MatNatConfiguration object used to get the server, username etc.
        authenticatedBaseUrl % The URL of the XNAT server for which the session cookie is valid
    end
    
    methods
        function obj = MatNat(config)
            % Creates a new MatNat object using the supplied configuraton
            
            if nargin < 1
                config = MatNatConfiguration;
            else
                if ~isa(config, 'MatNatConfiguration')
                    throw Exception('The configuration object must be of class MatNatConfiguration');
                end
            end
            
            obj.config = config;
        end
        
        function projectList = getProjectList(obj)
            % Returns a cell array of strings containig the project names
            
            projectStruct = obj.request('REST/projects', 'format', 'json', 'owner', 'true', 'member', 'true');
            projectObjList = projectStruct.ResultSet.Result;
            if isempty(projectObjList)
                projectList = [];
            else
                projectList = {projectObjList.name};
            end
        end
    end

    methods (Access = private)
        function returnValue = request(obj, url, varargin)
            % Performs a request call 
            
            if isempty(obj.sessionCookie)
                obj.forceAuthentication;
            end
            options = weboptions('RequestMethod', 'get', 'ContentType','text', 'KeyName', 'Cookie', 'KeyValue', ['JSESSIONID=' obj.sessionCookie], 'MediaType', 'application/json', 'ContentType', 'json');
            returnValue = webread([obj.authenticatedBaseUrl url], varargin{:}, options);
        end
        
        function forceAuthentication(obj)
            % Forces the server to initiate a new session and issue a new
            % session cookie
            
            baseUrl = obj.config.getBaseUrl;
            url = [baseUrl 'data/JSESSION'];
            options = weboptions('Username', obj.config.getUserName, 'Password', obj.config.getPassword);
            obj.sessionCookie = webread(url, options);
            obj.authenticatedBaseUrl = baseUrl;
        end
    end

end

