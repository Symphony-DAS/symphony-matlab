classdef Source < symphonyui.core.persistent.Entity

    properties
        label
    end
    
    properties (SetAccess = private)
        sources
        allSources
        epochGroups
        allEpochGroups
        parent
        experiment
    end

    methods
        
        function obj = Source(cobj)
            obj@symphonyui.core.persistent.Entity(cobj);
        end
        
        function p = createPreset(obj, name)
            p = symphonyui.core.persistent.SourcePreset(name,  obj.getDescriptionType(), obj.getProperties(), obj.label);
        end
        
        function applyPreset(obj, preset)
            applyPreset@symphonyui.core.persistent.Entity(obj, preset);
            obj.label = preset.label;
        end

        function l = get.label(obj)
            l = char(obj.cobj.Label);
        end
        
        function set.label(obj, l)
            obj.cobj.Label = l;
        end

        function s = get.sources(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.Sources, @symphonyui.core.persistent.Source);
        end

        function s = get.allSources(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.AllSources, @symphonyui.core.persistent.Source);
        end

        function g = get.epochGroups(obj)
            g = obj.cellArrayFromEnumerable(obj.cobj.EpochGroups, @symphonyui.core.persistent.EpochGroup);
        end

        function g = get.allEpochGroups(obj)
            g = obj.cellArrayFromEnumerable(obj.cobj.AllEpochGroups, @symphonyui.core.persistent.EpochGroup);
        end

        function s = get.parent(obj)
            csrc = obj.cobj.Parent;
            if isempty(csrc)
                s = [];
            else
                s = symphonyui.core.persistent.Source(csrc);
            end
        end

        function e = get.experiment(obj)
            e = symphonyui.core.persistent.Experiment(obj.cobj.Experiment);
        end

    end
    
    methods (Static)
        
        function s = newSource(cobj, description)
            symphonyui.core.persistent.Entity.newEntity(cobj, description);
            s = symphonyui.core.persistent.Source(cobj);
        end
        
    end

end
