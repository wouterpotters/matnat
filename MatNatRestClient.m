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
        
        function disp(obj)
            disp(['sessionCookie = ' obj.sessionCookie])
            disp(['authenticatedBaseUrl = ' obj.authenticatedBaseUrl])
            disp('config:')
            fprintf('\b ');
            disp(obj.config)
        end
        
        function projectMap = getProjectMap(obj)
            % Returns a map of project IDs to MatNatProject objects containing project metadata
            
            structFromServer = obj.requestJson('REST/projects', 'format', 'json', 'owner', 'true', 'member', 'true');
            projectMap = containers.Map;
            
            if ~isempty(structFromServer)
                objectList = structFromServer.ResultSet.Result;
                
                for object = objectList'
                    newProject = MatNatProject.createFromServerObject(obj, object);
                    projectMap(newProject.Id) = newProject;
                end
            end
        end
        
        function subjectProperties = getSubjectProperties(obj, projectName, subjectName, varargin)
            % subjectProperties = getSubjectProperties(obj, projectName, subjectName, varargin)
            if ~isempty(varargin)
                if any(~cellfun(@(v) ischar(v),varargin))
                    error('only string properties allowed');
                end
            end
            structFromServer = obj.requestJson(['REST/projects/' projectName '/subjects/' subjectName], 'format', 'json', 'owner', 'true', 'member', 'true', 'columns', 'DEFAULT');
            
            if ~isempty(structFromServer.items.children)
                subjectPropertiesALL = {structFromServer.items.children.field};
            else
                subjectPropertiesALL = {};
            end
            subjectPropertiesDISREGARD = {'experiments/experiment'};
            selection = find(~strcmpi(subjectPropertiesALL,subjectPropertiesDISREGARD));
            if ~isempty(selection)
                for selection_item = selection
                    property_type = subjectPropertiesALL{selection_item};
                    values = structFromServer.items.children(selection_item).items.data_fields;
                    
                    subjectProperties = struct(property_type,struct());
                    for value = fieldnames(values).'
                        subjectProperties.(property_type).(value{1}) = values.(value{1});
                    end
                end
            else
                subjectProperties = struct();
            end
        end
        
        function setSubjectProperties(obj, projectName, subjectName, subjectProperties, varargin)
            % setSubjectProperties(obj, projectName, subjectName, subjectProperties, varargin)
            if ~isempty(varargin)
                if any(~cellfun(@(v) ischar(v),varargin))
                    error('only string properties allowed');
                end
            end
            
            supported_property_types = 'demographics';
            available_property_types = fieldnames(subjectProperties).';
            
            first = true; setInput = '';
            if ~isempty(available_property_types)
                for prop_type = available_property_types(strcmpi(available_property_types,supported_property_types))
                    for prop_element = fieldnames(subjectProperties.(prop_type{1})).'
                        if isempty(strfind(prop_element{1},'xnat'))
                            if ~first
                                setInput = [setInput '&'];
                            end
                            first = false;
                            value = (subjectProperties.(prop_type{1}).(prop_element{1}));
                            if isnumeric(value)
                                value = num2str(value);
                            end
                            setInput = [setInput, prop_element{1}, '=' value];
                        end
                    end
                end
                structFromServer = obj.putJson(['REST/projects/' projectName '/subjects/' subjectName '?' setInput], 'format', 'json', 'owner', 'true', 'member', 'true', 'columns', 'DEFAULT');
            else
                warning('subjectProperty struct empty. Nothing set.')
            end
        end


        
        function subjectMap = getSubjectMap(obj, projectName, varargin)
            % subjectMap = getSubjectMap(obj, projectName, properties)
            % Returns a map of subject IDs to MatNatSubject objects containing subject metadata
            if ~isempty(varargin)
                if any(~cellfun(@(v) ischar(v),varargin))
                    error('only string properties allowed');
                end
            end
            structFromServer = obj.requestJson(['REST/projects/' projectName '/subjects'], 'format', 'json', 'owner', 'true', 'member', 'true', 'columns', 'DEFAULT');
            subjectMap = containers.Map;
            
            if ~isempty(structFromServer)
                objectList = structFromServer.ResultSet.Result;
                for object = objectList'
                    newSubject = MatNatSubject.createFromServerObject(obj, object, projectName);
                    subjectMap(newSubject.Id) = newSubject;
                end
            end
        end
        
        function subjectId = setSubject(obj, projectName, subjectName, varargin)
            % subjectId = setSubject(obj, projectName, subjectName)
            % subjectId = setSubject(obj, projectName, subjectName, 'properties', subjectProperties)
            % Returns a map of subject IDs to MatNatSubject objects containing subject metadata
            if rem(length(varargin),2) ~= 0
                error('use property-name-value pairs to set subject properties.')
            end
            
            subjectId = obj.putJson(['REST/projects/' projectName '/subjects/' subjectName], 'format', 'json', 'owner', 'true', 'member', 'true', 'columns', 'DEFAULT');
            
            if strcmp(varargin{1},'properties')
                obj.setSubjectProperties(projectName, subjectName, varargin{2})
            end
        end
        
        function deleteSubject(obj, projectName, subjectName)
            % deleteSubject(obj, projectName, subjectName)
            warning('DELETING SUBJECT: %s in project %s',subjectName,projectName);
            obj.delete(['REST/projects/' projectName '/subjects/' subjectName '?removeFiles=true'], 'format', 'json', 'owner', 'true', 'member', 'true', 'columns', 'DEFAULT');
        end
        
        %%% DOES NOT WORK WITHOUT scantype ID
        function subjectId = setExperiment(obj, projectName, subjectName, experimentObject)
            % subjectId = setSubject(obj, projectName, subjectName)
            % subjectId = setSubject(obj, projectName, subjectName, 'properties', subjectProperties)
            % Returns a map of subject IDs to MatNatSubject objects containing subject metadata
            fnames = fieldnames(experimentObject);
            prop = '/';
            for fi = fnames(ismember(fnames,{'Date'})).' %only include Date as properties. % exclude 'Label' and 'Type' (xsiType) and the rest here
                prop = strcat(prop,lower(fi{1}),'=',experimentObject.(fi{1}),'/');
            end
            prop = prop(1:end-1);
            subjectId = obj.putJson(['REST/projects/' projectName '/subjects/' subjectName '/experiments/' experimentObject.Label '?' experimentObject.Type prop], 'format', 'json', 'owner', 'true', 'member', 'true', 'columns', 'DEFAULT');
        end

        function subjectId = setExperimentScan(obj, projectName, subjectName, experimentName, scanObject)
            % subjectId = setSubject(obj, projectName, subjectName)
            % subjectId = setSubject(obj, projectName, subjectName, 'properties', subjectProperties)
            % Returns a map of subject IDs to MatNatSubject objects containing subject metadata
            subjectId = obj.putJson(['REST/projects/' projectName '/subjects/' subjectName '/experiments/' experimentName ...
                '/scans/' scanObject.Id '?xsiType=' scanObject.Modality.XnatType ...
                '&' scanObject.Modality.XnatType ...
                '/type=' scanObject.Type, ...
                '&quality=' scanObject.Quality, ...
                '&series_description=' scanObject.Series_Description, ...
                '&note=' scanObject.Note, ...
                ], 'format', 'json', 'owner', 'true', 'member', 'true', 'columns', 'DEFAULT');
        end
        
        function subjectId = setExperimentScanResource(obj, projectName, subjectName, experimentName, scanName, resourceObject)
            % subjectId = setSubject(obj, projectName, subjectName)
            % subjectId = setSubject(obj, projectName, subjectName, 'properties', subjectProperties)
            % Returns a map of subject IDs to MatNatSubject objects containing subject metadata
            try
                subjectId = obj.putJson(['REST/projects/' projectName '/subjects/' subjectName '/experiments/' experimentName ...
                            '/scans/' scanName.Id ...
                            '/resources/' resourceObject.Label ...
                            ], 'format', 'json', 'owner', 'true', 'member', 'true', 'columns', 'DEFAULT');
            catch
                warning('resource already exists?')
            end
        end

        function subjectId = uploadFile(obj, projectName, subjectName, experimentName, scanName, resourceObject, zip_file_to_upload)
            % subjectId = setSubject(obj, projectName, subjectName)
            % subjectId = setSubject(obj, projectName, subjectName, 'properties', subjectProperties)
            % Returns a map of subject IDs to MatNatSubject objects containing subject metadata
            try
                fid = fopen(zip_file_to_upload, 'r');
                zipdata = char(fread(fid)');
                fclose(fid);
            catch someException
                throw(addCause(MException('unableToReadFile',sprintf('Unable to read input file %s.',zip_file_to_upload)),someException));
            end

            subjectId = obj.putZip(['REST/projects/' projectName '/subjects/' subjectName '/experiments/' experimentName ...
                '/scans/' scanName.Id ...
                '/resources/' resourceObject.Label ...
                '/files?extract=true&inbody=true',...
                ], zipdata);
                

        end
        
        function sessionMap = getSessionMap(obj, projectName, subjectName)
            % Returns a map of session IDs to MatNatSession objects containing session metadata
            
            structFromServer = obj.requestJson(['REST/projects/' projectName '/subjects/' subjectName '/experiments'], 'format', 'json', 'owner', 'true', 'member', 'true');
            sessionMap = containers.Map;
            
            if ~isempty(structFromServer)
                objectList = structFromServer.ResultSet.Result;
                for object = objectList'
                    newSession = MatNatSession.createFromServerObject(obj, object, projectName, subjectName);
                    sessionMap(newSession.Id) = newSession;
                end
            end
        end
        
        function scanMap = getScanMap(obj, projectName, subjectName, sessionName)
            % Returns a map of scan IDs to MatNatScan objects containing scan metadata

            structFromServer = obj.requestJson(['REST/projects/' projectName '/subjects/' subjectName '/experiments/' sessionName '/scans'], 'format', 'json', 'owner', 'true', 'member', 'true');
            scanMap = containers.Map;
            
            if ~isempty(structFromServer)
                objectList = structFromServer.ResultSet.Result;
                for object = objectList'
                    newScan = MatNatScan.createFromServerObject(obj, object, projectName, subjectName, sessionName);
                    scanMap(newScan.Id) = newScan;
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
                    resourceList(end + 1) = MatNatResource.createFromServerObject(obj, object, projectName, subjectName, sessionName, scanLabel);
                end
            end
        end        

        function downloadScanToZipFile(obj, zipfileName, projectName, subjectName, sessionName, scanName, resourceName)
            % Downloads a zip file containing the scans

            obj.requestAndSaveFile(zipfileName, ['REST/projects/' projectName '/subjects/' subjectName '/experiments/' sessionName '/scans/' scanName '/resources/' resourceName '/files'], 'format', 'zip');
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

        function returnValue = putJson(obj, url, varargin)
            % Performs a request call
            returnValue = obj.put(url, varargin{:}, 'MediaType', 'application/json', 'ContentType', 'json');
        end
        
        function returnValue = putZip(obj, url, data, varargin)
            % Performs a request call
            returnValue = obj.putData(url, data);%, varargin{:}, 'MediaType', 'application/zip', 'ContentType', 'auto');
        end
        
        function returnValue = put(obj, url, varargin)
            % Performs a request call
            
            if isempty(obj.sessionCookie)
                obj.forceAuthentication;
            end
            options = weboptions('RequestMethod', 'put', 'KeyName', 'Cookie', 'KeyValue', ['JSESSIONID=' obj.sessionCookie]);
            try
                returnValue = webwrite([obj.authenticatedBaseUrl url], options);
            catch exception
                if strcmp(exception.identifier, 'MATLAB:webservices:HTTP404StatusCodeError')
                    returnValue = [];
                else
                    rethrow(exception);
                end
            end
        end
        
        function returnValue = delete(obj, url, varargin)
            if isempty(obj.sessionCookie)
                obj.forceAuthentication;
            end
            options = weboptions('RequestMethod', 'delete', 'KeyName', 'Cookie', 'KeyValue', ['JSESSIONID=' obj.sessionCookie]);
            options.Timeout = 1; % 10 seconds timeout
            try
                returnValue = webwrite([obj.authenticatedBaseUrl url], options);
            catch exception
                if strcmp(exception.identifier, 'MATLAB:webservices:HTTP404StatusCodeError')
                    returnValue = [];
                else
                    rethrow(exception);
                end
            end
        end


        function returnValue = putData(obj, url, data, varargin)
            % Performs a request call with data
            
            if isempty(obj.sessionCookie)
                obj.forceAuthentication;
            end
            options = weboptions('RequestMethod', 'put', 'KeyName', 'Cookie', 'KeyValue', ['JSESSIONID=' obj.sessionCookie],'MediaType','application/zip','CharacterEncoding','ISO-8859-1');
% Long timeouts make matlab nonresponsive...
%             if length(data)/(1024^2) > 2
%                 options.Timeout = length(data)/(1024^2); % assume 1 MB/s transfer rate / processing time?
%             else
                options.Timeout = 5;
%             end
            fprintf('\n Uploading ... \n')
            try
                for ind = 1:2:(nargin-3)
                    try
                        options.(varargin{ind}) = varargin{ind+1};
                    catch err
                        warning(err.message)
                    end
                end
                returnValue = webwrite([obj.authenticatedBaseUrl url], data, options);
            catch exception
                if strcmp(exception.identifier, 'MATLAB:webservices:HTTP404StatusCodeError')
                    returnValue = [];
                else
                    rethrow(exception);
                end
            end
            fprintf(repmat('\b',[1 16]));
        end
        
        function returnValue = requestAndSaveFile(obj, filePath, url, varargin)
            % Performs a request call to obtain and save a resource
            
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

