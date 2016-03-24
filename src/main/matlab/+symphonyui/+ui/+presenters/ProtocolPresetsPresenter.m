classdef ProtocolPresetsPresenter < appbox.Presenter
    
    properties (Access = private)
        acquisitionService
    end
    
    methods
        
        function obj = ProtocolPresetsPresenter(acquisitionService, view)
            if nargin < 2
                view = symphonyui.ui.views.ProtocolPresetsView();
            end
            obj = obj@appbox.Presenter(view);

            obj.acquisitionService = acquisitionService;
        end
        
    end
    
    methods (Access = protected)
        
        function bind(obj)
            bind@appbox.Presenter(obj);
            
            v = obj.view;
            obj.addListener(v, 'AddPreset', @obj.onViewSelectedAddPreset);
            obj.addListener(v, 'RemovePreset', @obj.onViewSelectedRemovePreset);
        end
        
    end
    
    methods (Access = private)
        
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
        
    end
    
end

