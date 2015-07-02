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
            c = obj.cellArrayFromEnumerable(obj.cobj.EpochGroups);
            g = cell(1, numel(c));
            for i = 1:numel(c)
                g{i} = symphonyui.core.persistent.EpochGroup(c{i});
            end
        end
        
        function g = get.epochBlocks(obj)
            c = obj.cellArrayFromEnumerable(obj.cobj.EpochBlocks);
            g = cell(1, numel(c));
            for i = 1:numel(c)
                g{i} = symphonyui.core.persistent.EpochBlock(c{i});
            end
        end
        
    end
    
end

