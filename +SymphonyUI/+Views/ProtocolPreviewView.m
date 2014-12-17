classdef ProtocolPreviewView < SymphonyUI.View
    
    properties
    end
    
    methods
        
        function obj = ProtocolPreviewView()
            obj = obj@SymphonyUI.View(SymphonyUI.Presenters.ProtocolPreviewPresenter());
        end
        
        function createInterface(obj)
            clf(obj.figureHandle);
            
            p = obj.presenter;
            
            set(obj.figureHandle, 'Name', 'Protocol Preview');
        end
        
    end
    
end

