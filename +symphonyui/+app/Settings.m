classdef Settings < handle
    
    methods (Static)
        
        function s = general()
            persistent localObj;
            if isempty(localObj) || ~isvalid(localObj)
                localObj = symphonyui.settings.GeneralSettings();
            end
            s = localObj;
        end
        
        function s = experiment()
            persistent localObj;
            if isempty(localObj) || ~isvalid(localObj)
                localObj = symphonyui.settings.ExperimentSettings();
            end
            s = localObj;          
        end
        
        function s = epochGroup()
            persistent localObj;
            if isempty(localObj) || ~isvalid(localObj)
                localObj = symphonyui.settings.EpochGroupSettings();
            end
            s = localObj;
        end
        
        function s = parse(settingValue)
            s = symphonyui.app.Settings.parseToString(settingValue);
        end
        
        function s = parseToString(settingValue)
            s = settingValue;
            if strncmp(s, '@', 1)
                try %#ok<TRYNC>
                    func = str2func(s);
                    s = char(func());
                end
            end
        end
        
        function c = parseToCell(settingValue)
            s = symphonyui.app.Settings.parseToString(settingValue);
            c = symphonyui.util.strToCell(s);
        end
        
    end
    
end

