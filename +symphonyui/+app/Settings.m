classdef Settings < handle
    
    properties (Constant)
        
        generalRigSearchPath = 'generalRigSearchPath'
        
        generalProtocolSearchPath = 'generalProtocolSearchPath'
        
        experimentDefaultName = 'experimentDefaultName'
        
        experimentDefaultLocation = 'experimentDefaultLocation'
        
        epochGroupLabelList = 'epochGroupLabelList'
        
        sourceLabelList = 'sourceLabelList'
        
    end
    
    methods (Static)
        
        function d = getDefault(setting)
            import symphonyui.app.Settings;
            
            switch setting
                case Settings.generalRigSearchPath
                    d = {fullfile(symphonyui.app.App.getRootPath(), 'examples', '+io', '+github', '+symphony_das', '+rigs')};
                case Settings.generalProtocolSearchPath
                    d = {fullfile(symphonyui.app.App.getRootPath(), 'examples', '+io', '+github', '+symphony_das', '+protocols')};
                case Settings.experimentDefaultName
                    d = @()datestr(now, 'yyyy-mm-dd');
                case Settings.experimentDefaultLocation
                    d = @()pwd();
                case Settings.epochGroupLabelList
                    d = {'Control', 'Drug', 'Wash'};
                case Settings.sourceLabelList
                    d = {'Animal', 'Tissue', 'Cell'};
                otherwise
                    error(['No default for setting ' setting]);
            end
        end
    end
    
end