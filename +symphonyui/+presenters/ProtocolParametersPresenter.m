classdef ProtocolParametersPresenter < symphonyui.Presenter
    
    properties (Access = private)
        previewPresenter
    end
    
    methods
        
        function obj = ProtocolParametersPresenter(view)
            if nargin < 1
                view = symphonyui.views.ProtocolParametersView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.addListener(view, 'SelectedPreset', @obj.onSelectedPreset);
            obj.addListener(view, 'Apply', @obj.onSelectedApply);
            obj.addListener(view, 'Revert', @obj.onSelectedRevert);
            
            view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
        end
        
        function setProtocol(obj, protocol)
            obj.view.clearParameters();
            obj.view.addParameter('Display name', protocol.displayName);
        end
        
    end
    
    methods (Access = private)
        
        function onWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onSelectedApply();
            end
        end
        
        function onSelectedPreset(obj, ~, ~)
            p = obj.view.getPreset();
            disp(p);
        end
        
        function onSelectedApply(obj, ~, ~)
            disp('Apply');
        end
        
        function onSelectedRevert(obj, ~, ~)
            disp('Revert');
        end
        
    end
    
end

