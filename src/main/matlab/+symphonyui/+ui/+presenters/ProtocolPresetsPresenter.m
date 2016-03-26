classdef ProtocolPresetsPresenter < appbox.Presenter
    
    properties (Access = private)
        log
        settings
        documentationService
        acquisitionService
    end
    
    methods
        
        function obj = ProtocolPresetsPresenter(documentationService, acquisitionService, view)
            if nargin < 3
                view = symphonyui.ui.views.ProtocolPresetsView();
            end
            obj = obj@appbox.Presenter(view);
            
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.settings = symphonyui.ui.settings.ProtocolPresetsSettings();
            obj.documentationService = documentationService;
            obj.acquisitionService = acquisitionService;
        end
        
    end
    
    methods (Access = protected)
        
        function willGo(obj)
            obj.populatePresetList();
            try
                obj.loadSettings();
            catch x
                obj.log.debug(['Failed to load presenter settings: ' x.message], x);
            end
            obj.updateStateOfControls();
        end
        
        function willStop(obj)
            try
                obj.saveSettings();
            catch x
                obj.log.debug(['Failed to save presenter settings: ' x.message], x);
            end
        end
        
        function bind(obj)
            bind@appbox.Presenter(obj);
            
            v = obj.view;
            obj.addListener(v, 'SelectedProtocolPreset', @obj.onViewSelectedProtocolPreset);
            obj.addListener(v, 'AddProtocolPreset', @obj.onViewSelectedAddProtocolPreset);
            obj.addListener(v, 'RemoveProtocolPreset', @obj.onViewSelectedRemoveProtocolPreset);
            
            d = obj.documentationService;
            obj.addListener(d, 'BeganEpochGroup', @obj.onServiceBeganEpochGroup);
            obj.addListener(d, 'EndedEpochGroup', @obj.onServiceEndedEpochGroup);
            
            a = obj.acquisitionService;
            obj.addListener(a, 'ChangedControllerState', @obj.onServiceChangedControllerState);
            obj.addListener(a, 'AddedProtocolPreset', @obj.onServiceAddedProtocolPreset);
            obj.addListener(a, 'RemovedProtocolPreset', @obj.onServiceRemovedProtocolPreset);
        end
        
    end
    
    methods (Access = private)
        
        function populatePresetList(obj)
            names = obj.acquisitionService.getAvailableProtocolPresets();
            
            data = cell(numel(names), 2);
            for i = 1:numel(names)
                preset = obj.acquisitionService.getProtocolPreset(names{i});
                data{i, 1} = preset.name;
                data{i, 2} = preset.protocolId;
            end
            
            obj.view.setProtocolPresets(data);
        end
        
        function onViewSelectedProtocolPreset(obj, ~, ~)
            obj.updateStateOfControls();
        end
        
        function onViewSelectedAddProtocolPreset(obj, ~, ~)
            presenter = symphonyui.ui.presenters.AddProtocolPresetPresenter(obj.acquisitionService);
            presenter.goWaitStop();
        end
        
        function onServiceAddedProtocolPreset(obj, ~, event)
            preset = event.data;
            obj.view.addProtocolPreset(preset.name, preset.protocolId);
        end
        
        function onViewSelectedRemoveProtocolPreset(obj, ~, ~)
            name = obj.view.getSelectedProtocolPreset();
            if isempty(name)
                return;
            end
            try
                obj.acquisitionService.removeProtocolPreset(name);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onServiceRemovedProtocolPreset(obj, ~, event)
            preset = event.data;
            obj.view.removeProtocolPreset(preset.name);
        end
        
        function onServiceBeganEpochGroup(obj, ~, ~)
            obj.updateStateOfControls();
        end
        
        function onServiceEndedEpochGroup(obj, ~, ~)
            obj.updateStateOfControls();
        end
        
        function onServiceChangedControllerState(obj, ~, ~)
            obj.updateStateOfControls();
        end
        
        function updateStateOfControls(obj)
            import symphonyui.core.ControllerState;
            
            hasSelectedProtocolPreset = ~isempty(obj.view.getSelectedProtocolPreset());
            hasOpenFile = obj.documentationService.hasOpenFile();
            hasEpochGroup = hasOpenFile && ~isempty(obj.documentationService.getCurrentEpochGroup());
            controllerState = obj.acquisitionService.getControllerState();
            isStopped = controllerState.isStopped();
            
            enableViewOnlyProtocolPreset = hasSelectedProtocolPreset && isStopped;
            enableRecordProtocolPreset = hasSelectedProtocolPreset && hasEpochGroup && isStopped;
            enableApplyProtocolPreset = hasSelectedProtocolPreset && isStopped;
            
            obj.view.enableViewOnlyProtocolPreset(enableViewOnlyProtocolPreset);
            obj.view.enableRecordProtocolPreset(enableRecordProtocolPreset);
            obj.view.enableApplyProtocolPreset(enableApplyProtocolPreset);
        end
        
        function loadSettings(obj)
            if ~isempty(obj.settings.viewPosition)
                obj.view.position = obj.settings.viewPosition;
            end
        end

        function saveSettings(obj)
            obj.settings.viewPosition = obj.view.position;
            %obj.settings.save();
        end
        
    end
    
end

