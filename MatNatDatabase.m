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
        
        function populate(obj)
            obj.Projects = obj.RestClient.getProjectList;
            for project = obj.Projects
                subjects = obj.RestClient.getSubjectList(project.Id);
                project.setSubjects(subjects);
                for subject = subjects
                    sessions = obj.RestClient.getSessionList(project.Id, subject.Label);
                    subject.setSessions(sessions);
                    subject.resetScans;
                    for session = sessions
                        scans = obj.RestClient.getScanList(project.Id, subject.Label, session.Label);
                        session.setScans(scans);
                        subject.addScans(scans);
                        for scan = scans
                            disp(['   SCAN:' scan.Id ' MODALITY:' scan.Modality.Name]);
                        end
                    end
                end
            end
            
        end
    end
    
end

