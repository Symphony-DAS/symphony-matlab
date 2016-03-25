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
            obj.addListener(v, 'SelectedPreset', @obj.onViewSelectedPreset);
            obj.addListener(v, 'AddPreset', @obj.onViewSelectedAddPreset);
            obj.addListener(v, 'RemovePreset', @obj.onViewSelectedRemovePreset);
            
            d = obj.documentationService;
            obj.addListener(d, 'BeganEpochGroup', @obj.onServiceBeganEpochGroup);
            obj.addListener(d, 'EndedEpochGroup', @obj.onServiceEndedEpochGroup);
            
            a = obj.acquisitionService;
            obj.addListener(a, 'ChangedControllerState', @obj.onServiceChangedControllerState);
        end
        
    end
    
    methods (Access = private)
        
        function populatePresetList(obj)
            
        end
        
        function onViewSelectedPreset(obj, ~, ~)
            obj.updateStateOfControls();
        end
        
        function onViewSelectedAddPreset(obj, ~, ~)
            obj.view.addPreset(['<html>' num2str(rand()) '<br><font color="gray">io.github.symphony_das.protocols.Pulse</font></html>']);
        end
        
        function onViewSelectedRemovePreset(obj, ~, ~)
            preset = obj.view.getSelectedPreset();
            if isempty(preset)
                return;
            end
            obj.view.removePreset(preset);
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
            
            hasSelectedPreset = ~isempty(obj.view.getSelectedPreset());
            hasOpenFile = obj.documentationService.hasOpenFile();
            hasEpochGroup = hasOpenFile && ~isempty(obj.documentationService.getCurrentEpochGroup());
            controllerState = obj.acquisitionService.getControllerState();
            isStopped = controllerState.isStopped();
            
            enableViewOnlyPreset = hasSelectedPreset && isStopped;
            enableRecordPreset = hasSelectedPreset && hasEpochGroup && isStopped;
            enableApplyPreset = hasSelectedPreset && isStopped;
            
            obj.view.enableViewOnlyPreset(enableViewOnlyPreset);
            obj.view.enableRecordPreset(enableRecordPreset);
            obj.view.enableApplyPreset(enableApplyPreset);
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

