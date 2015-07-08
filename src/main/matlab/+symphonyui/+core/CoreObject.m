classdef (Abstract) CoreObject < handle
    
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
        
    end
    
    methods (Access = protected)
        
        function obj = CoreObject(cobj)
            obj.cobj = cobj;
        end
        
        function c = cellArrayFromEnumerable(~, enum, wrap)
            if nargin < 3
                wrap = @(e)e;
            end
            
            c = {};
            enum = Symphony.Core.EnumerableExtensions.Wrap(enum);
            e = enum.GetEnumerator();
            i = 1;
            while e.MoveNext()
                c{i} = wrap(e.Current());
                i = i + 1;
            end
        end
        
        function m = mapFromKeyValueEnumerable(~, enum, wrap)
            if nargin < 3
                wrap = @(e)convert(e);
            end
            
            m = containers.Map();
            enum = Symphony.Core.EnumerableExtensions.Wrap(enum);
            e = enum.GetEnumerator();
            while e.MoveNext()
                kv = e.Current();
                m(char(kv.Key)) = wrap(kv.Value);
            end
        end
        
        function t = datetimeFromDateTimeOffset(~, dto)
            second = double(dto.Second) + (double(dto.Millisecond) / 1000);
            t = datetime(dto.Year, dto.Month, dto.Day, dto.Hour, dto.Minute, second);
            tz = char(dto.Offset.ToString());
            if tz(1) ~= '-'
                tz = ['+' tz];
            end
            t.TimeZone = tz;
        end
        
        function dto = dateTimeOffsetFromDatetime(~, t)
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