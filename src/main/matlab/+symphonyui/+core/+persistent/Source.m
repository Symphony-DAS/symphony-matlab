classdef Source < symphonyui.core.persistent.Entity
    
    properties (SetAccess = private)
        label
        sources
        epochGroups
        allEpochGroups
    end
    
    methods
        
        function obj = Source(cobj)
            obj@symphonyui.core.persistent.Entity(cobj);
        end
        
        function n = get.label(obj)
            n = char(obj.cobj.Label);
        end
        
        function s = get.sources(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.Sources, @symphonyui.core.persistent.Source);
        end
        
        function g = get.epochGroups(obj)
            g = obj.cellArrayFromEnumerable(obj.cobj.EpochGroups, @symphonyui.core.persistent.EpochGroup);
        end
        
        function g = get.allEpochGroups(obj)
            c = obj.cellArrayFromEnumerable(obj.cobj.AllEpochGroups, @symphonyui.core.persistent.EpochGroup);
        end
        
    end
    
end

