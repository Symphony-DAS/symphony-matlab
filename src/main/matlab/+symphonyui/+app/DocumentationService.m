classdef DocumentationService < handle

    events (NotifyAccess = private)
        CreatedFile
        OpenedFile
        ClosedFile
        AddedSource
        BeganEpochGroup
        EndedEpochGroup
        DeletedEntity
    end

    properties (Access = private)
        log
        session
        persistorFactory
        classRepository
    end

    methods

        function obj = DocumentationService(session, persistorFactory, classRepository)
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.session = session;
            obj.persistorFactory = persistorFactory;
            obj.classRepository = classRepository;
        end

        function d = getAvailableExperimentDescriptions(obj)
            d = obj.classRepository.get('symphonyui.core.persistent.descriptions.ExperimentDescription');
        end

        function p = getFilePath(obj, name, location)
            p = obj.persistorFactory.getPath(name, location);
        end

        function newFile(obj, name, location, description)
            if obj.hasOpenFile()
                error('File already open');
            end
            if ~any(strcmp(description, obj.getAvailableExperimentDescriptions()))
                error([description ' is not an available experiment description']);
            end
            constructor = str2func(description);
            obj.session.persistor = obj.persistorFactory.new(name, location, constructor());
            notify(obj, 'CreatedFile');
        end

        function openFile(obj, path)
            if obj.hasOpenFile()
                error('File already open');
            end
            obj.session.persistor = obj.persistorFactory.open(path);
            notify(obj, 'OpenedFile');
        end

        function closeFile(obj)
            group = obj.getCurrentEpochGroup();
            while ~isempty(group)
                obj.endEpochGroup();
                group = obj.getCurrentEpochGroup();
            end
            obj.session.getPersistor().close();
            obj.session.persistor = [];
            notify(obj, 'ClosedFile');
        end

        function tf = hasOpenFile(obj)
            tf = obj.session.hasPersistor();
        end

        function e = getExperiment(obj)
            e = obj.session.getPersistor().experiment;
        end

        function d = getAvailableSourceDescriptions(obj, parentType)
            d = {};
            classNames = obj.classRepository.get('symphonyui.core.persistent.descriptions.SourceDescription');
            for i = 1:numel(classNames)
                constructor = str2func(classNames{i});
                try
                    description = constructor();
                    allowableParentTypes = description.getAllowableParentTypes();
                catch x
                    obj.log.debug(x.message, x);
                    continue;
                end
                if isempty(allowableParentTypes) || any(cellfun(@(t)isequal(t, parentType), allowableParentTypes))
                    d{end + 1} = classNames{i}; %#ok<AGROW>
                end
            end
        end

        function s = addSource(obj, parent, description)
            if isempty(parent)
                parentType = [];
            else
                parentType = parent.getDescriptionType();
            end
            if ~any(strcmp(description, obj.getAvailableSourceDescriptions(parentType)))
                error([description ' is not an available source description for the current parent type']);
            end
            constructor = str2func(description);
            s = obj.session.getPersistor().addSource(parent, constructor());
            notify(obj, 'AddedSource', symphonyui.app.AppEventData(s));
        end

        function d = getAvailableEpochGroupDescriptions(obj, parentType)
            d = {};
            classNames = obj.classRepository.get('symphonyui.core.persistent.descriptions.EpochGroupDescription');
            for i = 1:numel(classNames)
                constructor = str2func(classNames{i});
                try
                    description = constructor();
                    allowableParentTypes = description.getAllowableParentTypes();
                catch x
                    obj.log.debug(x.message, x);
                    continue;
                end
                if isempty(allowableParentTypes) || any(cellfun(@(t)isequal(t, parentType), allowableParentTypes))
                    d{end + 1} = classNames{i}; %#ok<AGROW>
                end
            end
        end

        function g = beginEpochGroup(obj, source, description)
            parent = obj.getCurrentEpochGroup();
            if isempty(parent)
                parentType = [];
            else
                parentType = parent.getDescriptionType();
            end
            if ~any(strcmp(description, obj.getAvailableEpochGroupDescriptions(parentType)))
                error([description ' is not an available epoch group description for the current parent type']);
            end
            constructor = str2func(description);
            g = obj.session.getPersistor().beginEpochGroup(source, constructor());
            notify(obj, 'BeganEpochGroup', symphonyui.app.AppEventData(g));
        end

        function g = endEpochGroup(obj)
            g = obj.session.getPersistor().endEpochGroup();
            notify(obj, 'EndedEpochGroup', symphonyui.app.AppEventData(g));
        end

        function g = getCurrentEpochGroup(obj)
            g = obj.session.getPersistor().currentEpochGroup;
        end

        function b = getCurrentEpochBlock(obj)
            b = obj.session.getPersistor().currentEpochBlock;
        end

        function deleteEntity(obj, entity)
            uuid = entity.uuid;
            obj.session.getPersistor().deleteEntity(entity);
            notify(obj, 'DeletedEntity', symphonyui.app.AppEventData(uuid));
        end

        function sendEntityToWorkspace(obj, entity) %#ok<INUSL>
            name = matlab.lang.makeValidName(entity.uuid);
            assignin('base', name, entity);
            evalin('base', ['disp(''' name ' = ' class(entity) ''')']);
        end

    end

end
