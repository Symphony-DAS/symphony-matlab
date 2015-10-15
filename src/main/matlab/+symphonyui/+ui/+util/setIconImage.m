function setIconImage(hUipushtool,imageFileName)
%SETICONIMAGE  sets the icon of a toolbar pushbutton to the image specified. 
%
% SETICONIMAGE(HUIPUSHTOOL,IMAGEFILENAME) sets the icon of the HUIPUSHTOOL to the
% image secifiled by IMAGEFILENAME. HUIPUSHTOOL is a handle to an uipushtool on
% the toolbar. IMAGEFILENAME is the full name of the image file that will placed
% on the button.
%
% Example:
%   hfig = figure('Toolbar','none','DockControls','off');
%   tlb = uitoolbar(hfig);
%   btnNew = uipushtool(tlb,'TooltipString','New');
%   setIconImage(btnNew,'images\new.png');
%   btnOpen = uipushtool(tlb,'TooltipString','Open');
%   setIconImage(btnOpen,'images\open.png');
%   btnSave = uipushtool(tlb,'TooltipString','Save');
%   setIconImage(btnSave,'images\save.png');
%   btnHelp = uipushtool(tlb,'TooltipString','Help','Separator','on');
%   setIconImage(btnHelp,'images\help.png');
%   btnExit = uipushtool(tlb,'TooltipString','Exit','Separator','on',...
%               'ClickedCallback','close(hfig)');
%   setIconImage(btnExit,'images\exit.png');

% Note:
% Your can also set the icon of an uipushtool by setting it CData. However, 
% setIconImage can preserve the transpanrency of the image after it is added on
% to the uipushtool.

%   Copyright Qun HAN (junziyang@126.com)
%   College of Precision Instrument and Opto-Electronics Engineering,
%   Tianjin University, 300072, P.R. CHINA.
%   2006/12/01

error(nargchk(2, 2, nargin));
if ~ishandle(hUipushtool) || ~isequal(get(hUipushtool,'Type'),'uipushtool')
    error('First input argument must be a handle of an uipushtool.');
end
if ~ischar(imageFileName) ||~(isequal(imageFileName(end-3),'.') || ...
        isequal(imageFileName(end-4),'.'))
    error('Please specify a full imageFileName, NAME & EXTENTION.');
end
hUitoolbar = get(hUipushtool,'Parent');
tlbChildren = get(hUitoolbar,'Children');
numChild = length(tlbChildren);
index = find(tlbChildren==hUipushtool);
numSeparator = length(findobj(tlbChildren(index:end),'Separator','on'));
drawnow;
jUitoolbar = get(hUitoolbar,'JavaContainer');
jUipushtools = jUitoolbar.getComponentPeer.getComponents;
numJtools = numel(jUipushtools) - numChild - numSeparator;
ico = javax.swing.ImageIcon(imageFileName);
jUipushtools(numJtools+numChild-index+numSeparator+1).setIcon(ico);


