classdef Preparation < symphonyui.core.persistent.descriptions.SourceDescription
    
    methods
        
        function obj = Preparation()
            import symphonyui.core.*;
            
            obj.addProperty('protocol', '', ...
                'description', 'The preparation protocol implemented to obtain the specific sample');
            obj.addProperty('date', datestr(now), ...
                'type', PropertyType('char', 'row', 'datestr'), ...
                'description', 'The date the preparation protocol was performed to obtain the specific sample');
            obj.addProperty('region', '');
            obj.addProperty('sliceThickness', 0, ...
                'description', 'The thickness of the slice in microns');
            obj.addProperty('sliceOrientation', '', ...
                'description', 'The slice orientation: horizontal, sagital etc');
            obj.addProperty('bathTemperature', 0, ...
                'description', 'The temperature of the bath solution');
            obj.addProperty('bathSolution', '', ...
                'description', 'The solution the slice is bathed in');
            
            obj.addAllowableParentType('io.github.symphony_das.sources.Subject');
        end
        
    end
    
end

