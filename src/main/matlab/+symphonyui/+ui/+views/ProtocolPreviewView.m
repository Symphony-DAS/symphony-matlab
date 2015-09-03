classdef ProtocolPreviewView < symphonyui.ui.View
    
    properties (Access = private)
        previewPanel
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, ...
                'Name', 'Protocol Preview', ...
                'Position', screenCenter(600, 400));
            
            obj.previewPanel = uipanel( ...
                'Parent', obj.figureHandle, ...
                'BorderType', 'none');
        end

    end

end
