classdef MatNatScan < MatNatBase
    % MatNatScan An object representing an XNAT scan
    %
    %     Licence
    %     -------
    %     Part of MatNat. https://github.com/tomdoel/matnat
    %     Author: Tom Doel, 2015.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %        
    
    properties (SetAccess = protected)
        Id
        Modality
    end
    
    methods (Static)
        function obj = createFromServerObject(serverObject)
            % Creates a MatNatScan based on the information
            % structure returned from the XNAT server
            
            obj = MatNatScan;
            obj.Id = MatNatBase.getOptionalProperty(serverObject, 'ID');
            obj.Modality = MatNatModality.getModalityFromXnatString(MatNatBase.getOptionalProperty(serverObject, 'xsiType'));
        end
    end
end

