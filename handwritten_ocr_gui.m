
function varargout = handwritten_ocr_gui(varargin)
% HANDWRITTEN_OCR_GUI MATLAB code for handwritten_ocr_gui.fig
%      HANDWRITTEN_OCR_GUI, by itself, creates a new HANDWRITTEN_OCR_GUI or raises the existing
%      singleton*.
%
%      H = HANDWRITTEN_OCR_GUI returns the handle to a new HANDWRITTEN_OCR_GUI or the handle to
%      the existing singleton*.
%
%      HANDWRITTEN_OCR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HANDWRITTEN_OCR_GUI.M with the given input arguments.
%
%      HANDWRITTEN_OCR_GUI('Property','Value',...) creates a new HANDWRITTEN_OCR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before handwritten_ocr_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to handwritten_ocr_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help handwritten_ocr_gui

% Last Modified by GUIDE v2.5 12-May-2016 11:34:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @handwritten_ocr_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @handwritten_ocr_gui_OutputFcn, ...
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


% --- Executes just before handwritten_ocr_gui is made visible.
function handwritten_ocr_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to handwritten_ocr_gui (see VARARGIN)

% Choose default command line output for handwritten_ocr_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes handwritten_ocr_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = handwritten_ocr_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btn_upload.
% --- Upload Button OnClick ---
function btn_upload_Callback(hObject, eventdata, handles)
% hObject    handle to btn_upload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% Delete previous output
delete('~/Downloads/HandwrittenRecognition/HWCR-master/training_set/output.txt') 
[filename, pathname] = ...
     uigetfile('~/Downloads/HandwrittenRecognition/HWCR-master/training_set/*.jpg','Select Image File');
 %% Show Image on GUI
 global imagen
 imagen=strcat(pathname,filename); 
 axes(handles.img_input);
 imshow(imagen);
 



% --- Executes on button press in btn_generate.
% --- Generate Button OnClick ---
function btn_generate_Callback(hObject, eventdata, handles)
% hObject    handle to btn_generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 %% Train the network 
 train;
 
 %% Get the image file from global variab;e
 global imagen;
 imagen = imread(imagen);
 
 %% Preprocessing image
 if size(imagen,3)==3 % if RGB image then turn grayscale
    imagen=rgb2gray(imagen);
 end
 
 %% Convert to binary image
 threshold = graythresh(imagen);
 imagen =~im2bw(imagen,threshold);

 
 %% Remove all object containing fewer than 30 pixels
 imagen =bwareaopen(imagen,15);
 pause(1)
 
 %% Show image binary image
 figure(2)
 imshow(imagen);
 title('INPUT IMAGE WITHOUT NOISE')
 
 %% Edge detection
 Iedge = edge(uint8(imagen));
 %imshow(~Iedge)
 
 %% Morphology
 % * *Image Dilation*
 se = strel('square',2);
 Iedge2 = imdilate(Iedge, se); 
 figure(3)
 imshow(~Iedge2);
 title('IMAGE DILATION')
 % * *Image Filling*
 Ifill= imfill(Iedge2,'holes');
 figure(4)
 imshow(~Ifill)
 title('IMAGE FILLING')
 Ifill=Ifill & imagen;
 figure(5)
 imshow(~Ifill);

 re=Ifill;


 while 1
    %Fcn 'lines' separate lines in text
    [fl re]=lines(re);
    imgn=fl;
    
    % Label and count connected components
    [L Ne] = bwlabel(imgn);    

    %% Objects extraction
 for n=1:Ne
    [r,c] = find(L==n);
    n1=imgn(min(r):max(r),min(c):max(c));
    %imshow(~n1);
    BW2 = bwmorph(n1,'thin',Inf);
    imrotate(BW2,0);
    %imshow(~BW2);
    z=imresize(BW2,[50 50]);
    
    %% Perform Feature Extraction
    z=feature_extract(z);
    
    load ('featureout.mat');
    featureout=z;
    save ('featureout.mat','featureout');
    
    %% Performing Classification
    test;
 end
 
 if isempty(re)  %See variable 're' in Fcn 'lines'
        break
    end    
 end
 
 %% Read output from text file and write to GUI
fileID = fopen('~/Downloads/HandwrittenRecognition/HWCR-master/training_set/output.txt','r')
output_text =  fscanf(fileID,'%s')
set(handles.text_generated,'string', output_text);

