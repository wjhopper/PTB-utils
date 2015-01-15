function getSubjectInfo(varargin)

% Calling
% c=struct('radio',struct('eeg',struct('label','EEG Experiment?')), ...
%     'textinput',struct('subNum',struct('label','Subject Number')),...
%     'dropdown',struct('session',struct('label','Session','val',[1 2])));
% 
% getSubjectInfo('components',c);

% parse input arguments
ip = inputParser;
ip.addParamValue('components', [], @(x) ismatrix(x));
ip.addParamValue('name', 'Input Subject Info', @(x) isstring(x));
parse(ip,varargin{:}); 
s = ip.Results;
margin = 10;
padding = 5;
btn_size = 30;

% figure out correct size
TI_fnames = fieldnames(s.components.('textinput'));
    % DD_fnames = fieldnames(s.components.('dropdown'));
TI_size_sum =[10,225];
R_fnames = fieldnames(s.components.('radio'));
R_size_sum =[10,225];
for j = 1:(numel(TI_fnames))% + numel(DD_fnames))
    if strcmpi('height',fieldnames(s.components.('textinput').(TI_fnames{j})));
        TI_size_sum(1) = TI_size_sum(1) +s.components.('textinput').(TI_fnames{j}).('height') + 20; %20px for title
    else
        s.components.('textinput').(TI_fnames{j}).height = 30;
        TI_size_sum(1) = TI_size_sum(1) +50;
    end
end
R_size_sum(1) = R_size_sum(1) + 20* numel(R_fnames);
height = TI_size_sum(1) + R_size_sum(1) + btn_size + padding; 
width = max([TI_size_sum(2), R_size_sum(2)]);

% create figure 
if strcmp('win_name',fieldnames(s.components))
    t = s.components.('win_name');
else
    t = 'Get Subject Info';
end
dims =  get(0, 'ScreenSize');
fig = dialog('Name',t,'Position',[(dims(3)/2) + width/2, (dims(4)/2) + height/2, width, height], 'ToolBar','None','MenuBar','none', ...
    'NumberTitle','off','Visible','off');
offset= 0;
% add elements to fig
for i=1:numel(TI_fnames)
    uicontrol(fig,'Style','text','String',s.components.textinput.(TI_fnames{i}).label, ... 
        'Position',[margin, height - offset - margin - 20, width-2*margin, 20], ...
        'Horiz','left')
    uicontrol(fig,'Style','edit','Horiz','left','Backgr','w', 'FontSize', 11, ...
        'Position',[margin, height - offset - padding - 20 - s.components.textinput.(TI_fnames{i}).height, ...
                    width-2*margin, s.components.textinput.(TI_fnames{i}).height])
    offset = offset +  s.components.textinput.(TI_fnames{j}).height + 20;
end    
for i=1:numel(R_fnames)
    uicontrol(fig,'Style','checkbox','String',s.components.radio.(R_fnames{i}).label, ... 
        'Position',[margin, height - offset - margin - 20, width-2*margin, 20], ...
        'Val',0)
    offset = offset + 20;
end    

uicontrol(fig, 'Style','pushbutton','String','Run', ...
          'Pos', [margin height-(height-10) ((width-2*margin)/2)-padding, btn_size]) 
set(fig,'Visible','on');
a=2; % debug point =)