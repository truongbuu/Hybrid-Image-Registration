function varargout = volumeslicer(varargin)
% h = volumslicer       uses default volume, returns handle
% h = volumeslicer(vol) uses 3d matrix vol 
%
% For:    6.555 and Biz
% Author: Michael Siracusa
% 
% Please don't distribute until the code is less horrible :)
%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @volumeslicer_OpeningFcn, ...
                   'gui_OutputFcn',  @volumeslicer_OutputFcn, ...
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


% --- Executes just before volumeslicer is made visible.
function volumeslicer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to volumeslicer (see VARARGIN)

% Choose default command line output for volumeslicer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes volumeslicer wait for user response (see UIRESUME)
% uiwait(handles.figMain);

if length(varargin) == 0
  [x,y,z] = meshgrid(-2:.2:2, -2:.25:2, -2:.16:2);
  v = x .* exp(-x.^2 - y.^2 - z.^2);
else
  v = varargin{1};
end


handles.volumeOrig = v;
handles.volume = handles.volumeOrig;

handles.volumeLims = [min(handles.volumeOrig(:)) max(handles.volumeOrig(:))];
handles.volumeDims = size(handles.volume);
handles.sliceSliders = [handles.sliderYSlice handles.sliderXSlice, handles.sliderZSlice];
handles.sliceAxes = [handles.axesYSlice, handles.axesXSlice, handles.axesZSlice];
handles.sliceTitles = [handles.txtYSliceTitle, handles.txtXSliceTitle, handles.txtZSliceTitle];
handles.sliceVisible = [handles.chkYSliceVisible,handles.chkXSliceVisible,handles.chkZSliceVisible];
handles.resolutionMenus = [handles.menuResY handles.menuResX handles.menuResZ];
handles.resolution = [1 1 1];

handles.sliceNames = {'Y','X','Z'};

cla(handles.axesVolume); hold on;
for k=1:3
  handles.rangeOrig{k} = 1:size(handles.volumeOrig,k);
  handles.range{k}     = 1:handles.volumeDims(k);
end

if length(varargin) > 1
  handles = parseArgs(handles,varargin{2:end});
end

% Set slice positions to be in the middle
% Setup sliders and displays
for k=1:3

  set(handles.sliceSliders(k),'Max',1);
  set(handles.sliceSliders(k),'Min',0);
  set(handles.sliceSliders(k),'Value',.5);
  set(handles.sliceSliders(k),'SliderStep',[1 1]/handles.volumeDims(k));
  
  axes(handles.axesVolume); hold on;
  range = handles.range;
  range{k} = range{k}(end)/2;
  [xdata,ydata,zdata] = meshgrid(range{2},range{1},range{3});
  xdata = squeeze(xdata); ydata=squeeze(ydata); zdata = squeeze(zdata);
  handles.sliceSurface(k) = surface(xdata,ydata,zdata);
  set(handles.sliceSurface(k),'facelighting','none','facec','flat','edgec','n');

  otherDims = find([1 2 3] ~= k);
  outline{k} = ones(1,5)*range{k}(end)/2 ;
  outline{otherDims(1)} = range{otherDims(1)}([1   1    end end 1 ]);
  outline{otherDims(2)} = range{otherDims(2)}([1   end  end 1   1 ]);
  handles.sliceOutline(k) = plot3(outline{2},outline{1},outline{3});
  
  set(handles.sliceOutline(k),'LineStyle','--');
  set(handles.sliceOutline(k),'LineWidth',2);
  set(handles.sliceOutline(k),'Color',[0 0 0]);
  
  axes(handles.sliceAxes(k));
  handles.sliceSurfs(k)   = 0;
  handles.sliceImages(k)  = 0;
  
  % add context menu for each slice
  handles.sliceDims{k}     = otherDims;
  handles.sliceDimDirs{k}  = [0 0];
  handles.sliceDimSwap(k)  = 0;
  
  cmenu = uicontextmenu;
  set(handles.sliceAxes(k),'UIContextMenu',cmenu);
  uimenu(cmenu,'Label','Swap Axes','Callback',...
         sprintf('volumeslicer(''swapSliceAxes'',gcbo,[],guidata(gcbo),%d)',k));
  uimenu(cmenu,'Label',sprintf('Reverse %s Axes',handles.sliceNames{otherDims(1)}),'Callback',...
         sprintf('volumeslicer(''reverseSliceAxis'',gcbo,[],guidata(gcbo),%d,1)',k));
  uimenu(cmenu,'Label',sprintf('Reverse %s Axes',handles.sliceNames{otherDims(2)}),'Callback',...
         sprintf('volumeslicer(''reverseSliceAxis'',gcbo,[],guidata(gcbo),%d,2)',k));

  handles = setSlicePosition(handles,k);
