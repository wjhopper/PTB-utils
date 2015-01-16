function getSubjectInfo(varargin)

% Calling
% c=struct('radio',struct('eeg',struct('label','EEG Experiment?')), ...
%     'textinput',struct('subNum',struct('label','Subject Number')),...
%     'dropdown',struct('session',struct('label','Session','val',[1 2])));
% 
% getSubjectInfo('components',c);

% parse input arguments
ip = inputParser;
ip.addParamValue('components', struct('name','sub_num','type','textinput','label','Subject Number','value',''), @(x) isstruct(x));
ip.addParamValue('win_name', 'Input Subject Info', @(x) isstring(x));

parse(ip,varargin{:}); 
s = ip.Results.components;
margin = 10;
padding = 5;
BTN_size = 30;
TI_size = 30;
DD_size = 30;
CHK_size = 20;
label_size = 20;

table = {'textinput','edit'; 'check','checkbox';'dropdown','popup'};
% figure out correct size
height = ((TI_size+label_size)*sum(strcmpi('textinput',{s.type}))) + (CHK_size*sum(strcmpi('check',{s.type}))) + ...
            ((DD_size+label_size)*sum(strcmpi('dropdown',{s.type}))) + BTN_size + (3*margin);
width = 200;

% create figure 
t = ip.Results.win_name;
dims =  get(0, 'ScreenSize');
fig = dialog('Name',t,'Position',[(dims(3)/2) + width/2, (dims(4)/2) + height/2, width, height], 'ToolBar','None','MenuBar','none', ...
    'NumberTitle','off','Visible','off');

% add elements to fig
offset= 0;
for i=1:numel(s)
    if any(strcmp(s(i).type, {'textinput','dropdown'}))
        uicontrol(fig,'Style','text','String',s(i).label, 'Horiz','left', ... 
            'Position',[margin, height - offset - margin - label_size, width-2*margin, label_size])
        uicontrol(fig,'Style',table{strcmpi(s(i).type,table(:,1)),2}, 'Horiz','left','Backgr','w', ...
            'FontSize', 11,  'String', s(i).values, ...
            'Position',[margin, height - offset - padding - label_size - TI_size, ...
                        width-2*margin, TI_size])
        offset = offset +  50;
    else
       uicontrol(fig,'Style','checkbox','String',s(i).label,'Val',s(i).values, ... 
        'Position',[margin, height - offset - margin - CHK_size, width-2*margin, CHK_size])
        offset = offset + 20;
    end
end    

uicontrol(fig, 'Style','pushbutton','String','Run', ...
          'Pos', [(width/2)+padding height-(height-10) ((width-2*margin)/2)-margin, BTN_size]) 
uicontrol(fig, 'Style','pushbutton','String','Cancel', ...
          'Pos', [margin height-(height-10) ((width-2*margin)/2)-padding, BTN_size])       
set(fig,'Visible','on');
a=2; % debug point =)