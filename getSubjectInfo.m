function resps = getSubjectInfo(varargin)

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
        uicontrol(fig,'Style','text','String',s(i).label, 'Horiz','left','Tag',s(i).name,  ... 
            'Position',[margin, height - offset - margin - label_size, width-2*margin, label_size]); %#ok<*AGROW>
        a = uicontrol(fig,'Style',table{strcmpi(s(i).type,table(:,1)),2}, 'Horiz','left','Backgr','w', ...
            'FontSize', 11,  'String', s(i).values, 'Tag',s(i).name, ...
            'Position',[margin, height - offset - padding - label_size - TI_size, ...
                        width-2*margin, TI_size]);
        if strcmp(s(i).type, 'textinput')
            string_objs(i)=a;
        else
            drop_objs(i)=a;
        end
        offset = offset +  50;
    else
       value_objs(i) = uicontrol(fig,'Style','checkbox','String',s(i).label,'Val',s(i).values,'Tag',s(i).name, ... 
        'Position',[margin, height - offset - margin - CHK_size, width-2*margin, CHK_size]);
        offset = offset + 20;
    end
end    
% blank out missings
value_objs(value_objs==0)=[];
string_objs(string_objs==0)=[];
drop_objs(drop_objs==0)=[];

% add buttons
uicontrol(fig, 'Style','pushbutton','String','Run','Tag','RunBtn','Callback' ,@done ,...
          'Pos', [(width/2)+padding height-(height-10) ((width-2*margin)/2)-margin, BTN_size]) 
uicontrol(fig, 'Style','pushbutton','String','Cancel','Tag','CancelBtn','Callback' ,@done , ...
          'Pos', [margin height-(height-10) ((width-2*margin)/2)-padding, BTN_size])       

% Wait for input
set(fig,'Visible','on');
uiwait(fig);

% Parse input
if ishghandle(fig)
    if strcmp(get(fig,'UserData'),'OK'),
        if ~exist('resps','var')
            resps=struct();
        end
        for j=1:numel(string_objs)
            resps.(get(string_objs(j),'Tag')) = get(string_objs(j),'String');
        end
        for j=1:numel(drop_objs)
            resps.(get(drop_objs(j),'Tag')) =  getCurrentPopupString(drop_objs(j));
        end
        for j=1:numel(value_objs)
            resps.(get(value_objs(j),'Tag')) = get(value_objs(j),'Value');
        end
        delete(fig);
    end
else
  resps=[];  %#ok<NASGU>
end

a=2; % debug point =).
end

function doneKeyPress(obj, evd) %#ok
    switch(evd.Key)
      case {'return'}
        if ~strcmp(get(obj,'UserData'),'Cancel')
          set(gcbf,'UserData','OK');
          uiresume(gcbf);
        else
          delete(gcbf)
        end
      case 'escape'
        delete(gcbf)
    end
end

function done(obj, evd) %#ok
    if ~strcmp(get(obj,'UserData'),'Cancel')
      set(gcbf,'UserData','OK');
      uiresume(gcbf);
    else
      delete(gcbf)
    end
end

function str = getCurrentPopupString(hh)
%# getCurrentPopupString returns the currently selected string in the popupmenu with handle hh

%# could test input here
if ~ishandle(hh) || strcmp(get(hh,'Type'),'popupmenu')
error('getCurrentPopupString needs a handle to a popupmenu as input')
end

%# get the string - do it the readable way
list = get(hh,'String');
val = get(hh,'Value');
if iscell(list)
   str = list{val};
else
   str = list(val,:);
end

end