end

% Iso Surface
handles.isoSurface = 0;

% 3D Axes adjustment
axes(handles.axesVolume);view(3); 
if get(handles.chkEqualAxes,'Value')
  axis equal;
  axis tight;
else
  axis auto;
  axis tight;
end

hold off;
set(handles.axesVolume,'CLim',handles.volumeLims);
xlabel(handles.sliceNames{2}); 
ylabel(handles.sliceNames{1}); 
zlabel(handles.sliceNames{3}); 
colorbar('EastOutside');

set(handles.figMain,'DoubleBuffer','on');

guidata(hObject, handles);

function varargout = volumeslicer_OutputFcn(hObject, eventdata, handles, varargin)

varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setSlicePosition.  Main drawing function
%
function handles = setSlicePosition(handles,sliceNum,pos)


updateSlider = 1;
m1 = min(handles.range{sliceNum}(:));
m2 = max(handles.range{sliceNum}(:));
if ~exist('pos','var')
  pos = get(handles.sliceSliders(sliceNum),'Value')*(m2-m1)+m1;
  updateSlider = 0;
end

[foo, posIndx] = min(abs(handles.range{sliceNum}-pos));

indx = {};
for k=1:3
  indx{k} = 1:handles.volumeDims(k);
end
indx{sliceNum} = posIndx;

% Only update the slider position if it was specified
% If not it must be a callback and then we read in the position from
if updateSlider
  set(handles.sliceSliders(sliceNum),'Value',pos);
end

slice = squeeze(handles.volume(indx{1},indx{2},indx{3}));
hold off;

dims = handles.sliceDims{sliceNum};
dirs = {'YDir','XDir'};
s = slice;
if handles.sliceDimSwap(sliceNum)
  s = s';
  dims = dims(end:-1:1);
  dirs = {dirs{end:-1:1}};
end

switch get(handles.menuSliceMode,'Value')
  case 2
    
    if handles.sliceSurfs(sliceNum)
      set(handles.sliceSurfs(sliceNum),'zdata',s);
    else
      axes(handles.sliceAxes(sliceNum)); hold off;
      handles.sliceSurfs(sliceNum) = surf(handles.range{dims(2)},handles.range{dims(1)},s);
      handles.sliceImages(sliceNum) = 0;
      axis tight;
      a = axis;
      a(5:6) = handles.volumeLims;
      axis(a);
      set(handles.sliceAxes(sliceNum),'CLimMode','manual','CLim',handles.volumeLims);
      
      xlabel(handles.sliceNames{dims(2)});
      ylabel(handles.sliceNames{dims(1)});
      
      updateAxes(handles);
    end 

  otherwise
    handles.sliceSurfs(sliceNum) = 0;
    if handles.sliceImages(sliceNum)
      set(handles.sliceImages(sliceNum),'cdata',s);
    else
      axes(handles.sliceAxes(sliceNum)); hold off;
      handles.sliceImages(sliceNum) = imagesc(handles.range{dims(2)},handles.range{dims(1)},...
                                              s,handles.volumeLims);
      set(handles.sliceAxes(sliceNum),'CLimMode','manual','CLim',handles.volumeLims);
      
      xlabel(handles.sliceNames{dims(2)});
      ylabel(handles.sliceNames{dims(1)});
      
      updateAxes(handles);
    end
