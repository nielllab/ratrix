function varargout = datacollection(varargin)
% DATACOLLECTION M-file for datacollection.fig
%      DATACOLLECTION, by itself, creates a new DATACOLLECTION or raises the existing
%      singleton*.
%
%      H = DATACOLLECTION returns the handle to a new DATACOLLECTION or the handle to
%      the existing singleton*.
%
%      DATACOLLECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATACOLLECTION.M with the given input arguments.
%
%      DATACOLLECTION('Property','Value',...) creates a new DATACOLLECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before datacollection_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to datacollection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help datacollection

% Last Modified by GUIDE v2.5 21-Jul-2007 18:43:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @datacollection_OpeningFcn, ...
                   'gui_OutputFcn',  @datacollection_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
dcuiparams;

function dv=javaDateToNum(df)
dv(1) = df.getYear()+1900;
dv(2) = df.getMonth()+1;
dv(3) = df.getDate();
dv(4) = df.getHours();
dv(5) = df.getMinutes();
dv(6) = df.getSeconds();

function dstr=javaDateToStr(df)
dstr = sprintf('%d/%d/%d',df.getMonth()+1,df.getDate(),df.getYear()+1900);

% --- Executes just before datacollection is made visible.
function datacollection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to datacollection (see VARARGIN)

% Choose default command line output for datacollection
handles.output = hObject;

fprintf('In opening\n');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes datacollection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = datacollection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function SDateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SDateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SDateEdit as text
%        str2double(get(hObject,'String')) returns contents of SDateEdit as a double
str = get(hObject,'String');
try
    df = java.util.Date(str);
    % Convert to standard date format
    dv=javaDateToNum(df);
    handles.startDate = datenum(dv); 
    %sprintf('%d/%d/%d',df.getMonth()+1,df.getDate(),df.getYear()+1900);
    fprintf('Setting startdate to %s\n',datestr(handles.startDate));
catch
    fprintf('Error in SDateEdit_Callback\n');
    handles.startDate = '';
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SDateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SDateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.startDate=now-1;
set(hObject,'String',datestr(handles.startDate,'mm/dd/yyyy'));
guidata(hObject, handles);


function EDateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to EDateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EDateEdit as text
%        str2double(get(hObject,'String')) returns contents of EDateEdit as a double
str = get(hObject,'String');
try
    df = java.util.Date(str);
    % Convert to standard date format
    dv=javaDateToNum(df);
    handles.endDate = datenum(dv);
    %sprintf('%d/%d/%d',df.getMonth()+1,df.getDate(),df.getYear()+1900);
    fprintf('Setting enddate to %s\n',datestr(handles.endDate));
catch
    fprintf('Error in EDateEdit_Callback\n');
    handles.endDate = '';
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EDateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.endDate = now;
set(hObject,'String',datestr(handles.endDate,'mm/dd/yyyy'));
guidata(hObject, handles);

% --- Executes on button press in GetAllData.
function GetAllData_Callback(hObject, eventdata, handles)
% hObject    handle to GetAllData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dcuiparams



if ~strcmp(handles.startDate,'') && ~strcmp(handles.endDate,'')
    fprintf('Getting data from %s to %s\n',datestr(handles.startDate),datestr(handles.endDate));
%     getRatrixDataFromStation(uiparams.remotePath,uiparams.subjects,uiparams.loadMethod, ...
%     [handles.startDate,handles.endDate],uiparams.stations,uiparams.stationIP, ...
%     uiparams.saveOn);

loadMethod=uiparams.loadMethod;
loadMethodParams=[handles.startDate,handles.endDate];

%rat pairings should be loaded in from dcuiparams, but i can't type! (& it dans code does not work) pmm 070721

%overnight
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_113'},loadMethod,loadMethodParams,3,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_102'},loadMethod,loadMethodParams,1,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_106'},loadMethod,loadMethodParams,2,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_114'},loadMethod,loadMethodParams,11,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_116'},loadMethod,loadMethodParams,9,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_117'},loadMethod,loadMethodParams,4,[],1)

%morn
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_126'},loadMethod,loadMethodParams,3 ,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_127'},loadMethod,loadMethodParams,1 ,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_128'},loadMethod,loadMethodParams,2 ,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_129'},loadMethod,loadMethodParams,11,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_130'},loadMethod,loadMethodParams,9 ,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_131'},loadMethod,loadMethodParams,4,[],1)

%aft
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_112'},loadMethod,loadMethodParams,3,[],1)
%[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_***'},loadMethod,loadMethodParams,1,[],1)
%[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_***'},loadMethod,loadMethodParams,2,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_115'},loadMethod,loadMethodParams,11,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_118'},loadMethod,loadMethodParams,9,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_119'},loadMethod,loadMethodParams,4,[],1)


else
    fprintf('Invalid Range %s to %s\n',datestr(handles.startDate),datestr(handles.endDate));
end

guidata(hObject, handles);

