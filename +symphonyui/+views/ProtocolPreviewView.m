classdef ProtocolPreviewView < symphonyui.View
    
    properties
    end
    
    methods
        
        function obj = ProtocolPreviewView(parent)
            obj = obj@symphonyui.View(parent);
        end
        
        function createUI(obj)
            set(obj.figureHandle, 'Name', 'Protocol Preview');
        end
        
    end
    
end

