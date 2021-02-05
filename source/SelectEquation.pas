unit SelectEquation;

{$IFDEF FPC}
 {$MODE Delphi}
{$ENDIF}

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, ComCtrls, Contnrs, ImgList, Dialogs,
  Graphics, StdCtrls, Equations, UsefulUtils;

type
  TLanguage = (lEnglish, lRussian, lDeutsche);
  TEqData = record
    Count: Integer;
    Height: Integer;
    Width: Integer;
    Visible: String;
    DescrList: array of String;
  end;

  TImageLists = class(TObjectList)
  private
    function GetItem(Index: Integer): TImageList;
    procedure SetItem(Index: Integer; AImageList: TImageList);
  public
    property Items[Index: Integer]: TImageList read GetItem write SetItem;
  end;

  TSelectEquation = class(TCustomPanel)
  private
    { Private declarations }
    FEqDataList: array of TEqData;
    FImageLists: TImageLists;
    FLabel: TLabel;
    FPageControl: TPageControl;
    FToolBar: TToolBar;
    FQDSEquation: TQDSEquation;
    FLanguage: TLanguage;
    procedure BtMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure BtPanelClick(Sender: TObject);
    procedure BtTabSheetClick(Sender: TObject);
    procedure CreateDescript;
    procedure CreateImageLists;
    procedure CreateLabel;
    procedure CreatePageControl;
    procedure CreateToolBar(AParent: TWinControl; Index: Integer);
    procedure SetQDSEquation(AQDSEquation: TQDSEquation);
    procedure SetLanguage(const Value: TLanguage);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CreateWnd; override;
  published
    { Published declarations }
    property Align;
    property Anchors;
    property AutoSize;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property Constraints;
    {$IFNDEF FPC}
    property Ctl3D;
    {$ENDIF}
    property Enabled;
    property Equation: TQDSEquation read FQDSEquation write SetQDSEquation;
    property Language: TLanguage read FLanguage write SetLanguage;
    property PopupMenu;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

procedure Register;

implementation

{$IFDEF FPC}
 {$R ../resources/images.res}
 {$R ../resources/localize.res}
{$ELSE}
 {$R images.res}
 {$R localize.res}
{$ENDIF}

procedure Register;
begin
  RegisterComponents('QDS Equations', [TSelectEquation]);
end;

{ TImageLists }

function TImageLists.GetItem(Index: Integer): TImageList;
begin
  Result := TImageList(inherited Items[Index]);
end;

procedure TImageLists.SetItem(Index: Integer; AImageList: TImageList);
begin
  inherited Items[Index] := AImageList;
end;

{ TSelectEquaion }

procedure TSelectEquation.BtMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  AToolButton: TToolButton;
begin
  AToolButton:=(Sender as TToolButton);
  if AToolButton.Parent=FToolBar then begin
    AToolButton.Hint:={Format('0 %d %s',[AToolButton.Tag, }FEqDataList[0].DescrList[AToolButton.Tag]{])};
  end else begin
    AToolButton.Hint:={Format('%d %d %s',[AToolButton.Tag, AToolButton.ImageIndex, }FEqDataList[AToolButton.Tag].DescrList[AToolButton.ImageIndex]{])};
  end;

  FLabel.Caption:=AToolButton.Hint;
end;

procedure TSelectEquation.BtPanelClick(Sender: TObject);
var
  AToolButton: TToolButton;
begin
  FToolBar.Buttons[FPageControl.ActivePageIndex].Down:=False;
  AToolButton:=(Sender as TToolButton);
  FPageControl.ActivePageIndex := AToolButton.Tag;
  AToolButton.Down:=True;
end;

procedure TSelectEquation.BtTabSheetClick(Sender: TObject);
var
  AToolButton: TToolButton;