end

% Deal with axis reversal
for k=1:2
  if handles.sliceDimDirs{sliceNum}(k)
    set(handles.sliceAxes(sliceNum),dirs{k},'reverse');
  else
    set(handles.sliceAxes(sliceNum),dirs{k},'normal');
  end
end


set(handles.sliceTitles(sliceNum),'String',...
  ['Slice at ' handles.sliceNames{sliceNum} ' = ' sprintf('%d',handles.range{sliceNum}(posIndx))]);


f = {'ydata','xdata','zdata'};
fdata = slice; fdata(:) = pos;
if get(handles.sliceVisible(sliceNum),'Value') == 1
  set(handles.sliceSurface(sliceNum),'cdata',slice,f{sliceNum},fdata);
  set(handles.sliceSurface(sliceNum),'Visible','on');
else
  set(handles.sliceSurface(sliceNum),'Visible','off');
end

setSliceOutlinePosition(handles,sliceNum,pos);
axes(handles.axesVolume);
guidata(handles.figMain,handles);

function setSliceOutlinePosition(handles,sliceNum,pos)

f = {'ydata','xdata','zdata'};
set(handles.sliceOutline(sliceNum),f{sliceNum},pos*ones(1,5));


% --- Executes on slider movement.
function slider_Callback(hObject, eventdata, handles)

setSlicePosition(handles,find(handles.sliceSliders == hObject));


function sliceVisible_Callback(hObject, eventdata, handles)

setSlicePosition(handles,find(handles.sliceVisible == hObject));
drawnow;




% --- Executes on button press in chkIsoSurfaceVisible.
function chkIsoSurfaceVisible_Callback(hObject, eventdata, handles)

if get(handles.chkIsoSurfaceVisible,'Value')
  
  set(handles.sliderIsoSurface,'Visible','on');

  handles = updateIsoSurface(handles);
  guidata(handles.figMain,handles);
 
  set(handles.isoSurface,'Visible','on');
  set(handles.txtIsoValue,'Visible','on');
else
  set(handles.sliderIsoSurface,'Visible','off');
  set(handles.txtIsoValue,'Visible','off');
  set(handles.isoSurface,'Visible','off');
  
  delete(handles.isoSurface);
  handles.isoSurface = 0;
  guidata(handles.figMain,handles);
end



function handles = changeResolution(handles,res)

[x y z D] = reducevolume(handles.volumeOrig,[res(2) res(1) res(3)]);
handles.volume = D;

handles.volumeDims = size(handles.volume);
for k=1:3 handles.range{k} = handles.rangeOrig{k}(1:res(k):end); end

for k=1:3
  set(handles.sliceSliders(k),'SliderStep',[1 1]*res(k)/handles.volumeDims(k));
  
  range = handles.range;
  range{k} = range{k}(end)/2;
  [xdata,ydata,zdata] = meshgrid(range{2},range{1},range{3});
  xdata = squeeze(xdata); ydata=squeeze(ydata); zdata = squeeze(zdata);
  set(handles.sliceSurface(k),'xdata',xdata,'ydata',ydata,'zdata',zdata,'cdata',zdata);
  
  setSlicePosition(handles,k);
end

if handles.isoSurface
  handles = updateIsoSurface(handles);
end

handles.resolution = res;

function handles = updateIsoSurface(handles)

range = handles.range;
[xdata,ydata,zdata] = meshgrid(range{2},range{1},range{3});
value = get(handles.sliderIsoSurface,'Value')*diff(handles.volumeLims) + handles.volumeLims(1);

% Some code borrowed from sliceomatic
clim=get(handles.axesVolume,'clim');
cmap=get(handles.figMain,'colormap');
clen=clim(2)-clim(1);
indx=floor((value-clim(1))*length(cmap)/clen);

set(handles.txtIsoValue,'String',sprintf('Isovalue=%d',value));

