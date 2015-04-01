% Demonstrates how to use the property editor.
%
% See also: PropertyEditor

% Copyright 2010 Levente Hunyadi
function example_propertyeditor

% create figure
f = figure( ...
    'MenuBar', 'none', ...
    'Name', 'Property editor demo - Copyright 2010 Levente Hunyadi', ...
    'NumberTitle', 'off', ...
    'Toolbar', 'none');
items = { SampleObject SampleObject };
editor = uiextras.jide.PropertyEditor(f, 'Items', items);
editor.AddItem(uiextras.jide.SampleNestedObject, 1);
editor.RemoveItem(1);
