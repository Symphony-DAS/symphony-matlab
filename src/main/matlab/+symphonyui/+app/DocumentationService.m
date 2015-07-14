classdef DocumentationService < handle

    events (NotifyAccess = private)
        OpenedFile
        ClosedFile
        AddedDevice
        AddedSource
        BeganEpochGroup
        EndedEpochGroup
        BeganEpochBlock
        EndedEpochBlock
        DeletedEntity
    end
    
    properties (Access = private)
        sessionData
        persistorFactory
        persistorListeners
    end

    methods
        
        function obj = DocumentationService(sessionData, persistorFactory)
            obj.sessionData = sessionData;
            obj.persistorFactory = persistorFactory;
            
            persistor = obj.sessionData.persistor;
            if ~isempty(persistor)
                obj.bindPersistor(persistor);
            end
            
            addlistener(obj.sessionData, 'persistor', 'PostSet', @obj.onSessionSetPersistor);
        end
        
        function close(obj)
            if obj.hasOpenFile()
                obj.closeFile();
            end
        end
        
        function tf = hasOpenFile(obj)
            tf = obj.hasCurrentPersistor();
        end
        
        function createFile(obj, name, location)
            if obj.hasOpenFile()
                error('File already open');
            end
            obj.sessionData.persistor = obj.persistorFactory.create(name, location);
        end
        
        function openFile(obj, path)
            if obj.hasOpenFile()
                error('File already open');
            end
            obj.sessionData.persistor = obj.persistorFactory.load(path);
        end
        
        function closeFile(obj)
            obj.getCurrentPersistor().close();
            obj.sessionData.persistor = [];
        end
        
        function tf = hasCurrentPersistor(obj)
            p = obj.sessionData.persistor;
            tf = ~isempty(p) && ~p.isClosed;
        end
        
        function p = getCurrentPersistor(obj)
            if ~obj.hasCurrentPersistor()
                error('No current persistor');
            end
            p = obj.sessionData.persistor;
        end
        
        function e = getCurrentExperiment(obj)
            e = obj.getCurrentPersistor().experiment;
        end
        
        function d = addDevice(obj, name, manufacturer)
            d = obj.getCurrentPersistor().addDevice(name, manufacturer);
        end
        
        function s = addSource(obj, label, parent)
            s = obj.getCurrentPersistor().addSource(label, parent);
        end
        
        function g = beginEpochGroup(obj, label, source)
            g = obj.getCurrentPersistor().beginEpochGroup(label, source);
        end
        
        function g = endEpochGroup(obj)
            g = obj.getCurrentPersistor().endEpochGroup();
        end
        
        function g = getCurrentEpochGroup(obj)
            g = obj.getCurrentPersistor().currentEpochGroup;
        end
        
        function deleteEntity(obj, entity)
            obj.getCurrentPersistor().deleteEntity(entity);
        end
        
    end
    
    methods (Access = private)
        
        function onSessionSetPersistor(obj, ~, ~)
            obj.unbindPersistor();
            
            persistor = obj.sessionData.persistor;
            if isempty(persistor)
                return;
            end
            
            obj.bindPersistor(persistor);
            notify(obj, 'OpenedFile');
        end
        
        function onPersistorClosed(obj, ~, ~)
            obj.unbindPersistor();
            notify(obj, 'ClosedFile');
        end
        
        function bindPersistor(obj, persistor)
            l = {};
            l{end + 1} = addlistener(persistor, 'AddedDevice', @(s,d)notify(obj, 'AddedDevice', symphonyui.core.util.DomainEventData(d.data)));
            l{end + 1} = addlistener(persistor, 'AddedSource', @(s,d)notify(obj, 'AddedSource', symphonyui.core.util.DomainEventData(d.data)));
            l{end + 1} = addlistener(persistor, 'BeganEpochGroup', @(s,d)notify(obj, 'BeganEpochGroup', symphonyui.core.util.DomainEventData(d.data)));
            l{end + 1} = addlistener(persistor, 'EndedEpochGroup', @(s,d)notify(obj, 'EndedEpochGroup', symphonyui.core.util.DomainEventData(d.data)));
            l{end + 1} = addlistener(persistor, 'DeletedEntity', @(s,d)notify(obj, 'DeletedEntity', symphonyui.core.util.DomainEventData(d.data)));
            l{end + 1} = addlistener(persistor, 'Closed', @obj.onPersistorClosed);
            obj.persistorListeners = l;
        end
        
        function unbindPersistor(obj)
            while ~isempty(obj.persistorListeners)
                delete(obj.persistorListeners{1});
                obj.persistorListeners(1) = [];
            end
        end
        
    end

end
