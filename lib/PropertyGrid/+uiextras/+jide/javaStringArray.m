% Converts a MatLab cell array of strings into a java.lang.String array.
%
% Input arguments:
% str:
%    a cell array of strings (i.e. a cell array of char row vectors)
%
% Output arguments:
% arr:
%    a java.lang.String array instance (i.e. java.lang.String[])
%
% See also: javaArray

% Copyright 2009-2010 Levente Hunyadi
function arr = javaStringArray(str)

assert(iscellstr(str) && (isempty(str) || isvector(str)), ...
    'java:StringArray:InvalidArgumentType', ...
    'Cell row or column vector of strings expected.');
if isempty(str)
    arr = toArray(java.util.Vector);
    return;
end
arr = javaArray('java.lang.String', length(str));
for k = 1 : numel(str);
    arr(k) = java.lang.String(str{k});
end
