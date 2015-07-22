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
        
        Scans
    end
    
     methods
        function setScans(obj, scans)
            obj.Scans = scans;
        end        
    end
    
    methods (Static)
        function obj = createFromServerObject(serverObject)
            % Creates a MatNatSession based on the information
            % structure returned from the XNAT server
            
            obj = MatNatSession;
            obj.Label = MatNatBase.getOptionalProperty(serverObject, 'label');
            obj.Id = MatNatBase.getOptionalProperty(serverObject, 'ID');
        end
    end
end