begin
  AToolButton:=(Sender as TToolButton);
  if Assigned(FQDSEquation) then begin
    case AToolButton.Tag of
      1:
        case AToolButton.ImageIndex of
          0:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8804);
          1:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8805);
          6:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8800);
          7:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8801);
          8:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8776);
        end;
      2:
        case AToolButton.ImageIndex of
          2:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(160);
          6:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8230);
        end;
      4:
        case AToolButton.ImageIndex of
          0:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(177);
          2:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(215);
          3:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(247);
          4:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(42);
          5:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8729);
          6:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(9675);//9702
          7:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(9679);
          10: FQDSEquation.ActiveEditArea.AddEqExtSymbol(8249);
          11: FQDSEquation.ActiveEditArea.AddEqExtSymbol(8250);

        end;
      5:
        case AToolButton.ImageIndex of
          0:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8594);
          1:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8592);
          2:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8596);
          3:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8593);
          4:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8595);
          5:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8597);
        end;
      6:
        case AToolButton.ImageIndex of
          5:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(9488);
        end;
      7:
        case AToolButton.ImageIndex of
          3:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8745);
        end;  

      8:
        case AToolButton.ImageIndex of
          0:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8706);
          2:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8734);
          7:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(9524);
          8:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(9674);
          9:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(8467);
          11: FQDSEquation.ActiveEditArea.AddEqExtSymbol(176);
          12: FQDSEquation.ActiveEditArea.AddEqExtSymbol(295);
          14: FQDSEquation.ActiveEditArea.AddEqExtSymbol(8747);
          15: FQDSEquation.ActiveEditArea.AddEqExtSymbol(8721);//931
          16: FQDSEquation.ActiveEditArea.AddEqExtSymbol(8719);
        end;
      9:
        case AToolButton.ImageIndex of
          0:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(945);
          1:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(946);
          2:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(967);
          3:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(948);
          4:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(949);
          5:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(966);//
          6:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(966);
          7:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(947);
          8:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(951);
          9:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(953);
          10: FQDSEquation.ActiveEditArea.AddEqExtSymbol(954);
          11: FQDSEquation.ActiveEditArea.AddEqExtSymbol(955);
          12: FQDSEquation.ActiveEditArea.AddEqExtSymbol(956);
          13: FQDSEquation.ActiveEditArea.AddEqExtSymbol(957);
          14: FQDSEquation.ActiveEditArea.AddEqExtSymbol(959);
          15: FQDSEquation.ActiveEditArea.AddEqExtSymbol(960);
          16: FQDSEquation.ActiveEditArea.AddEqExtSymbol(969);//
          17: FQDSEquation.ActiveEditArea.AddEqExtSymbol(952);
          18: FQDSEquation.ActiveEditArea.AddEqExtSymbol(952);//
          19: FQDSEquation.ActiveEditArea.AddEqExtSymbol(961);
          20: FQDSEquation.ActiveEditArea.AddEqExtSymbol(963);
          21: FQDSEquation.ActiveEditArea.AddEqExtSymbol(962);
          22: FQDSEquation.ActiveEditArea.AddEqExtSymbol(964);
          23: FQDSEquation.ActiveEditArea.AddEqExtSymbol(965);
          24: FQDSEquation.ActiveEditArea.AddEqExtSymbol(969);
          25: FQDSEquation.ActiveEditArea.AddEqExtSymbol(958);
          26: FQDSEquation.ActiveEditArea.AddEqExtSymbol(968);
          27: FQDSEquation.ActiveEditArea.AddEqExtSymbol(950);
        end;
      10:
        case AToolButton.ImageIndex of
          0:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(913);
          1:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(914);
          2:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(935);
          3:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(916);
          4:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(917);
          5:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(934);
          6:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(915);
          7:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(919);
          8:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(921);
          9:  FQDSEquation.ActiveEditArea.AddEqExtSymbol(922);
          10: FQDSEquation.ActiveEditArea.AddEqExtSymbol(923);
          11: FQDSEquation.ActiveEditArea.AddEqExtSymbol(924);
          12: FQDSEquation.ActiveEditArea.AddEqExtSymbol(925);
          13: FQDSEquation.ActiveEditArea.AddEqExtSymbol(927);
          14: FQDSEquation.ActiveEditArea.AddEqExtSymbol(928);
          15: FQDSEquation.ActiveEditArea.AddEqExtSymbol(920);
          16: FQDSEquation.ActiveEditArea.AddEqExtSymbol(929);
          17: FQDSEquation.ActiveEditArea.AddEqExtSymbol(931);
          18: FQDSEquation.ActiveEditArea.AddEqExtSymbol(932);
          19: FQDSEquation.ActiveEditArea.AddEqExtSymbol(933);
          20: FQDSEquation.ActiveEditArea.AddEqExtSymbol(937);
          21: FQDSEquation.ActiveEditArea.AddEqExtSymbol(926);
          22: FQDSEquation.ActiveEditArea.AddEqExtSymbol(936);
          23: FQDSEquation.ActiveEditArea.AddEqExtSymbol(918);
        end;
      11:
        case AToolButton.ImageIndex of
          0:  FQDSEquation.ActiveEditArea.AddEqBrackets(kbRound);
          1:  FQDSEquation.ActiveEditArea.AddEqBrackets(kbSquare);
          2:  FQDSEquation.ActiveEditArea.AddEqBrackets(kbFigure);
          3:  FQDSEquation.ActiveEditArea.AddEqBrackets(kbCorner);
          4:  FQDSEquation.ActiveEditArea.AddEqBrackets(kbModule);
          5:  FQDSEquation.ActiveEditArea.AddEqBrackets(kbDModule);
        end;
      12:
        case AToolButton.ImageIndex of
          0:  FQDSEquation.ActiveEditArea.AddEqDivision;
          5:  FQDSEquation.ActiveEditArea.AddEqSquare;

        end;
      13:
        case AToolButton.ImageIndex of
          0:  FQDSEquation.ActiveEditArea.AddEqIndex([goIndexTop]);
          1:  FQDSEquation.ActiveEditArea.AddEqIndex([goIndexBottom]);
          2:  FQDSEquation.ActiveEditArea.AddEqIndex([goIndexTop, goIndexBottom]);
        end;
      14:
        case AToolButton.ImageIndex of
          0:  FQDSEquation.ActiveEditArea.AddEqSumma([]);
          1:  FQDSEquation.ActiveEditArea.AddEqSumma([goLimitBottom]);
          2:  FQDSEquation.ActiveEditArea.AddEqSumma([goLimitTop, goLimitBottom]);
          3:  FQDSEquation.ActiveEditArea.AddEqSumma([goIndexBottom]);
          4:  FQDSEquation.ActiveEditArea.AddEqSumma([goIndexTop, goIndexBottom]);
        end;
      15:
        case AToolButton.ImageIndex of
          0:  FQDSEquation.ActiveEditArea.AddEqIntegral([], 1, False);
          1:  FQDSEquation.ActiveEditArea.AddEqIntegral([goLimitTop, goLimitBottom], 1, False);
          2:  FQDSEquation.ActiveEditArea.AddEqIntegral([goIndexTop, goIndexBottom], 1, False);
          3:  FQDSEquation.ActiveEditArea.AddEqIntegral([], 1, False);
          4:  FQDSEquation.ActiveEditArea.AddEqIntegral([goLimitBottom], 1, False);
          5:  FQDSEquation.ActiveEditArea.AddEqIntegral([goIndexBottom], 1, False);
          6:  FQDSEquation.ActiveEditArea.AddEqIntegral([], 2, False);
          7:  FQDSEquation.ActiveEditArea.AddEqIntegral([goLimitBottom], 2, False);
          8:  FQDSEquation.ActiveEditArea.AddEqIntegral([goIndexBottom], 2, False);
          9:  FQDSEquation.ActiveEditArea.AddEqIntegral([], 3, False);
          10: FQDSEquation.ActiveEditArea.AddEqIntegral([goLimitBottom], 3, False);
          11: FQDSEquation.ActiveEditArea.AddEqIntegral([goIndexBottom], 3, False);
          12: FQDSEquation.ActiveEditArea.AddEqIntegral([], 1, True);
          13: FQDSEquation.ActiveEditArea.AddEqIntegral([goLimitBottom], 1, True);
          14: FQDSEquation.ActiveEditArea.AddEqIntegral([goIndexBottom], 1, True);
          15: FQDSEquation.ActiveEditArea.AddEqIntegral([], 2, True);
          16: FQDSEquation.ActiveEditArea.AddEqIntegral([goLimitBottom], 2, True);
          17: FQDSEquation.ActiveEditArea.AddEqIntegral([goIndexBottom], 2, True);
          18: FQDSEquation.ActiveEditArea.AddEqIntegral([], 3, True);
          19: FQDSEquation.ActiveEditArea.AddEqIntegral([goLimitBottom], 3, True);
          20: FQDSEquation.ActiveEditArea.AddEqIntegral([goIndexBottom], 3, True);
        end;
      16:
        case AToolButton.ImageIndex of
          0:  FQDSEquation.ActiveEditArea.AddEqVector([], aeBottom);
          1:  FQDSEquation.ActiveEditArea.AddEqVector([kaDouble], aeBottom);
          2:  FQDSEquation.ActiveEditArea.AddEqVector([], aeTop);
          3:  FQDSEquation.ActiveEditArea.AddEqVector([kaDouble], aeTop);
          4:  FQDSEquation.ActiveEditArea.AddEqVector([kaRight], aeBottom);
          5:  FQDSEquation.ActiveEditArea.AddEqVector([kaLeft], aeBottom);
          6:  FQDSEquation.ActiveEditArea.AddEqVector([kaRight, kaLeft], aeBottom);
          7:  FQDSEquation.ActiveEditArea.AddEqVector([kaRight], aeTop);
          8:  FQDSEquation.ActiveEditArea.AddEqVector([kaLeft], aeTop);
          9:  FQDSEquation.ActiveEditArea.AddEqVector([kaRight, kaLeft], aeTop);
        end;
      17:
        case AToolButton.ImageIndex of
          0:  FQDSEquation.ActiveEditArea.AddEqArrow([kaRight], aeTop);
          1:  FQDSEquation.ActiveEditArea.AddEqArrow([kaLeft], aeTop);
          2:  FQDSEquation.ActiveEditArea.AddEqArrow([kaLeft, kaRight], aeTop);
          3:  FQDSEquation.ActiveEditArea.AddEqArrow([kaRight], aeBottom);
          4:  FQDSEquation.ActiveEditArea.AddEqArrow([kaLeft], aeBottom);
          5:  FQDSEquation.ActiveEditArea.AddEqArrow([kaLeft, kaRight], aeBottom);
        end;
      18:
        case AToolButton.ImageIndex of
          0:  FQDSEquation.ActiveEditArea.AddEqMultiply([]);
          1:  FQDSEquation.ActiveEditArea.AddEqMultiply([goLimitBottom]);
          2:  FQDSEquation.ActiveEditArea.AddEqMultiply([goLimitTop, goLimitBottom]);
          3:  FQDSEquation.ActiveEditArea.AddEqMultiply([goIndexBottom]);
          4:  FQDSEquation.ActiveEditArea.AddEqMultiply([goIndexTop, goIndexBottom]);
          5:  FQDSEquation.ActiveEditArea.AddEqCoMult([]);
          6:  FQDSEquation.ActiveEditArea.AddEqCoMult([goLimitBottom]);
          7:  FQDSEquation.ActiveEditArea.AddEqCoMult([goLimitTop, goLimitBottom]);
          8:  FQDSEquation.ActiveEditArea.AddEqCoMult([goIndexBottom]);
          9:  FQDSEquation.ActiveEditArea.AddEqCoMult([goIndexTop, goIndexBottom]);
          10: FQDSEquation.ActiveEditArea.AddEqIntersection([]);
          11: FQDSEquation.ActiveEditArea.AddEqIntersection([goLimitBottom]);
          12: FQDSEquation.ActiveEditArea.AddEqIntersection([goLimitTop, goLimitBottom]);
          13: FQDSEquation.ActiveEditArea.AddEqIntersection([goIndexBottom]);
          14: FQDSEquation.ActiveEditArea.AddEqIntersection([goIndexTop, goIndexBottom]);
          15: FQDSEquation.ActiveEditArea.AddEqJoin([]);
          16: FQDSEquation.ActiveEditArea.AddEqJoin([goLimitBottom]);
          17: FQDSEquation.ActiveEditArea.AddEqJoin([goLimitTop, goLimitBottom]);
          18: FQDSEquation.ActiveEditArea.AddEqJoin([goIndexBottom]);
          19: FQDSEquation.ActiveEditArea.AddEqJoin([goIndexTop, goIndexBottom]);
        end;
      19:                  {(kmHoriz, kmVert, kmSquare)}
        case AToolButton.ImageIndex of
          0:  FQDSEquation.ActiveEditArea.AddEqMatrix(kmHoriz, 2);
          1:  FQDSEquation.ActiveEditArea.AddEqMatrix(kmVert, 2);
          2:  FQDSEquation.ActiveEditArea.AddEqMatrix(kmSquare, 4);
          3:  FQDSEquation.ActiveEditArea.AddEqMatrix(kmHoriz, 3);
          4:  FQDSEquation.ActiveEditArea.AddEqMatrix(kmVert, 3);
          5:  FQDSEquation.ActiveEditArea.AddEqMatrix(kmSquare, 9);
          6:  FQDSEquation.ActiveEditArea.AddEqMatrix(kmHoriz, 4);
          7:  FQDSEquation.ActiveEditArea.AddEqMatrix(kmVert, 4);
          8:  FQDSEquation.ActiveEditArea.AddEqMatrix(kmSquare, 16);
        end;
    end;
    if FQDSEquation.Enabled then FQDSEquation.SetFocus;
  end;  
