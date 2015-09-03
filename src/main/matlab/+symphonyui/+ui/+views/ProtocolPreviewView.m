classdef ProtocolPreviewView < symphonyui.ui.View
    
    properties (Access = private)
        previewPanel
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, ...
                'Position', screenCenter(600, 400), ...
                'Toolbar', 'figure');
           
            obj.previewPanel = uipanel( ...
                'Parent', obj.figureHandle, ...
                'BorderType', 'none');
        end
        
        function setTitle(obj, t)
            set(obj.figureHandle, 'Name', t);
        end
        
        function p = getPreviewPanel(obj)
            p = obj.previewPanel;
        end

    end

end
