classdef Source < symphonyui.core.persistent.Entity

    properties
        label
    end
    
    properties (SetAccess = private)
        creationTime
        parent
        experiment
    end

    methods
        
        function obj = Source(cobj, factory)
            obj@symphonyui.core.persistent.Entity(cobj, factory);
        end
        
        function p = createPreset(obj, name)
            p = createPreset@symphonyui.core.persistent.Entity(obj, name);
            p.classProperties('label') = obj.label;
        end
        
        function applyPreset(obj, preset)
            applyPreset@symphonyui.core.persistent.Entity(obj, preset);
            obj.label = preset.classProperties('label');
        end

        function l = get.label(obj)
            l = char(obj.cobj.Label);
        end
        
        function set.label(obj, l)
            obj.cobj.Label = l;
        end
        
        function t = get.creationTime(obj)
            t = obj.datetimeFromDateTimeOffset(obj.cobj.CreationTime);
        end

        function s = getSources(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.Sources, @(ce)obj.entityFactory.create(ce));
        end

        function s = getAllSources(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.AllSources, @(ce)obj.entityFactory.create(ce));
        end

        function g = getEpochGroups(obj)
            g = obj.cellArrayFromEnumerable(obj.cobj.EpochGroups, @(ce)obj.entityFactory.create(ce));
        end

        function g = getAllEpochGroups(obj)
            g = obj.cellArrayFromEnumerable(obj.cobj.AllEpochGroups, @(ce)obj.entityFactory.create(ce));
        end

        function s = get.parent(obj)
            csrc = obj.cobj.Parent;
            if isempty(csrc)
                s = [];
            else
                s = obj.entityFactory.create(csrc);
            end
        end

        function e = get.experiment(obj)
            e = obj.entityFactory.create(obj.cobj.Experiment);
        end
        
        function t = getEntityType(obj) %#ok<MANU>
            t = symphonyui.core.persistent.EntityType.SOURCE;
        end

    end
    
    methods (Static)
        
        function s = newSource(cobj, factory, description)
            symphonyui.core.persistent.Entity.newEntity(cobj, factory, description);
            s = factory.create(cobj);
        end
        
    end

end
