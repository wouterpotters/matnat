classdef MatNatResource < MatNatBase
    % MatNatResource An object representing an XNAT resource
    %
    %     Licence
    %     -------
    %     Part of MatNat. https://github.com/tomdoel/matnat
    %     Author: Tom Doel, 2015.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %        
    
    properties (SetAccess = protected)
        Label
        FileCount
        Format
    end
    
    properties (Access = private)
        RestClient
    end
    
    methods
        function obj = MatNatResource(restClient)
            obj.RestClient = restClient;
        end
    end
    
    methods (Static)
        function obj = createFromServerObject(restClient, serverObject)
            % Creates a MatNatScan based on the information
            % structure returned from the XNAT server
            
            obj = MatNatResource(restClient);
            obj.Label = MatNatBase.getOptionalProperty(serverObject, 'label');
            obj.FileCount = str2num(MatNatBase.getOptionalProperty(serverObject, 'file_count'));
            obj.Format = MatNatBase.getOptionalProperty(serverObject, 'format');
        end
    end
end

