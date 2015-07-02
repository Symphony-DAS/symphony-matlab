classdef Experiment < symphonyui.core.persistent.TimelineEntity
    
    properties (SetAccess = private)
        purpose
        devices
        sources
        epochGroups
    end
    
    methods
        
        function obj = Experiment(cobj)
            obj@symphonyui.core.persistent.TimelineEntity(cobj);
        end
        
        function p = get.purpose(obj)
            p = char(obj.cobj.Purpose);
        end
        
        function d = get.devices(obj)
            c = obj.cellArrayFromEnumerable(obj.cobj.Devices);
            d = cell(1, numel(c));
            for i = 1:numel(c)
                d{i} = symphonyui.core.persistent.Device(c{i});
            end
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
        
    end
    
end

