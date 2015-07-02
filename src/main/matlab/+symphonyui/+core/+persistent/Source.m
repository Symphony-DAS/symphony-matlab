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
            c = obj.cellArrayFromEnumerable(obj.cobj.Sources);
            s = cell(1, numel(c));
            for i = 1:numel(c)
                s{i} = symphonyui.core.persistent.Source(c{i});
            end
        end
        
        function g = get.epochGroups(obj)
            c = obj.cellArrayFromEnumerable(obj.cobj.EpochGroups);
            g = cell(1, numel(c));
            for i = 1:numel(c)
                g{i} = symphonyui.core.persistent.EpochGroup(c{i});
            end
        end
        
        function g = get.allEpochGroups(obj)
            c = obj.cellArrayFromEnumerable(obj.cobj.AllEpochGroups);
            g = cell(1, numel(c));
            for i = 1:numel(c)
                g{i} = symphonyui.core.persistent.EpochGroup(c{i});
            end
        end
        
    end
    
end

