classdef ProtocolPreviewView < SymphonyUI.View
    
    properties
    end
    
    methods
        
        function obj = ProtocolPreviewView(parent)
            obj = obj@SymphonyUI.View(parent);
        end
        
        function createUI(obj)
            set(obj.figureHandle, 'Name', 'Protocol Preview');
        end
        
    end
    
end

