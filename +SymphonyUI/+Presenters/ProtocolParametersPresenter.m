classdef ProtocolParametersPresenter < SymphonyUI.Presenter
    
    properties (Access = private)
        protocol
        previewPresenter
    end
    
    methods
        
        function obj = ProtocolParametersPresenter(view)
            if nargin < 1
                view = SymphonyUI.Views.ProtocolParametersView([]);
            end
            
            obj = obj@SymphonyUI.Presenter(view);
        end
        
        function setProtocol(obj, protocol)
            disp('Set protocol');
        end
        
    end
    
    methods (Access = private)
        
        function onSelectedPreview(obj, ~, ~)
            if isempty(obj.previewPresenter) || ~isvalid(obj.previewPresenter)
                v = SymphonyUI.Views.ProtocolPreviewView();
                obj.previewPresenter = v.presenter;
            end
            
            obj.previewPresenter.view.show();
        end
        
        function onSelectedApply(obj, ~, ~)
            disp('Apply');
        end
        
        function onSelectedClose(obj, ~, ~)
            if ~isempty(obj.previewPresenter) && isvalid(obj.previewPresenter)
                obj.previewPresenter.onSelectedClose();
            end
            
            onSelectedClose@SymphonyUI.Presenter(obj);
        end
        
    end
    
end

