classdef MatNatModality
    % MatNatModality Enumeration representing a modality for imaging data
    %
    %     Licence
    %     -------
    %     Part of MatNat. https://github.com/tomdoel/matnat
    %     Author: Tom Doel, 2015.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %        

    properties
        Name
        XnatType
    end
    
    methods
        function obj = MatNatModality(name, xnatType)
            obj.Name = name;
            obj.XnatType = xnatType;
        end
    end

    enumeration
        MR ('MR', 'xnat:mrScanData')
        PET ('PET', 'xnat:petScanData')
        CT ('CT', 'xnat:ctScanData')
        EPS ('EPS', 'xnat:epsScanData')
        HD ('HD', 'xnat:hdScanData')
        ECG ('ECG', 'xnat:ecgScanData')
        US ('US', 'xnat:usScanData')
        IO ('IO', 'xnat:ioScanData')
        MG ('MG', 'xnat:mgScanData')
        DX ('DX', 'xnat:dxScanData')
        CR ('CR', 'xnat:crScanData')
        GMV ('GMV', 'xnat:gmvScanData')
        GM ('GM', 'xnat:gmScanData')
        ESV ('ESV', 'xnat:esvScanData')
        ES ('ES', 'xnat:esScanData')
        NM ('NM', 'xnat:nmScanData')
        DX3DCraniofacial ('DX3DCraniofacial', 'xnat:dx3DCraniofacialScanData')
        XA3D ('XA3D', 'xnat:xa3DScanData')
        RF ('RF', 'xnat:rfScanData')
        XA ('XA', 'xnat:xaScanData')
        SM ('SM', 'xnat:smScanData')
        XC ('XC', 'xnat:xcScanData')
        XCV ('XCV', 'xnat:xcvScanData')
        OP ('OP', 'xnat:opScanData')
        OPT ('OPT', 'xnat:optScanData')
        RTImage ('RTImage', 'xnat:rtImageScanData')
        SC ('SC', 'xnat:scScanData')
        Seg ('Seg', 'xnat:segScanData')
        MRS ('MRS', 'xnat:mrsScanData')
        VoiceAudio ('VoiceAudio', 'xnat:voiceAudioScanData')
        OtherDicom ('OtherDicom', 'xnat:otherDicomScanData')
    end
    
    properties
    end
    
    methods (Static)
        function modality = getModalityFromXnatString(xnatType)
            % Get the modality type from the Xnat type string
            
            allEnums = enumeration('MatNatModality');
            for enum = allEnums.'
                if strcmp(xnatType, enum.XnatType)
                    modality = enum;
                    return;
                end
            end
            modality = [];
        end
    end
end

