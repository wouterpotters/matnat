classdef MatNatRestClient < handle
    % MatNatRestClient Provides an API for communicating with an XNAT server via REST calls
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
        function obj = MatNatRestClient(config)
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
            % Returns an array of MatNatProjects containing project metadata
            
            structFromServer = obj.requestJson('REST/projects', 'format', 'json', 'owner', 'true', 'member', 'true');
            projectList = MatNatProject.empty;
            
            if ~isempty(structFromServer)
                objectList = structFromServer.ResultSet.Result;
                
                for object = objectList'
                    projectList(end + 1) = MatNatProject.createFromServerObject(obj, object);
                end
            end
        end
        
        function projectList = getSubjectList(obj, projectName)
            % Returns an array of MatNatSubjects containing subject metadata
            
            structFromServer = obj.requestJson(['REST/projects/' projectName '/subjects'], 'format', 'json', 'owner', 'true', 'member', 'true', 'columns', 'DEFAULT');
            projectList = MatNatSubject.empty;
            
            if ~isempty(structFromServer)
                objectList = structFromServer.ResultSet.Result;
                
                for object = objectList'
                    projectList(end + 1) = MatNatSubject.createFromServerObject(obj, object, projectName);
                end
            end
        end
        
        function sessionList = getSessionList(obj, projectName, subjectName)
            % Returns an array of MatNatSessions containing session metadata
            
            structFromServer = obj.requestJson(['REST/projects/' projectName '/subjects/' subjectName '/experiments'], 'format', 'json', 'owner', 'true', 'member', 'true');
            sessionList = MatNatSession.empty;
            
            if ~isempty(structFromServer)
                objectList = structFromServer.ResultSet.Result;
                for object = objectList'
                    sessionList(end + 1) = MatNatSession.createFromServerObject(obj, object, projectName, subjectName);
                end
            end
        end
        
        function scanList = getScanList(obj, projectName, subjectName, sessionName)
            % Returns an array of MatNatScans containing scan metadata

            structFromServer = obj.requestJson(['REST/projects/' projectName '/subjects/' subjectName '/experiments/' sessionName '/scans'], 'format', 'json', 'owner', 'true', 'member', 'true');
            scanList = MatNatScan.empty;
            
            if ~isempty(structFromServer)
                objectList = structFromServer.ResultSet.Result;
                for object = objectList'
                    scanList(end + 1) = MatNatScan.createFromServerObject(obj, object, projectName, subjectName, sessionName);
                end
            end
        end
        
        function resourceList = getResourceList(obj, projectName, subjectName, sessionName, scanLabel)
            % Returns an array of MatNatScans containing scan metadata

            structFromServer = obj.requestJson(['REST/projects/' projectName '/subjects/' subjectName '/experiments/' sessionName '/scans/' scanLabel '/resources'], 'format', 'json', 'owner', 'true', 'member', 'true');
            resourceList = MatNatResource.empty;
            
            if ~isempty(structFromServer)
                objectList = structFromServer.ResultSet.Result;
                for object = objectList'
                    resourceList(end + 1) = MatNatResource.createFromServerObject(obj, object);
                end
            end
        end        
        
        function downloadScan(obj, fileName, projectName, subjectName, sessionName, scanName, resourceName)
            % Returns an array of MatNatScans containing scan metadata

            obj.requestAndSaveFile(fileName, ['REST/projects/' projectName '/subjects/' subjectName '/experiments/' sessionName '/scans/' scanName '/resources/' resourceName '/files'], 'format', 'zip');
        end        
    end
    
    methods (Access = private)
        function returnValue = requestJson(obj, url, varargin)
            % Performs a request call
            
            returnValue = obj.request(url, varargin{:}, 'MediaType', 'application/json', 'ContentType', 'json');
        end
        
        function returnValue = request(obj, url, varargin)
            % Performs a request call
            
            if isempty(obj.sessionCookie)
                obj.forceAuthentication;
            end
            options = weboptions('RequestMethod', 'get', 'KeyName', 'Cookie', 'KeyValue', ['JSESSIONID=' obj.sessionCookie]);
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
        
        function returnValue = requestAndSaveFile(obj, filePath, url, varargin)
            % Performs a request call
            
            if isempty(obj.sessionCookie)
                obj.forceAuthentication;
            end
            options = weboptions('RequestMethod', 'get', 'KeyName', 'Cookie', 'KeyValue', ['JSESSIONID=' obj.sessionCookie]);
            try
                returnValue = websave(filePath, [obj.authenticatedBaseUrl url], varargin{:}, options);
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