% --- Executes on button press in GetData.
function GetData_Callback(hObject, eventdata, handles)
% hObject    handle to GetData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dcuiparams
if ~strcmp(handles.startDate,'') && ~strcmp(handles.endDate,'') && ~strcmp(handles.targetRat,'')
    fprintf('Getting data from %s to %s\n',datestr(handles.startDate),datestr(handles.endDate));
    
    handles.stationId = [];
    for i=1:size(uiparams.heats,2)
        index=find(strcmp(uiparams.heats{i}.subjects,handles.targetRat));
        if ~isempty(index)
            handles.stationId = uiparams.stationIds(index);
            break
        end
    end
    if isempty(handles.stationId)
        error('Cannot find subject');
    end
    %fprintf('%s %d %d\n',handles.targetRat,handles.stationId,index);
    getRatrixDataFromStation(uiparams.remotePath,handles.targetRat,uiparams.loadMethod, ...
    [handles.startDate,handles.endDate],handles.stationId,uiparams.stationIP, ...
    uiparams.saveSmallData,uiparams.saveLargeData);
else
    fprintf('Invalid Range %s to %s Rat: %s\n',datestr(handles.startDate),datestr(handles.endDate),handles.targetRat);
end
guidata(hObject, handles);

% --- Executes on button press in Plot.
function Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dcuiparams;
inspectRatResponses(handles.targetRat,uiparams.whichPlots,uiparams.plotHandles,uiparams.subplotParams);


% --- Executes on selection change in RatPopup.
function RatPopup_Callback(hObject, eventdata, handles)
% hObject    handle to RatPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RatPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RatPopup
contents = get(hObject,'String');
handles.targetRat = contents{get(hObject,'Value')};
fprintf('Value of popup is %s\n',handles.targetRat);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function RatPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RatPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Get rat strings from file
dcuiparams;
set(hObject,'String',uiparams.subjects);
contents = get(hObject,'String');
handles.targetRat = contents{get(hObject,'Value')};
fprintf('Value of popup at startup is %s\n',handles.targetRat);
guidata(hObject, handles);



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dcuiparams

%make reports
overnight=weeklyReport(uiparams.heats{1}.subjects,1,0,uiparams.heats{1}.name);
morning=weeklyReport(uiparams.heats{2}.subjects,0,0,uiparams.heats{2}.name);   
afternoon=weeklyReport(uiparams.heats{3}.subjects,0,0,uiparams.heats{3}.name); 
wholeReport=[overnight morning afternoon];

saveToDesktop=1;
if saveToDesktop
    reportName='lastWeeklyReport.txt';
    fid = fopen([uiparams.desktopPath '\' reportName],'wt');
    fprintf(fid,'%s',sprintf (wholeReport));
    fclose(fid);
end

saveForPosterity=1;
if saveForPosterity
    reportName=sprintf('%s_weeklyReport.txt',datestr(now,30));
    fid = fopen([uiparams.weeklyLogPath '\' reportName],'wt');
    fprintf(fid,'%s',sprintf (wholeReport));
    fclose(fid);
end




% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 whichPlots=[1 1 1 1 0 1 1 1 1 1 1 1 1]; %see a lot ; 
    whichPlots=[1 1 0 0 0 0 0 0 0 0 0 0 0]; %see basics
    savePlots=whichPlots; %zeros(size(whichPlots))
    
    %overnight heat
    subplotParams.x=2; subplotParams.y=3; handles=[1:13];
    subplotParams.index=1; inspectRatResponses('rat_113',whichPlots,handles,subplotParams)
    subplotParams.index=3; inspectRatResponses('rat_102',whichPlots,handles,subplotParams)
    subplotParams.index=5; inspectRatResponses('rat_106',whichPlots,handles,subplotParams)
      whichPlots(1,[10,11,12])=0; %to include flanker analysis don't plot cued stims, which hve all 0s in cond inds
    subplotParams.index=2; inspectRatResponses('rat_114',whichPlots,handles,subplotParams)
    subplotParams.index=4; inspectRatResponses('rat_116',whichPlots,handles,subplotParams)
    subplotParams.index=6; inspectRatResponses('rat_117',whichPlots,handles,subplotParams)
     who='overnight'; where='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rats\6trixPlots\';
    savePlotsToPNG(savePlots,handles,who,where);
    
    %morning heat
    handles=[21:33];
    subplotParams.index=1; inspectRatResponses('rat_126',whichPlots,handles,subplotParams)
    subplotParams.index=3; inspectRatResponses('rat_127',whichPlots,handles,subplotParams)
    subplotParams.index=5; inspectRatResponses('rat_128',whichPlots,handles,subplotParams)
    subplotParams.index=2; inspectRatResponses('rat_129',whichPlots,handles,subplotParams)
    subplotParams.index=4; inspectRatResponses('rat_130',whichPlots,handles,subplotParams)
    subplotParams.index=6; inspectRatResponses('rat_131',whichPlots,handles,subplotParams) 
    who='morning'; where='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rats\6trixPlots\';
    savePlotsToPNG(savePlots,handles,who,where);
    
    %afternoon heat
    handles=[41:53];
    subplotParams.index=1; inspectRatResponses('rat_112',whichPlots,handles,subplotParams)
    %subplotParams.index=3; inspectRatResponses('rat_***',whichPlots,handles,subplotParams)
    %subplotParams.index=5; inspectRatResponses('rat_***',whichPlots,handles,subplotParams)   
    subplotParams.index=2; inspectRatResponses('rat_115',whichPlots,handles,subplotParams)
    subplotParams.index=4; inspectRatResponses('rat_118',whichPlots,handles,subplotParams)
    subplotParams.index=6; inspectRatResponses('rat_119',whichPlots,handles,subplotParams) 
    who='morning'; where='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rats\6trixPlots\';
    savePlotsToPNG(savePlots,handles,who,where);
