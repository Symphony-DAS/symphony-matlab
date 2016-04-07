classdef AppEventData < event.EventData

    properties (SetAccess = private)
        data
    end

    methods

        function obj = AppEventData(data)
            obj.data = data;
        end

    end

end
