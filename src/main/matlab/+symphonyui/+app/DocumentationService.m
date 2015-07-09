classdef DocumentationService < handle

    events (NotifyAccess = private)
        OpenedFile
        ClosedFile
        AddedDevice
        AddedSource
        BeganEpochGroup
        EndedEpochGroup
    end
    
    properties (Access = private)
        sessionData
        persistorFactory
        persistorEventManager
    end

    methods

        function obj = DocumentationService(sessionData, persistorFactory)
            obj.sessionData = sessionData;
            obj.persistorFactory = persistorFactory;
            obj.persistorEventManager = symphonyui.ui.util.EventManager();
        end

        function delete(obj)
            if obj.hasOpenFile()
                obj.closeFile();
            end
        end

        function createFile(obj, name, location)
            if obj.hasOpenFile()
                error('A file is already open');
            end
            persistor = obj.persistorFactory.create(name, location);
            obj.setPersistor(persistor);
            notify(obj, 'OpenedFile');
        end

        function openFile(obj, path)
            if obj.hasOpenFile()
                error('A file is already open');
            end
            persistor = obj.persistorFactory.load(path);
            obj.setPersistor(persistor);
            notify(obj, 'OpenedFile');
        end
        
        function closeFile(obj)
            obj.getPersistor().close();
            obj.unsetPersistor();
            notify(obj, 'ClosedFile');
        end
        
        function tf = hasOpenFile(obj)
            tf = obj.hasPersistor();
        end
        
        function e = getExperiment(obj)
            e = obj.getPersistor().experiment;
        end
        
        function d = addDevice(obj, name, manufacturer)
            d = obj.getPersistor().addDevice(name, manufacturer);
        end
        
        function s = addSource(obj, label, parent)
            s = obj.getPersistor().addSource(label, parent);
        end
        
        function g = beginEpochGroup(obj, label, source)
            g = obj.getPersistor().beginEpochGroup(label, source);
        end
        
        function g = endEpochGroup(obj)
            g = obj.getPersistor().endEpochGroup();
        end
        
        function g = getCurrentEpochGroup(obj)
            g = obj.getPersistor().currentEpochGroup;
        end
        
    end
    
    methods (Access = private)
        
        function p = getPersistor(obj)
            if ~obj.hasPersistor()
                error('No persistor');
            end
            p = obj.sessionData.persistor;
        end
        
        function setPersistor(obj, persistor)
            m = obj.persistorEventManager;
            try
                m.addListener(persistor, 'AddedDevice', @(s,d)notify(obj, 'AddedDevice', symphonyui.core.util.DomainEventData(d.data)));
                m.addListener(persistor, 'AddedSource', @(s,d)notify(obj, 'AddedSource', symphonyui.core.util.DomainEventData(d.data)));
                m.addListener(persistor, 'BeganEpochGroup', @(s,d)notify(obj, 'BeganEpochGroup', symphonyui.core.util.DomainEventData(d.data)));
                m.addListener(persistor, 'EndedEpochGroup', @(s,d)notify(obj, 'EndedEpochGroup', symphonyui.core.util.DomainEventData(d.data)));
            catch x
                m.removeAllListeners();
                rethrow(x);
            end
            obj.sessionData.persistor = persistor;
        end
        
        function unsetPersistor(obj)
            obj.persistorEventManager.removeAllListeners();
            obj.sessionData.persistor = [];
        end
        
        function tf = hasPersistor(obj)
            tf = ~isempty(obj.sessionData.persistor);
        end
        
    end

end
