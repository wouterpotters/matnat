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
        
        Sessions
        Scans
    end

     methods
        function setSessions(obj, sessions)
            obj.Sessions = sessions;
        end
        
        function resetScans(obj)
            obj.Scans = MatNatScan.empty;
        end
        
        function addScans(obj, scans)
            obj.Scans = horzcat(obj.Scans, scans);
        end
    end
    
    methods (Static)
        function obj = createFromServerObject(serverObject)
            % Creates a MatNatSubject based on the prosubjectject information
            % structure returned from the XNAT server
            
            obj = MatNatSubject;
            obj.Label = MatNatBase.getOptionalProperty(serverObject, 'label');
            obj.Id = MatNatBase.getOptionalProperty(serverObject, 'ID');
        end  
    end
end

