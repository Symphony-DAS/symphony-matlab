classdef ProtocolParametersPresenter < SymphonyUI.Presenter
    
    properties
        previewPresenter
    end
    
    methods
        
        function setProtocol(obj, protocol)
            disp('Set protocol');
        end
        
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