end;

procedure TSelectEquation.CreateDescript;
var
  i, j, LangID: Integer;
  function EqData(Count, Height, Width: Integer; AVisible: String): TEqData;
  begin
    Result.Count:=Count;
    Result.Height:=Height;
    Result.Width:=Width;
    Result.Visible:=AVisible;
  end;
begin
  SetLength(FEqDataList, 20);
  FEqDataList[ 0]:=EqData(19,20,40,'1101111111111111111');
  FEqDataList[ 1]:=EqData(11,10,10,'11000011100');
  FEqDataList[ 2]:=EqData(11,15,15,'00100010000');
  FEqDataList[ 3]:=EqData(20,15,15,'00000000000000000000');
  FEqDataList[ 4]:=EqData(12,10,10,'101111110011');
  FEqDataList[ 5]:=EqData(14,15,15,'11111100000000');
  FEqDataList[ 6]:=EqData( 8,10,10,'00000100');
  FEqDataList[ 7]:=EqData(12,10,10,'000100000000');
  FEqDataList[ 8]:=EqData(18,10,10,'101000011101101111');
  FEqDataList[ 9]:=EqData(28,15,15,'1111111111111111111111111111');
  FEqDataList[10]:=EqData(24,10,10,'111111111111111111111111');
  FEqDataList[11]:=EqData(30,20,20,'111111000000000000000000000000');
  FEqDataList[12]:=EqData( 9,20,20,'100001000'{'101011100'});
  FEqDataList[13]:=EqData(15,20,20,'111000000000000');
  FEqDataList[14]:=EqData( 5,20,20,'11111');
  FEqDataList[15]:=EqData(21,20,20,'111111111111111111111');
  FEqDataList[16]:=EqData(10,15,15,'1111111111');
  FEqDataList[17]:=EqData( 6,15,15,'111111');
  FEqDataList[18]:=EqData(20,20,20,'11111111111111111111');
  FEqDataList[19]:=EqData(12,20,20,'111111111000');
  LangID:=1;
  case FLanguage of
    lEnglish: LangID:=3;
    lRussian: LangID:=1;
    lDeutsche: LangID:=2;
  end;

  for i:=0 to Length(FEqDataList)-1 do begin
    SetLength(FEqDataList[i].DescrList, FEqDataList[i].Count);
    for j:=0 to Length(FEqDataList[i].DescrList)-1 do
      FEqDataList[i].DescrList[j]:=GetString(Format('%d%s%s',[LangID,IntToStrZero(i,2),IntToStrZero(j,2)]));
  end;
