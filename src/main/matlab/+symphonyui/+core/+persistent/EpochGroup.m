classdef EpochGroup < symphonyui.core.persistent.TimelineEntity
    
    properties (SetAccess = private)
        label
        source
        epochGroups
        epochBlocks
    end
    
    methods
        
        function obj = EpochGroup(cobj)
            obj@symphonyui.core.persistent.TimelineEntity(cobj);
        end
        
        function p = get.label(obj)
            p = char(obj.cobj.Label);
        end
        
        function s = get.source(obj)
            s = symphonyui.core.persistent.Source(obj.cobj.Source);
        end
        
        function g = get.epochGroups(obj)
            g = obj.cellArrayFromEnumerable(obj.cobj.EpochGroups, @symphonyui.core.persistent.EpochGroup);
        end
        
        function b = get.epochBlocks(obj)
            b = obj.cellArrayFromEnumerable(obj.cobj.EpochBlocks, @symphonyui.core.persistent.EpochBlock);
        end
        
    end
    
end

