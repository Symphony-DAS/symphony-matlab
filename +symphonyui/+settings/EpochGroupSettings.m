classdef EpochGroupSettings < symphonyui.SettingsBase
    
    properties (SetObservable, AbortSet)
        labelList
        defaultKeywords
    end
    
    properties (Constant, Access = private)
        LABEL_LIST_KEY = 'LABEL_LIST'
        DEFAULT_KEYWORDS_KEY = 'DEFAULT_KEYWORDS'
    end
    
    methods
        
        function l = get.labelList(obj)
            l = obj.get(obj.LABEL_LIST_KEY, 'Control, Drug, Wash');
        end
        
        function k = get.defaultKeywords(obj)
            k = obj.get(obj.DEFAULT_KEYWORDS_KEY, '');
        end
        
    end
    
end