end;

procedure TSelectEquation.CreateImageLists;
var
  i: Integer;
  {$IFDEF FPC}
  bmp: TBitmap;
  {$ENDIF}
begin
  FImageLists:=TImageLists.Create;
  for i:=0 to Length(FEqDataList)-1 do begin
    FImageLists.Insert(i, TImageList.Create(Self));
    FImageLists.Items[i].Width:=FEqDataList[i].Width;
    FImageLists.Items[i].Height:=FEqDataList[i].Height;
    {$IFDEF FPC}
    bmp := TBitmap.Create;
    bmp.Transparent := true;
    bmp.TransparentColor := clWhite;
    bmp.LoadFromResourceName(HINSTANCE, 'BT'+IntToStrZero(i, 2));
    FImageLists.Items[i].AddSliced(bmp, FEqDataList[i].Count, 1);
    bmp.Free;
    {$ELSE}
    FImageLists.Items[i].GetResource(rtBitmap,'BT'+IntToStrZero(i, 2),FImageLists.Items[i].Width,[lrTransparent],clWhite);
    {$ENDIF}
  end;
end;

procedure TSelectEquation.CreateLabel;
begin
  FLabel:=TLabel.Create(Self);
  FLabel.Parent:=Self;
  FLabel.Align:=alTop;
  FLabel.Caption:='';
  FLabel.WordWrap:=True;
