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
            
            structFromServer = obj.request('REST/projects', 'format', 'json', 'owner', 'true', 'member', 'true');
            projectList = MatNatProject.empty;
            
            if ~isempty(structFromServer)                
                objectList = structFromServer.ResultSet.Result;
                
                for object = objectList'
                    projectList(end + 1) = MatNatProject.createMatNatProjectFromServerObject(object);
                end
            end
        end
        
        function sessionList = getSessionList(obj, projectName)
            % Returns a cell array of strings containig the session names
            % for the given project
            
            structFromServer = obj.request(['REST/projects/' projectName '/experiments'], 'format', 'json', 'owner', 'true', 'member', 'true');
            sessionList = MatNatSession.empty;            
            
            if ~isempty(structFromServer)
                objectList = structFromServer.ResultSet.Result;                
                for object = objectList'
                    sessionList(end + 1) = MatNatSession.createMatNatSessionFromServerObject(object);
                end
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
            try
                returnValue = webread([obj.authenticatedBaseUrl url], varargin{:}, options);
            catch exception
                if strcmp(exception.identifier, 'MATLAB:webservices:HTTP404StatusCodeError')
                    returnValue = [];
                else
                    rethrow(exception);
                end
            end
        end
        
        function forceAuthentication(obj)
            % Forces the server to initiate a new session and issue a new
            % session cookie
            
            baseUrl = deblank(obj.config.getBaseUrl);
            if baseUrl(end) ~= '/'
                baseUrl = [baseUrl '/'];
            end
            url = [baseUrl 'data/JSESSION'];
            options = weboptions('Username', obj.config.getUserName, 'Password', obj.config.getPassword);
            obj.sessionCookie = webread(url, options);
            obj.authenticatedBaseUrl = baseUrl;
        end
    end

end

