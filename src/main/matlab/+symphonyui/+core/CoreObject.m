classdef (Abstract) CoreObject < handle
    % A CoreObject is the base class for all Matlab classes that wrap a core .NET class.
    
    properties (SetAccess = private, Hidden)
        cobj
    end
    
    methods
        
        function tf = isequal(obj, other)
            if isempty(obj) || isempty(other) || ~isa(obj, 'symphonyui.core.CoreObject') || ~isa(other, 'symphonyui.core.CoreObject')
                tf = false;
                return;
            end
            tf = obj.cobj.Equals(other.cobj);
        end
        
        function tf = eq(obj, other)
            if isempty(obj) || isempty(other) || ~isa(obj, 'symphonyui.core.CoreObject') || ~isa(other, 'symphonyui.core.CoreObject')
                tf = false;
                return;
            end
            tf = obj.cobj == other.cobj;
        end
        
        function tf = ne(obj, other)
            tf = ~eq(obj, other);
        end
        
    end
    
    methods (Access = protected)
        
        function obj = CoreObject(cobj)
            obj.cobj = cobj;
        end
        
        function tryCore(obj, call) %#ok<INUSL>
            try
                call();
            catch x
                if isa(x, 'NET.NetException')
                    error(symphonyui.core.util.netReport(x));
                else
                    rethrow(x)
                end
            end
        end
        
        function r = tryCoreWithReturn(obj, call) %#ok<INUSL>
            try
                r = call();
            catch x
                if isa(x, 'NET.NetException')
                    error(symphonyui.core.util.netReport(x));
                else
                    rethrow(x)
                end
            end
        end
        
        function c = cellArrayFromEnumerable(obj, enum, wrap) %#ok<INUSL>
            if nargin < 3 || isempty(wrap)
                wrap = @(e)e;
            end
            
            c = {};
            enum = Symphony.Core.EnumerableExtensions.Wrap(enum);
            e = enum.GetEnumerator();
            i = 1;
            while e.MoveNext()
                c{i} = wrap(e.Current()); %#ok<AGROW>
                i = i + 1;
            end
        end
        
        function c = firstFromEnumerable(obj, enum, wrap) %#ok<INUSL>
            if nargin < 3 || isempty(wrap)
                wrap = @(e)e;
            end
            
            enum = Symphony.Core.EnumerableExtensions.Wrap(enum);
            e = enum.GetEnumerator();
            e.MoveNext();
            c = wrap(e.Current());
        end
        
        function c = cellArrayFromEnumerableOrderedBy(obj, enum, prop, wrap)
            if nargin < 4
                wrap = [];
            end
            
            c = obj.cellArrayFromEnumerable(enum, wrap);
            if isempty(c)
                return;
            end
            a = [c{:}];
            [~, i] = sort([a(:).(prop)]);
            c = c(i);
        end
        
        function m = mapFromKeyValueEnumerable(obj, enum, wrap) %#ok<INUSL>
            if nargin < 3
                wrap = @(e)(e);
            end
            
            m = containers.Map();
            enum = Symphony.Core.EnumerableExtensions.Wrap(enum);
            e = enum.GetEnumerator();
            while e.MoveNext()
                kv = e.Current();
                m(char(kv.Key)) = wrap(convert(kv.Value));
            end
        end
        
        function d = dictionaryFromMap(obj, map) %#ok<INUSL>
            d = NET.createGeneric('System.Collections.Generic.Dictionary', {'System.String', 'System.Object'});
            keys = map.keys;
            for i = 1:numel(keys);
                key = keys{i};
                d.Add(key, map(key));
            end
        end
        
        function t = datetimeFromDateTimeOffset(obj, dto) %#ok<INUSL>
            second = double(dto.Second) + (double(dto.Millisecond) / 1000);
            t = datetime(dto.Year, dto.Month, dto.Day, dto.Hour, dto.Minute, second);
            tz = char(dto.Offset.ToString());
            if tz(1) ~= '-'
                tz = ['+' tz];
            end
            t.TimeZone = tz;
        end
        
        function dto = dateTimeOffsetFromDatetime(obj, t) %#ok<INUSL>
            if isempty(t.TimeZone)
                error('Datetime ''TimeZone'' must be set');
            end
            t.Format = 'ZZZZZ';
            tz = char(t);
            if tz(1) == '+'
                tz(1) = [];
            end
            offset = System.TimeSpan.Parse(tz);
            dto = System.DateTimeOffset(t.Year, t.Month, t.Day, t.Hour, t.Minute, floor(t.Second), round(1000*rem(t.Second, 1)), offset);
        end
        
        function d = durationFromTimeSpan(obj, t) %#ok<INUSL>
            d = seconds(t.TotalSeconds);
        end
        
        function t = timeSpanFromDuration(obj, d) %#ok<INUSL>
            t = System.TimeSpan.FromTicks(milliseconds(d) * 10000);
        end
        
        function v = propertyValueFromValue(obj, v) %#ok<INUSL>
            if iscell(v) || isstruct(v) || (isempty(v) && isnumeric(v))
                v = savejson('', v, 'Compact', true);
            end
        end
        
        function v = valueFromPropertyValue(obj, v) %#ok<INUSL>
            if ischar(v) && ~isempty(regexp(v, '^\s*(?:\[.+\])|(?:\{.+\})\s*$', 'once'))
                try %#ok<TRYNC>
                    v = loadjson(v);
                end
            end
        end
        
    end
    
end

function v = convert(dotNetValue)
    v = dotNetValue;
    if ~isa(v, 'System.Object')
        return;
    end
    
    clazz = strtok(class(dotNetValue), '[');
    switch clazz
        case 'System.Int16'
            v = int16(v);
        case 'System.UInt16'
            v = uint16(v);
        case 'System.Int32'
            v = int32(v);
        case 'System.UInt32'
            v = uint32(v);
        case 'System.Int64'
            v = int64(v);
        case 'System.UInt64'
            v = uint64(v);
        case 'System.Single'
            v = single(v);
        case 'System.Double'
            v = double(v);
        case 'System.Boolean'
            v = logical(v);
        case 'System.Byte'
            v = uint8(v);
        case {'System.Char', 'System.String'}
            v = char(v);
    end
end