end;

procedure TSelectEquation.CreatePageControl;
var
  TabSheet: TTabSheet;
  i: Integer;
begin
  FPageControl:=TPageControl.Create(Self);
  FPageControl.Parent:=Self;
  FPageControl.Align:=alClient;
  FPageControl.Style:=tsButtons;
  for i:=1 to Length(FEqDataList)-1 do begin
    TabSheet:=TTabSheet.Create(FPageControl);
    TabSheet.Parent:=FPageControl;
    TabSheet.PageControl:=FPageControl;
    FPageControl.Pages[i-1].TabVisible := False;
    CreateToolBar(TabSheet, i);
  end;
  FPageControl.ActivePageIndex:=0;
end;

procedure TSelectEquation.CreateToolBar(AParent: TWinControl; Index: Integer);
var
  ToolButton: TToolButton;
  i: Integer;
begin
  FToolBar:=TToolBar.Create(Self);
  FToolBar.Parent:=AParent;
  FToolBar.AutoSize:=True;
  FToolBar.Flat:=True;
  FToolBar.ButtonHeight:=FEqDataList[Index].Height + 8;
  FToolBar.ButtonWidth:=FEqDataList[Index].Width;
  FToolBar.Images:=FImageLists.Items[Index];
  for i:=FEqDataList[Index].Count-1 downto 0 do begin
    ToolButton:=TToolButton.Create(FToolBar);
    ToolButton.Parent:=FToolBar;
    ToolButton.Hint:=FEqDataList[Index].DescrList[i];
    ToolButton.ShowHint:=True;
    ToolButton.ImageIndex:=i;
    ToolButton.OnMouseMove:=BtMouseMove;
    if AParent is TSelectEquation then begin
      ToolButton.Tag:=i;
      ToolButton.Enabled:=FPageControl.PageCount>i;
      ToolButton.OnClick:=BtPanelClick;
    end;
    if AParent is TTabSheet then begin
      ToolButton.Tag:=Index;
      ToolButton.Enabled:=True;
      ToolButton.OnClick:=BtTabSheetClick;
    end;
    ToolButton.AutoSize:=True;
    ToolButton.Visible:=FEqDataList[Index].Visible[i+1]='1';

  end;
end;

constructor TSelectEquation.Create(AOwner: TComponent);
begin
  inherited;
  FLanguage:=lRussian;
  CreateDescript;
  CreateImageLists;
end;

destructor TSelectEquation.Destroy;
begin
  FLabel.Free;
  FPageControl.Free;
  FImageLists.Free;
  inherited;
end;


procedure TSelectEquation.SetQDSEquation(AQDSEquation: TQDSEquation);
begin
  FQDSEquation:=AQDSEquation;
end;

procedure TSelectEquation.CreateWnd;
begin
  inherited CreateWnd;
  CreatePageControl;
  CreateLabel;
  CreateToolBar(Self, 0);
  //AutoSize:=True;
  FToolBar.Buttons[0].Click;
end;


procedure TSelectEquation.SetLanguage(const Value: TLanguage);
begin
  FLanguage := Value;
  CreateDescript;
end;

end.
