function resps = getSubjectInfo(varargin)

% Calling
% c=struct('radio',struct('eeg',struct('label','EEG Experiment?')), ...
%     'textinput',struct('subNum',struct('label','Subject Number')),...
%     'dropdown',struct('session',struct('label','Session','val',[1 2])));
% 
% getSubjectInfo('components',c);

% parse input arguments
ip = inputParser;
ip.KeepUnmatched = true;
ip.addParamValue('components', {struct('name','sub_num','type','textinput','label','Subject Number')}, @iscell);
ip.addParamValue('win_name', 'Input Subject Info', @isstring);
parse(ip,varargin{:}); 
s= ip.Results.components;
t = ip.Results.win_name;

%some gui object constants to use
margin = 10;
padding = 5;
BTN_size = 30;
TI_size = 30;
DD_size = 30;
CHK_size = 20;
label_size = 20;
table = {'textinput',{'edit',TI_size}; 'check',{'checkbox',CHK_size};'dropdown',{'popup',DD_size}};
height = BTN_size + (3*margin);
width = 200;

% figure out correct size
for i=1:numel(s)
    if any(strcmp('type',fieldnames(s{i})))
        tmp = table{strcmp(s{i}.type,table(:,1)),2};
        s{i}.type = tmp{1}; %#ok<FXSET>
        height = height + tmp{2} + label_size;
    else
        s{i}.type = 'textinput'; %#ok<FXSET>
        height = height + label_size + TI_size + label_size;
    end
end

% create figure 
dims =  get(0, 'ScreenSize');
fig = dialog('Name',t,'Position',[(dims(3)/2) + width/2, (dims(4)/2) + height/2, width, height], 'ToolBar','None','MenuBar','none', ...
    'NumberTitle','off','Visible','off');

% add elements to fig
offset= 0;
value_objs=[];
string_objs=[];
drop_objs=[];
title_obs=[];
for i=1:numel(s)
    
    if any(strcmp('label',fieldnames(s{i})))
        lab = s{i}.label;
    else
        lab = ['Field' num2str(i)];
    end
% if its a drop down or text input field, give it a title and check its values setting 
    if any(strcmp(s{i}.type, {'edit','popup'}))
        title_obs(i) = uicontrol(fig,'Style','text','String',lab, 'Horiz','left','Tag',[ s{i}.name '_lab'],  ... 
                        'Position',[margin, height - offset - margin - label_size, width-2*margin, label_size]); %#ok<*AGROW>
        if any(strcmp('values',fieldnames(s{i})))
            vals = s{i}.values;
        else
            vals= [];
        end 
        props= struct('Horiz','left','Backgr','w', 'FontSize', 11, 'Tag',s{i}.name, ...
            'Position',[margin, height - offset - padding - label_size - TI_size, width-2*margin, TI_size]);
    end
    
    if strcmp(s{i}.type, 'edit')
        string_objs(i) = uicontrol(fig,props,'Style','edit', 'String', vals);
        offset = offset +  TI_size + label_size;
    elseif strcmp(s{i}.type, 'popup')
        drop_objs(i) = uicontrol(fig,props,'Style','popup', 'String', vals);
        offset = offset +  DD_size + label_size;
    else
        if any(strcmp('value',fieldnames(s{i})))
            vals = s{i}.value;
        else
            vals= 0;
        end
        value_objs(end+1) = uicontrol(fig,'Style','checkbox','String',s{i}.label,'Val',s{i}.values,'Tag',s{i}.name, ...
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
<<<<<<< HEAD
=======

function controls = extract(unmatched)
    
end
>>>>>>> 5eebbbb... restructued input argument style go getSubjectInfo (again....)