fv = isosurface(xdata,ydata,zdata,handles.volume,value);

if handles.isoSurface  
  set(handles.isoSurface,fv);
else
  handles.isoSurface = patch(fv);
  guidata(handles.figMain,handles);
end

try
  set(handles.isoSurface,'facecolor',cmap(indx,:));
catch
  set(handles.isoSurface,'facecolor','none');
end

c = cmap(1,:);
if get(handles.sliderIsoSurface,'Value') > .5
  c = cmap(end,:);
end

set(handles.isoSurface,'edgecolor',c,'facelighting','phong');



% --- Executes on selection change in menuColormap.
function menuColormap_Callback(hObject, eventdata, handles)
mapnames=get(hObject,'string');
colormap(mapnames{get(hObject,'value')});


% --- Executes on selection change in menuSliceMode.
function menuSliceMode_Callback(hObject, eventdata, handles)

handles = setSlicePosition(handles,1);
handles = setSlicePosition(handles,2);
handles = setSlicePosition(handles,3);
updateAxes(handles);
drawnow;


% --- Executes on selection change in menuResX.
function menuRes_Callback(hObject, eventdata, handles)

r = get(hObject,'Value');
if get(handles.chkSingleResolution,'Value')
  res = round([r r r]);
  for k=1:3
   set(handles.resolutionMenus(k),'Value',r);
  end
else
  for k=1:3
    res(k) = get(handles.resolutionMenus(k),'Value');
  end
end

if any(handles.resolution ~= res)
  handles = changeResolution(handles,round(res));
  guidata(handles.figMain,handles);
end
  

% --- Executes on button press in chkSingleResolution.
function chkSingleResolution_Callback(hObject, eventdata, handles)

if get(handles.chkSingleResolution,'Value')
  for k=1:3
    res(k) = get(handles.resolutionMenus(k),'Value');
  end
  r = min(res);
  handles = changeResolution(handles,round([r r r]));
  guidata(handles.figMain,handles);
  for k=1:3
    set(handles.resolutionMenus(k),'Value',r);
  end
end


function handles = parseArgs(handles,varargin);

k = 1;
while k < length(varargin)
  
  if isstr(varargin{k}) && (k+1) <= length(varargin)
    
    switch varargin{k}
      case {'DimNames'}
        handles.sliceNames = varargin{k+1};
        k = k+1;
      case {'DimRanges'}
        handles.rangeOrig = varargin{k+1};
        handles.range = handles.rangeOrig;
        k = k+1;
      otherwise
        k = k+1;
    end
  else
    fprintf('Invalid Argument %d\n',k+1);
  end
  k = k+1;
  
end

% --- Executes on button press in chkEqualAxes.
function chkEqualAxes_Callback(hObject, eventdata, handles)
updateAxes(handles);

function updateAxes(handles)

for sliceNum=1:3
  axes(handles.sliceAxes(sliceNum));
  switch get(handles.menuSliceMode,'Value')
    case 2
      axis tight;
    otherwise
      if get(handles.chkEqualAxes,'Value')
        axis equal;
        axis tight;
      else
        axis normal;
      end
  end
end

axes(handles.axesVolume);
if get(handles.chkEqualAxes,'Value')
  axis equal;
  axis tight;
else
  axis normal;
end
drawnow;


function reverseSliceAxis(hObject,eventdata,handles,sliceNum,dim)

switch get(hObject,'Checked')
  case 'off'
    set(hObject,'Checked','on');
    handles.sliceDimDirs{sliceNum}(dim) = 1;
  case 'on'
    set(hObject,'Checked','off');
    handles.sliceDimDirs{sliceNum}(dim) = 0;
end

handles = setSlicePosition(handles,sliceNum);
guidata(handles.figMain,handles);

function swapSliceAxes(hObject,eventdata,handles,sliceNum)

handles.sliceDimSwap(sliceNum) = ~handles.sliceDimSwap(sliceNum);

handles = setSlicePosition(handles,sliceNum);
guidata(handles.figMain,handles);

