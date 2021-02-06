//{$Define DEMO}
unit Equations;

{$IFDEF FPC}
 {$MODE Delphi}
{$ENDIF}

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, ExtCtrls, Forms,
  Dialogs, Contnrs, UsefulUtils, Math;

type
  TKindBracket=(kbRound, kbSquare, kbFigure, kbCorner, kbModule, kbDModule);
  TKindArrow = set of (kaRight, kaLeft, kaDouble);
  TAlignEA = (aeTop, aeBottom);
  TGroupOptions = set of (goLimitTop, goLimitBottom, goIndexTop, goIndexBottom);
  TKindMatrix = (kmHoriz, kmVert, kmSquare);

  TExpression = record
    ClassName: string;
    ExprData: string;
  end;

  TExprArray = array of TExpression;
  TEditArea = class;
  TEquation = class;
  TEditAreaList = class(TObjectList)
  private
    function GetItem(Index: Integer): TEditArea;
    procedure SetItem(Index: Integer; AValue: TEditArea);
  public
    property Items[Index: Integer]: TEditArea read GetItem write SetItem;
  end;

  TEquationList = class(TStringList)
  private
    function GetItem(Index: Integer): TEquation;
    procedure PutItem(Index: Integer; AValue: TEquation);
  public
    property Items[Index: Integer]: TEquation read GetItem write PutItem;
  end;

  TQDSGraphic = class(TCustomControl)
  private
    FBkColor: TColor;
    procedure SetBkColor(AValue: TColor); virtual;
  protected
    function GetExprData(const ExprData: String): TExprArray;
    procedure RefreshDimensions; virtual; abstract;
    property BkColor: TColor read FBkColor write SetBkColor;
    property Canvas;
    property Font;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TEquatStore = class(TQDSGraphic)
  private
    FEditAreaIndex: Integer;
    FEditAreaList: TEditAreaList;
    FLevel: Integer;
    FUpdateCount: Integer;
    Kp: Double;
    procedure SetEditAreaIndex(AValue: Integer);
    procedure SetEditAreaList(AValue: TEditAreaList);
    procedure SetUpdateState(Updating: Boolean); virtual; abstract;
  protected
    procedure EditAreaDown; dynamic;
    procedure EditAreaUp; dynamic;
    procedure RefreshEditArea(AEditAreaIndex: Integer = 0); dynamic;
    property EditAreaIndex: Integer read FEditAreaIndex write SetEditAreaIndex;
    property Level: Integer read FLevel write FLevel;
    property UpdateCount: Integer read FUpdateCount;
  public
    procedure BeginUpdate;
    procedure DeleteEditArea; dynamic;
    procedure EndUpdate;
    procedure InsertEditArea; dynamic;
    property EditAreaList: TEditAreaList read FEditAreaList write
        SetEditAreaList;
  end;

  TQDSEquation = class(TEquatStore)
  private
    FActiveEditArea: TEditArea;
    FOnChange: TNotifyEvent;
    FVersion: String;
    function GetData: string;
    procedure SetBkColor(AValue: TColor); override;
    procedure SetData(const AValue: string);
    procedure SetUpdateState(Updating: Boolean); override;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message
        WM_LBUTTONDOWN;
  protected
    function CalcHeight(AIndex: Integer): Integer;
    function CalcWidth: Integer;
    procedure Change; virtual;
    procedure EditAreaDown; override;
    procedure EditAreaUp; override;
    procedure FontChanged(Sender: TObject); dynamic;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure RefreshEditArea(AEditAreaIndex: Integer = 0); override;
    procedure RefreshDimensions; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddEditArea;
    procedure DeleteEditArea; override;
    procedure InsertEditArea; override;
    procedure Paint; override;
    property ActiveEditArea: TEditArea read FActiveEditArea write
        FActiveEditArea;
    property Canvas;
  published
    property Align;
    property Anchors;
    property BkColor;
    property Data: String read GetData write SetData;
    property Enabled;
    property Font;
    property Version: String read FVersion;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TEACursor = class(TQDSGraphic)
  private
    FComVisible: Boolean;
    Timer: TTimer;
    function GetParent: TEditArea;
    procedure PutParent(AValue: TEditArea);
    procedure RefreshVisible;
    procedure SetComVisible(Value: Boolean);
  protected
    procedure Paint; override;
    procedure RefreshDimensions; override;
    procedure Time(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ComVisible: Boolean read FComVisible write SetComVisible;
    property Parent: TEditArea read GetParent write PutParent;
  end;

  TEditArea = class(TQDSGraphic)
  private
    FActive: Boolean;
    FCursor: TEACursor;
    FEquationIndex: Integer;
    FEquationList: TEquationList;
    Index: Integer;
    MainArea: TQDSEquation;
    function GetData: string;
    function GetIsEmpty: Boolean;
    function GetParent: TEquatStore;
    procedure OnActive;
    procedure OnDeactive;
    procedure PutParent(AValue: TEquatStore);
    procedure RefreshCursor;
    procedure RefreshEquations;
    procedure RefreshRecurse;
    procedure SetActive(AValue: Boolean);
    procedure SetBkColor(AValue: TColor); override;
    procedure SetData(const AValue: string);
    procedure SetEquationIndex(AValue: Integer);
    procedure SetEquationList(AValue: TEquationList);
    procedure WMLButtonDown(var Message: TWMLButtonDown); message
        WM_LBUTTONDOWN;
  protected

    function CalcWidth(AIndex: Integer): Integer;
    procedure RefreshDimensions; override;
  public
    function CalcHeight: Integer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddEqBrackets(kb: TKindBracket);
    procedure AddEqExtSymbol(SymbolCode: Integer);
    procedure AddEqIndex(go: TGroupOptions);
    procedure AddEqIntegral(go: TGroupOptions; Size: Integer; Ring: Boolean);
    procedure AddEqSimple(Ch: Char);
    procedure AddEqVector(ka: TKindArrow; ae: TAlignEA); 
    procedure AddEqSumma(go: TGroupOptions);
    procedure AddEqMultiply(go: TGroupOptions);
    procedure AddEqJoin(go: TGroupOptions);
    procedure AddEqIntersection(go: TGroupOptions);
    procedure AddEqCoMult(go: TGroupOptions);
    procedure AddEqArrow(ka: TKindArrow; ae: TAlignEA);
    procedure AddEqSquare;
    procedure AddEqDivision;
    procedure AddEqMatrix(km: TKindMatrix; CountEA: Integer);
    procedure DelEquation(AEquationIndex: Integer);
    procedure Paint; override;
    property Active: Boolean read FActive write SetActive;
    property Cursor: TEACursor read FCursor write FCursor;
    property Data: string read GetData write SetData;
    property EquationIndex: Integer read FEquationIndex write SetEquationIndex;
    property EquationList: TEquationList read FEquationList write
        SetEquationList;
    property IsEmpty: Boolean read GetIsEmpty;
    property Parent: TEquatStore read GetParent write PutParent;
  end;

  TEquation = class(TEquatStore)
  private
    Index: Integer;
    function GetData: string; virtual;
    function GetMidLine: Integer; virtual;
    function GetParent: TEditArea;
    procedure PutParent(AValue: TEditArea);
    procedure SetData(const AValue: string); virtual;
    procedure SetUpdateState(Updating: Boolean); override;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message
        WM_LBUTTONDOWN;
    property Data: string read GetData write SetData;
  protected
    function CalcHeight: Integer; dynamic;
    function CalcWidth: Integer; dynamic;
    procedure SetCanvasFont;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    property MidLine: Integer read GetMidLine;
    property Parent: TEditArea read GetParent write PutParent;
  end;

  TEqSimple = class(TEquation)
  private
    function GetData: string; override;
  protected
    Ch: Char;
    function CalcHeight: Integer; override;
    function CalcWidth: Integer; override;
    procedure RefreshDimensions; override;
  public
    procedure Paint; override;
  end;

  TEqExtSymbol = class(TEquation)
  private
    function GetData: string; override;
  protected
    Symbol: WideChar;
    function CalcHeight: Integer; override;
    function CalcWidth: Integer; override;
    procedure RefreshDimensions; override;
  public
    procedure Paint; override;
  end;

  TEqParent = class(TEquation)
  private
    function GetData: string; override;
    procedure SetBkColor(AValue: TColor); override;
    procedure SetData(const AValue: string); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InsertEditArea; override;
  end;

  TEqGroupOp = class(TEqParent)
  private
    FRing: Boolean;
    FSize: Integer;
    FSymbol: WideChar;
    FGroupOptions: TGroupOptions;
    FLimitTop, FLimitBottom, FIndexTop, FIndexBottom: TEditArea;
    function GetCommonHeight: Integer;
    function GetCommonWidth: Integer;
    function GetData: string; override;
    procedure SetData(const AValue: string); override;
    function GetMidLine: Integer; override;
    function GetSymbolHeight: Integer;
    function GetSymbolWidth: Integer;
    function GetTopMargin: Integer;
    procedure SetGroupOptions(Value: TGroupOptions);
    procedure SetRing(ARing: Boolean);
    procedure SetSize(ASize: Integer);
    procedure SetSymbol(Value: WideChar);
  protected
    function CalcHeight: Integer; override;
    function CalcSymbolHeight: Integer;
    function CalcSymbolWidth: Integer;
    function CalcWidth: Integer; override;
    procedure RefreshDimensions; override;
    procedure RefreshEA(AEditArea: TEditArea; AKp: Double);
    procedure RefreshEditArea(AEditAreaIndex: Integer = 0); override;
  public
    constructor Create(AOwner: TComponent); override;
    property GroupOptions: TGroupOptions read FGroupOptions write SetGroupOptions;
    procedure Paint; override;
    property Ring: Boolean read FRing write SetRing;
    property Size: Integer read FSize write SetSize;
    property Symbol: WideChar read FSymbol write SetSymbol;
    property SymbolHeight: Integer read GetSymbolHeight;
    property SymbolWidth: Integer read GetSymbolWidth;
    property TopMargin: Integer read GetTopMargin;
  end;

  TEqIntegral = class(TEqGroupOp)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TEqSumma = class(TEqGroupOp)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TEqMultiply = class(TEqGroupOp)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TEqIntersection = class(TEqGroupOp)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TEqJoin = class(TEqGroupOp)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TEqCoMult = class(TEqGroupOp)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TEqIndex = class(TEqParent)
  private
    FIndexTop, FIndexBottom: TEditArea;
    FGroupOptions: TGroupOptions;
    function GetData: String; override;
    procedure SetData(const AValue: String); override;
    procedure SetGroupOptions(const Value: TGroupOptions);
  protected
    function CalcHeight: Integer; override;
    function CalcWidth: Integer; override;
    procedure RefreshDimensions; override;
    procedure RefreshEA(AEditArea: TEditArea);
    procedure RefreshEditArea(AEditAreaIndex: Integer = 0); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    property GroupOptions: TGroupOptions read FGroupOptions write SetGroupOptions;
  end;

  TEqBrackets = class(TEqParent)
  private
    FLSymbol: WideChar;
    FRSymbol: WideChar;
    FKindBracket: TKindBracket;
    procedure SetKindBracket(AValue: TKindBracket);
    procedure SetLSymbol(Value: WideChar);
    procedure SetRSymbol(Value: WideChar);
  protected
    function CalcSymbolWidth: Integer;
    function CalcSymbolHeight: Integer;
    function CalcHeight: Integer; override;
    function CalcWidth: Integer; override;
    function GetCommonHeight: Integer;
    procedure RefreshDimensions; override;
    procedure RefreshEditArea(AEditAreaIndex: Integer = 0); override;
    property KindBracket: TKindBracket read FKindBracket write SetKindBracket;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    property LSymbol: WideChar read FLSymbol write SetLSymbol;
    property RSymbol: WideChar read FRSymbol write SetRSymbol;
  end;

  TEqArrow = class(TEqParent)
  private
    ArrowHeight, LineHeight: Integer;
    FAlignEA: TAlignEA;
    FKindArrow: TKindArrow;

    function GetMidLine: Integer; override;
    procedure SetKindArrow(Value: TKindArrow);
    procedure SetAlignEA(const Value: TAlignEA);
  protected
    function CalcHeight: Integer; override;
    function CalcWidth: Integer; override;
    procedure RefreshDimensions; override;
    procedure RefreshEditArea(AEditAreaIndex: Integer = 0); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    property AlignEA: TAlignEA read FAlignEA write SetAlignEA;
    property KindArrow: TKindArrow read FKindArrow write SetKindArrow;
  end;

  TEqSquare = class(TEqParent)
  private
    LineHeight: Integer;
    GalkaLeft: Integer;
    function GetMidLine: Integer; override;
  protected
    function CalcHeight: Integer; override;
    function CalcWidth: Integer; override;
    procedure RefreshDimensions; override;
    procedure RefreshEditArea(AEditAreaIndex: Integer = 0); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;

  TEqDivision = class(TEqParent)
  private
    ArrowHeight, LineHeight: Integer;
    function GetData: String; override;
    procedure SetData(const AValue: String); override; 
    function GetMidLine: Integer; override;
  protected
    function CalcHeight: Integer; override;
    function CalcWidth: Integer; override;
    procedure RefreshDimensions; override;
    procedure RefreshEA(AEditArea: TEditArea);
    procedure RefreshEditArea(AEditAreaIndex: Integer = 0); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;

  TEqVector = class(TEqParent)
  private
    ArrowHeight, LineHeight: Integer;
    FAlignEA: TAlignEA;
    FKindArrow: TKindArrow;

    function GetMidLine: Integer; override;
    procedure SetKindArrow(Value: TKindArrow);
    procedure SetAlignEA(const Value: TAlignEA);
  protected
    function CalcHeight: Integer; override;
    function CalcWidth: Integer; override;
    procedure RefreshDimensions; override;
    procedure RefreshEditArea(AEditAreaIndex: Integer = 0); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    property AlignEA: TAlignEA read FAlignEA write SetAlignEA;
    property KindArrow: TKindArrow read FKindArrow write SetKindArrow;
  end;

  TEqMatrix = class(TEqParent)
  private
    FCountEA: Integer;
    FKindMatrix: TKindMatrix;
    procedure SetData(const AValue: String); override;
    function GetData: String; override;
    function GetDX: Integer;
    function GetDY: Integer;
    function GetColWidth(ACol: Integer): Integer;
    function GetRowHeight(ARow: Integer): Integer;
    function GetMidLine: Integer; override;
    procedure SetKindMatrix(const Value: TKindMatrix);
    procedure SetCountEA(const Value: Integer);
  protected
    function CalcHeight: Integer; override;
    function CalcWidth: Integer; override;
    procedure RefreshDimensions; override;
    procedure RefreshEA(AEditArea: TEditArea);
    procedure RefreshEditArea(AEditAreaIndex: Integer = 0); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    property CountEA: Integer read FCountEA write SetCountEA;
    property KindMatrix: TKindMatrix read FKindMatrix write SetKindMatrix;
  end;
procedure Register;


implementation

uses Types;


procedure Register;
begin
  RegisterComponents('QDS Equations', [TQDSEquation]);
end;


{
******************************** TEquationList *********************************
}
function TEquationList.GetItem(Index: Integer): TEquation;
begin
  Result := TEquation(inherited Objects[Index]);
end;

procedure TEquationList.PutItem(Index: Integer; AValue: TEquation);
begin
  inherited Objects[Index] := AValue;
end;


{
******************************** TEditAreaList *********************************
}
function TEditAreaList.GetItem(Index: Integer): TEditArea;
begin
  Result := TEditArea(inherited Items[Index]);
end;

procedure TEditAreaList.SetItem(Index: Integer; AValue: TEditArea);
begin
  inherited Items[Index] := AValue;
end;

{
********************************* TQDSGraphic **********************************
}
constructor TQDSGraphic.Create(AOwner: TComponent);
begin
  inherited;
end;

function TQDSGraphic.GetExprData(const ExprData: String): TExprArray;
var
  i, ExprCount: Integer;

  function StandOnLetter: Boolean;
  begin
    while (not(AnsiChar(ExprData[i]) in ['a'..'z', 'A'..'Z']))and(i<Length(ExprData)) do Inc(i);
    Result:=(AnsiChar(ExprData[i]) in ['a'..'z', 'A'..'Z']);
  end;
  function GetNextClass: String;
  begin
    Result:='';
    while (AnsiChar(ExprData[i]) in ['a'..'z', 'A'..'Z']) do begin
      Result:=Result+ExprData[i];
      Inc(i);
    end;
    Result:=Trim(Result);
  end;
  function StandOnBracket: Integer;
  begin
    Result:=0;
    while (not(AnsiChar(ExprData[i]) in ['(', ')']))and(i<Length(ExprData)) do Inc(i);
    if ExprData[i]='(' then Result:=1;
    if ExprData[i]=')' then Result:=-1;
  end;
  function GetNextExpr: String;
  var BracketsCount, ExprBegin, ExprEnd: Integer;
  begin
    Result:='';
    BracketsCount:=StandOnBracket;
    ExprBegin:=Succ(i);
    while BracketsCount<>0 do begin
      Inc(i);
      Inc(BracketsCount, StandOnBracket);
    end;
    ExprEnd:=i;
    Result:=Trim(Copy(ExprData, ExprBegin, ExprEnd-ExprBegin));
  end;

begin
  ExprCount:=0;
  SetLength(Result, ExprCount);
  i:=1;
  if Length(ExprData)>0 then while StandOnLetter do begin
    Inc(ExprCount);
    SetLength(Result, ExprCount);
    Result[ExprCount-1].ClassName:=GetNextClass;
    Result[ExprCount-1].ExprData:=GetNextExpr;
  end;
end;


procedure TQDSGraphic.SetBkColor(AValue: TColor);
begin
  FBkColor := AValue;
  Repaint;
end;

{
********************************* TEquatStore **********************************
}
procedure TEquatStore.BeginUpdate;
begin
  if FUpdateCount = 0 then SetUpdateState(True);
  Inc(FUpdateCount);
end;

procedure TEquatStore.DeleteEditArea;
begin
end;

procedure TEquatStore.EditAreaDown;
begin
end;

procedure TEquatStore.EditAreaUp;
begin
end;

procedure TEquatStore.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then SetUpdateState(False);
end;

procedure TEquatStore.InsertEditArea;
begin
end;

procedure TEquatStore.RefreshEditArea(AEditAreaIndex: Integer = 0);
begin
end;

procedure TEquatStore.SetEditAreaIndex(AValue: Integer);
begin
  if (AValue<>FEditAreaIndex)and(AValue>=0)and(AValue<FEditAreaList.Count) then
    FEditAreaIndex := AValue;
end;

procedure TEquatStore.SetEditAreaList(AValue: TEditAreaList);
begin
  FEditAreaList := AValue;
end;


{
********************************* TQDSEquation *********************************
}
constructor TQDSEquation.Create(AOwner: TComponent);
begin
  inherited;
  Height:=400;
  Width:=600;
  FEditAreaIndex:=0;
  FBkColor:=clWhite;
  FLevel:=0;
  Kp:=1;
  FEditAreaList:=TEditAreaList.Create;
  Font.Name:='Times New Roman';
  Font.Charset:=Russian_Charset;
  Font.Color:=clBlack;
  Font.OnChange := FontChanged;
  InsertEditArea;
  Font.Size:=20;
  {$IfDef DEMO}
  FVersion:='1.0.0.0 Demo';
  MessageBox(Application.Handle, 'This is demo version of component. Please, visit site http://qdsequations.com for more information.', 'Qds Equations', 48);
  {$Else}
  FVersion:='1.0.0.0 ';
  {$EndIf}
end;

destructor TQDSEquation.Destroy;
begin
  FEditAreaList.Free;
  inherited Destroy;
end;

procedure TQDSEquation.AddEditArea;
var
  AEditAreaIndex: Integer;
begin
  AEditAreaIndex:=FEditAreaIndex+1;
  FEditAreaList.Insert(AEditAreaIndex, TEditArea.Create(Self));
  FEditAreaList.Items[AEditAreaIndex].Parent:=Self;
  FEditAreaList.Items[AEditAreaIndex].MainArea:=Self;
  FEditAreaList.Items[AEditAreaIndex].Font:=Font;
  FEditAreaList.Items[AEditAreaIndex].Font.Size:=Round(Font.Size*Kp);
  FEditAreaList.Items[AEditAreaIndex].Index:=AEditAreaIndex;
  FEditAreaList.Items[AEditAreaIndex].RefreshDimensions;
  EditAreaIndex:=AEditAreaIndex;
  RefreshEditArea(FEditAreaIndex);
  FEditAreaList.Items[FEditAreaIndex].Active:=True;
  Change;
end;

function TQDSEquation.CalcHeight(AIndex: Integer): Integer;
var
  i: Integer;
begin
  Result:=Font.Size;
  for i:=0 to AIndex-1 do
    Inc(Result, FEditAreaList.Items[i].Height+Font.Size);
end;

function TQDSEquation.CalcWidth: Integer;
var
  i: Integer;
begin
  Result:=0;
  for i:=0 to FEditAreaList.Count-1 do
    if FEditAreaList.Items[i].Width>Result then
      Result:=FEditAreaList.Items[i].Width;
end;

procedure TQDSEquation.Change;
begin
  inherited Changed;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TQDSEquation.DeleteEditArea;
begin
  if FEditAreaList.Count>1 then FEditAreaList.Delete(FEditAreaIndex);
  if FEditAreaIndex>=FEditAreaList.Count then Dec(FEditAreaIndex);
  RefreshEditArea(FEditAreaIndex);
  FEditAreaList.Items[FEditAreaIndex].Active:=True;
  Change;
end;

procedure TQDSEquation.EditAreaDown;
begin
  EditAreaIndex:=EditAreaIndex+1;
  FEditAreaList.Items[FEditAreaIndex].Active:=True;
end;

procedure TQDSEquation.EditAreaUp;
begin
  EditAreaIndex:=EditAreaIndex-1;
  FEditAreaList.Items[FEditAreaIndex].Active:=True;
end;

procedure TQDSEquation.FontChanged(Sender: TObject);
begin
  RefreshEditArea;
end;

function TQDSEquation.GetData: String;
var
  i: Integer;
begin
  Result:='';
  for i:=0 to FEditAreaList.Count-1 do begin
    Result:=Format('%sEditArea(%s)',[Result, FEditAreaList.Items[i].Data]);
  end;
end;

procedure TQDSEquation.InsertEditArea;
begin
  FEditAreaList.Insert(FEditAreaIndex, TEditArea.Create(Self));
  FEditAreaList.Items[FEditAreaIndex].Parent:=Self;
  FEditAreaList.Items[FEditAreaIndex].MainArea:=Self;
  FEditAreaList.Items[FEditAreaIndex].Font:=Font;
  FEditAreaList.Items[FEditAreaIndex].Font.Size:=Round(Font.Size*Kp);
  FEditAreaList.Items[FEditAreaIndex].Index:=FEditAreaIndex;
  FEditAreaList.Items[FEditAreaIndex].RefreshDimensions;
  RefreshEditArea(FEditAreaIndex);
  FEditAreaList.Items[FEditAreaIndex].Active:=True;
  Change;
end;

procedure TQDSEquation.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Assigned(ActiveEditArea) then case Key of
    VK_UP:
      ActiveEditArea.Parent.EditAreaUp;
    VK_DOWN:
      ActiveEditArea.Parent.EditAreaDown;
    VK_DELETE: begin
      if ActiveEditArea.IsEmpty then ActiveEditArea.Parent.DeleteEditArea else
      ActiveEditArea.DelEquation(ActiveEditArea.EquationIndex);
    end;
    VK_BACK: begin
      if ActiveEditArea.EquationIndex=0 then begin
        if EditAreaIndex>0 then begin
          EditAreaIndex:=EditAreaIndex-1;
          DeleteEditArea;
        end;
      end else if not ActiveEditArea.IsEmpty then begin
        ActiveEditArea.EquationIndex:=ActiveEditArea.EquationIndex-1;
        ActiveEditArea.DelEquation(ActiveEditArea.EquationIndex);
      end;
    end;
    VK_RETURN: begin
      if ActiveEditArea.EquationIndex=0 then InsertEditArea
      else AddEditArea;
    end;
    VK_HOME:
      ActiveEditArea.EquationIndex:=0;
    VK_END:
      ActiveEditArea.EquationIndex:=ActiveEditArea.EquationList.Count;
    VK_LEFT:
      ActiveEditArea.EquationIndex:=ActiveEditArea.EquationIndex-1;
    VK_RIGHT:
      ActiveEditArea.EquationIndex:=ActiveEditArea.EquationIndex+1;

    VK_NUMPAD0..VK_NUMPAD9, 48..90, 166..228, VK_MULTIPLY, VK_ADD,
    VK_SEPARATOR, VK_SUBTRACT, VK_DECIMAL, VK_DIVIDE: begin
      ActiveEditArea.AddEqSimple(GetCharFromVirtualKey(Key)[1]);
      ActiveEditArea.EquationIndex:=ActiveEditArea.EquationIndex+1;
    end;
    //else ShowMessage(IntToStr(Key));
  end;
  inherited KeyDown(Key, Shift);
end;

procedure TQDSEquation.Paint;
{$IfDef DEMO}
var
  demo: string;
{$EndIf}
begin
  Canvas.Pen.Style := psInsideFrame;
  Canvas.Pen.Color:=clBlack;
  Canvas.Brush.Style := bsClear;
  Canvas.Brush.Color := FBkColor;
  Canvas.Rectangle(0, 0, Width, Height);

{$IfDef DEMO}
  demo:='DEMO VERSION, VISIT http://qdsequations.com';
  Canvas.TextOut(3,2,demo);
  Canvas.TextOut(3,Height-Canvas.TextHeight('demo')-2, demo);
{$EndIf}
end;

procedure TQDSEquation.RefreshEditArea(AEditAreaIndex: Integer = 0);
var
  i: Integer;
begin
  for i:=AEditAreaIndex to FEditAreaList.Count-1 do begin
    FEditAreaList.Items[i].Left:=Font.Size div 2;
    FEditAreaList.Items[i].Top:=CalcHeight(i);
    FEditAreaList.Items[i].Font.Assign(Font);
    FEditAreaList.Items[i].Font.Size:=Round(Font.Size*Kp);
    FEditAreaList.Items[i].RefreshDimensions;

    FEditAreaList.Items[i].Index:=i;
    FEditAreaList.Items[i].BkColor:=BkColor;
  end;
end;

procedure TQDSEquation.RefreshDimensions;
begin
end;

procedure TQDSEquation.SetBkColor(AValue: TColor);
var
  i: Integer;
begin
  FBkColor := AValue;
  for i:=0 to FEditAreaList.Count-1 do begin
    FEditAreaList.Items[i].BkColor:=FBkColor;
  end;
  Repaint;
end;

procedure TQDSEquation.SetData(const AValue: string);
var
  i: Integer;
  ExprArray: TExprArray;
begin
  FEditAreaList.Clear;
  FEditAreaIndex:=0;
  ExprArray:=GetExprData(AValue);
  for i:=0 to Length(ExprArray)-1 do begin
    if ExprArray[i].ClassName = 'EditArea' then begin
      if FEditAreaList.Count>0 then AddEditArea else InsertEditArea;
      FEditAreaList.Items[i].Data:=ExprArray[i].ExprData;
      //EditAreaIndex:=EditAreaIndex+1;
    end;
  end;
end;

procedure TQDSEquation.SetUpdateState(Updating: Boolean);
begin
  if not Updating then Change;
end;

procedure TQDSEquation.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result:=DLGC_WANTARROWS;
end;

procedure TQDSEquation.WMLButtonDown(var Message: TWMLButtonDown);
begin
  SetFocus;
end;

{
********************************** TEACursor ***********************************
}
constructor TEACursor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Timer:=TTimer.Create(Self);
  Timer.Interval:=500;
  Timer.OnTimer:=Time;
end;

destructor TEACursor.Destroy;
begin
  Timer.Free;
  inherited Destroy;
end;

function TEACursor.GetParent: TEditArea;
begin
  Result := TEditArea(inherited Parent);
end;

procedure TEACursor.Paint;
begin
  Canvas.Pen.Style := psSolid;
  Canvas.Brush.Style := bsClear;
  Canvas.Brush.Color := clBlack;
  Canvas.Rectangle(0, 0, Width, Height);
end;

procedure TEACursor.PutParent(AValue: TEditArea);
begin
  inherited Parent := AValue;
end;

procedure TEACursor.RefreshDimensions;
begin
  Width:=2;
  Height:=Font.Size;
  RefreshVisible;
end;

procedure TEACursor.RefreshVisible;
begin
  Visible:= not Visible and FComVisible and Parent.MainArea.Enabled;       
end;

procedure TEACursor.SetComVisible(Value: Boolean);
begin
  Timer.Enabled:=Value;
  FComVisible:=Value;
  RefreshVisible;
end;

procedure TEACursor.Time(Sender: TObject);
begin
  RefreshVisible;
end;

{
********************************** TEditArea ***********************************
}
constructor TEditArea.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEquationList:=TEquationList.Create;
  FEquationIndex:=0;
  FBkColor:=clWhite;

  FCursor:=TEACursor.Create(Self);
  FCursor.Parent:=Self;
end;

destructor TEditArea.Destroy;
begin
  FCursor.Free;
  FEquationList.Free;
  if Active then MainArea.ActiveEditArea:=nil;
  inherited Destroy;
end;

procedure TEditArea.AddEqBrackets(kb: TKindBracket);
var TempStr: String;
begin
  TempStr:='Brackets';
  case kb of
    kbRound:   TempStr:=TempStr+'Round';
    kbSquare:  TempStr:=TempStr+'Square';
    kbFigure:  TempStr:=TempStr+'Figure';
    kbCorner:  TempStr:=TempStr+'Corner';
    kbModule:  TempStr:=TempStr+'Module';
    kbDModule: TempStr:=TempStr+'DModule';
  end;
  FEquationList.InsertObject(FEquationIndex, TempStr, TEqBrackets.Create(Self));
  (FEquationList.Items[FEquationIndex] as TEqBrackets).KindBracket:=kb;
  RefreshRecurse;
  MainArea.Change;
end;

procedure TEditArea.AddEqExtSymbol(SymbolCode: Integer);
begin
  FEquationList.InsertObject(FEquationIndex, 'ExtSymbol', TEqExtSymbol.Create(Self));
  (FEquationList.Items[FEquationIndex] as TEqExtSymbol).Symbol:=WideChar(SymbolCode);
  RefreshRecurse;
  MainArea.Change;
end;

procedure TEditArea.AddEqIndex(go: TGroupOptions);
var TempStr: String;
begin
  TempStr:='Index';
  if goIndexTop in go then TempStr:=TempStr+'Top';
  if goIndexBottom in go then TempStr:=TempStr+'Bottom';
  FEquationList.InsertObject(FEquationIndex, TempStr, TEqIndex.Create(Self));
  (FEquationList.Items[FEquationIndex] as TEqIndex).GroupOptions:=go;
  RefreshRecurse;
  MainArea.Change;
end;

procedure TEditArea.AddEqIntegral(go: TGroupOptions; Size: Integer; Ring: Boolean);
var TempStr: String;
begin
  TempStr:='Int';
  if go=[goLimitBottom] then TempStr:=TempStr+'LimitBottom';
  if go=[goIndexBottom] then TempStr:=TempStr+'IndexBottom';
  if go=[goLimitBottom, goLimitTop] then TempStr:=TempStr+'LimitBottomTop';
  if go=[goIndexBottom, goIndexTop] then TempStr:=TempStr+'IndexBottomTop';

  case Size of
    1: TempStr:=TempStr+'One';
    2: TempStr:=TempStr+'Two';
    3: TempStr:=TempStr+'Three';
  end;

  if Ring then TempStr:=TempStr+'Ring';

  FEquationList.InsertObject(FEquationIndex, TempStr, TEqIntegral.Create(Self));

  (FEquationList.Items[FEquationIndex] as TEqIntegral).Ring:=Ring;
  (FEquationList.Items[FEquationIndex] as TEqIntegral).Size:=Size;
  (FEquationList.Items[FEquationIndex] as TEqIntegral).GroupOptions:=go;

  RefreshRecurse;
  MainArea.Change;
end;

procedure TEditArea.AddEqVector(ka: TKindArrow; ae: TAlignEA);
var TempStr: String;
begin
  TempStr:='Vector';
  if kaRight in ka then TempStr:=TempStr+'kaRight';
  if kaLeft in ka then TempStr:=TempStr+'kaLeft';
  if kaDouble in ka then TempStr:=TempStr+'kaDouble';
  case ae of
    aeTop:    TempStr:=TempStr+'aeTop';
    aeBottom: TempStr:=TempStr+'aeBottom';
  end;
  FEquationList.InsertObject(FEquationIndex, TempStr, TEqVector.Create(Self));
  (FEquationList.Items[FEquationIndex] as TEqVector).AlignEA:=ae;
  (FEquationList.Items[FEquationIndex] as TEqVector).KindArrow:=ka;
  RefreshRecurse;
  MainArea.Change;
end;

procedure TEditArea.AddEqSimple(Ch: Char);
begin
  FEquationList.InsertObject(FEquationIndex, 'Simple', TEqSimple.Create(Self));
  (FEquationList.Items[FEquationIndex] as TEqSimple).Ch:=Ch;
  RefreshRecurse;
  MainArea.Change;
end;

procedure TEditArea.AddEqSumma(go: TGroupOptions);
var TempStr: String;
begin
  TempStr:='Sum';
  if go=[goLimitBottom] then TempStr:=TempStr+'LimitBottom';
  if go=[goIndexBottom] then TempStr:=TempStr+'IndexBottom';
  if go=[goLimitBottom, goLimitTop] then TempStr:=TempStr+'LimitBottomTop';
  if go=[goIndexBottom, goIndexTop] then TempStr:=TempStr+'IndexBottomTop';


  FEquationList.InsertObject(FEquationIndex, TempStr, TEqSumma.Create(Self));
  (FEquationList.Items[FEquationIndex] as TEqSumma).GroupOptions:=go;

  RefreshRecurse;
  MainArea.Change;
end;

procedure TEditArea.AddEqMultiply(go: TGroupOptions);
var TempStr: String;
begin
  TempStr:='Multiply';
  if go=[goLimitBottom] then TempStr:=TempStr+'LimitBottom';
  if go=[goIndexBottom] then TempStr:=TempStr+'IndexBottom';
  if go=[goLimitBottom, goLimitTop] then TempStr:=TempStr+'LimitBottomTop';
  if go=[goIndexBottom, goIndexTop] then TempStr:=TempStr+'IndexBottomTop';


  FEquationList.InsertObject(FEquationIndex, TempStr, TEqMultiply.Create(Self));
  (FEquationList.Items[FEquationIndex] as TEqMultiply).GroupOptions:=go;

  RefreshRecurse;
  MainArea.Change;
end;

procedure TEditArea.AddEqIntersection(go: TGroupOptions);
var TempStr: String;
begin
  TempStr:='Intersection';
  if go=[goLimitBottom] then TempStr:=TempStr+'LimitBottom';
  if go=[goIndexBottom] then TempStr:=TempStr+'IndexBottom';
  if go=[goLimitBottom, goLimitTop] then TempStr:=TempStr+'LimitBottomTop';
  if go=[goIndexBottom, goIndexTop] then TempStr:=TempStr+'IndexBottomTop';
  FEquationList.InsertObject(FEquationIndex, TempStr, TEqIntersection.Create(Self));
  (FEquationList.Items[FEquationIndex] as TEqIntersection).GroupOptions:=go;
  RefreshRecurse;
  MainArea.Change;
end;

procedure TEditArea.AddEqJoin(go: TGroupOptions);
var TempStr: String;
begin
  TempStr:='Join';
  if go=[goLimitBottom] then TempStr:=TempStr+'LimitBottom';
  if go=[goIndexBottom] then TempStr:=TempStr+'IndexBottom';
  if go=[goLimitBottom, goLimitTop] then TempStr:=TempStr+'LimitBottomTop';
  if go=[goIndexBottom, goIndexTop] then TempStr:=TempStr+'IndexBottomTop';
  FEquationList.InsertObject(FEquationIndex, TempStr, TEqJoin.Create(Self));
  (FEquationList.Items[FEquationIndex] as TEqJoin).GroupOptions:=go;
  RefreshRecurse;
  MainArea.Change;
end;

procedure TEditArea.AddEqCoMult(go: TGroupOptions);
var TempStr: String;
begin
  TempStr:='CoMult';
  if go=[goLimitBottom] then TempStr:=TempStr+'LimitBottom';
  if go=[goIndexBottom] then TempStr:=TempStr+'IndexBottom';
  if go=[goLimitBottom, goLimitTop] then TempStr:=TempStr+'LimitBottomTop';
  if go=[goIndexBottom, goIndexTop] then TempStr:=TempStr+'IndexBottomTop';
  FEquationList.InsertObject(FEquationIndex, TempStr, TEqCoMult.Create(Self));
  (FEquationList.Items[FEquationIndex] as TEqCoMult).GroupOptions:=go;
  RefreshRecurse;
  MainArea.Change;
end;

procedure TEditArea.AddEqArrow(ka: TKindArrow; ae: TAlignEA);
var TempStr: String;
begin
  TempStr:='Arrow';
  if kaRight in ka then TempStr:=TempStr+'kaRight';
  if kaLeft in ka then TempStr:=TempStr+'kaLeft';
  case ae of
    aeTop:    TempStr:=TempStr+'aeTop';
    aeBottom: TempStr:=TempStr+'aeBottom';
  end;
  FEquationList.InsertObject(FEquationIndex, TempStr, TEqArrow.Create(Self));
  (FEquationList.Items[FEquationIndex] as TEqArrow).AlignEA:=ae;
  (FEquationList.Items[FEquationIndex] as TEqArrow).KindArrow:=ka;

  RefreshRecurse;
  MainArea.Change;
end;

procedure TEditArea.AddEqSquare;
begin
  FEquationList.InsertObject(FEquationIndex, 'Square', TEqSquare.Create(Self));
  RefreshRecurse;
  MainArea.Change;
end;

procedure TEditArea.AddEqDivision;
begin
  FEquationList.InsertObject(FEquationIndex, 'Division', TEqDivision.Create(Self));
  RefreshRecurse;
  MainArea.Change;
end;

procedure TEditArea.AddEqMatrix(km: TKindMatrix; CountEA: Integer);
var TempStr: String;
begin                  
  TempStr:='Matrix';
  case km of
    kmHoriz:    TempStr:=TempStr+'kmHoriz';
    kmVert: TempStr:=TempStr+'kmVert';
    kmSquare: TempStr:=TempStr+'kmSquare';
  end;

  FEquationList.InsertObject(FEquationIndex, TempStr, TEqMatrix.Create(Self));
  (FEquationList.Items[FEquationIndex] as TEqMatrix).KindMatrix:=km;
  (FEquationList.Items[FEquationIndex] as TEqMatrix).CountEA:=CountEA;
  RefreshRecurse;
  MainArea.Change;
end;


function TEditArea.CalcHeight: Integer;
var
  i, SumHeight: Integer;
begin
  Result:=FCursor.Height;
  for i:=0 to EquationList.Count-1 do begin
    SumHeight:=5+Round(EquationList.Items[i].CalcHeight+
      Abs(EquationList.Items[i].CalcHeight/2-EquationList.Items[i].MidLine));
    if Result<SumHeight then
      Result:=SumHeight;
  end;
end;

function TEditArea.CalcWidth(AIndex: Integer): Integer;
var
  i: Integer;
begin
  Result:=0;
  for i:=0 to AIndex-1 do begin
    Result:=Result+FCursor.Width+EquationList.Items[i].CalcWidth;
  end;
end;

procedure TEditArea.DelEquation(AEquationIndex: Integer);
begin
  if (AEquationIndex>=0)and(AEquationIndex<EquationList.Count) then begin
    EquationList.Items[AEquationIndex].Free;
    EquationList.Delete(AEquationIndex);
    RefreshRecurse;
  end;
  MainArea.Change;
end;

function TEditArea.GetData: string;
var
  i: Integer;
begin
  Result:='';
  for i:=0 to FEquationList.Count-1 do begin
    Result:=Format('%s%s(%s)',[Result, FEquationList.Strings[i],FEquationList.Items[i].Data]);
  end;
end;

function TEditArea.GetIsEmpty: Boolean;
begin
  Result:=FEquationList.Count=0;
end;

function TEditArea.GetParent: TEquatStore;
begin
  Result := TEquatStore(inherited Parent);
end;

procedure TEditArea.OnActive;
begin
  if Assigned(MainArea.ActiveEditArea) then if MainArea.ActiveEditArea<>Self then
    MainArea.ActiveEditArea.Active:=False;
  MainArea.ActiveEditArea:=Self;
  Parent.EditAreaIndex:=Index;
  Repaint;
  FCursor.ComVisible:=True;
end;

procedure TEditArea.OnDeactive;
begin
  Repaint;
  FCursor.ComVisible:=False;
end;

procedure TEditArea.Paint;
begin
  if MainArea.Enabled and (FActive or GetIsEmpty) then begin
    Canvas.Pen.Color := clBlack;
    Canvas.Pen.Style := psDot;
  end else begin
    Canvas.Pen.Color := FBkColor;
    Canvas.Pen.Style := psSolid;
  end;
  Canvas.Brush.Style := bsClear;
  Canvas.Brush.Color := FBkColor;
  Canvas.Rectangle(0, 0, Width, Height);
end;

procedure TEditArea.PutParent(AValue: TEquatStore);
begin
  inherited Parent := AValue;
end;

procedure TEditArea.RefreshCursor;
begin
  FCursor.Font:=Font;
  FCursor.RefreshDimensions;
  FCursor.Top:=Round((Height-FCursor.Height)/2);
  FCursor.Left:=CalcWidth(FEquationIndex);
end;

procedure TEditArea.RefreshDimensions;
begin
  Height:=CalcHeight+2;
  if IsEmpty then begin
    Width:=Font.Size;
  end else begin
    Width:=CalcWidth(EquationList.Count)+Font.Size div 3;
    RefreshEquations;
  end;
  RefreshCursor;
end;

procedure TEditArea.RefreshEquations;
var
  i: Integer;
begin
  for i:=0 to FEquationList.Count-1 do begin
    FEquationList.Items[i].Index:=i;
    FEquationList.Items[i].Font:=Font;
    FEquationList.Items[i].BkColor:=FBkColor;
    FEquationList.Items[i].RefreshDimensions;
    FEquationList.Items[i].Level:=Parent.Level+1;
    FEquationList.Items[i].Left:=CalcWidth(i)+FCursor.Width;

    FEquationList.Items[i].Top:=Round(Height/2-FEquationList.Items[i].MidLine);
  end;
end;

procedure TEditArea.RefreshRecurse;
begin
  Parent.RefreshEditArea(Index);
  if Parent.ClassName<>'TQDSEquation' then begin
    (Parent as TEquation).Parent.RefreshRecurse;
  end;
end;

procedure TEditArea.SetActive(AValue: Boolean);
begin
  FActive := AValue;
  if AValue then OnActive
  else OnDeactive;
end;

procedure TEditArea.SetBkColor(AValue: TColor);
var
  i: Integer;
begin
  FBkColor := AValue;
  for i:=0 to FEquationList.Count-1 do begin
    FEquationList.Items[i].BkColor:=FBkColor;
    FEquationList.Items[i].RefreshDimensions;
  end;
  Repaint;
end;

procedure TEditArea.SetData(const AValue: string);
var
  i: Integer;
  ExprArray: TExprArray;
begin
  for i:=0 to FEquationList.Count-1 do FEquationList.Items[i].Free;
  FEquationList.Clear;
  FEquationIndex:=0;
  ExprArray:=GetExprData(AValue);
  for i:=0 to Length(ExprArray)-1 do begin
    if ExprArray[i].ClassName = 'Simple' then begin
      AddEqSimple(ExprArray[i].ExprData[1]);
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'ExtSymbol' then begin
      AddEqExtSymbol(StrToInt(ExprArray[i].ExprData));
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IndexTop' then begin
      AddEqIndex([goIndexTop]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IndexBottom' then begin
      AddEqIndex([goIndexBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IndexTopBottom' then begin
      AddEqIndex([goIndexTop, goIndexBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'BracketsRound' then begin
      AddEqBrackets(kbRound);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'BracketsSquare' then begin
      AddEqBrackets(kbSquare);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'BracketsFigure' then begin
      AddEqBrackets(kbFigure);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'BracketsCorner' then begin
      AddEqBrackets(kbCorner);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'BracketsModule' then begin
      AddEqBrackets(kbModule);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'BracketsDModule' then begin
      AddEqBrackets(kbDModule);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntOne' then begin
      AddEqIntegral([], 1, False);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntLimitBottomTopOne' then begin
      AddEqIntegral([goLimitTop, goLimitBottom], 1, False);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntIndexBottomTopOne' then begin
      AddEqIntegral([goIndexTop, goIndexBottom], 1, False);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntLimitBottomOne' then begin
      AddEqIntegral([goLimitBottom], 1, False);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntIndexBottomOne' then begin
      AddEqIntegral([goIndexBottom], 1, False);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntTwo' then begin
      AddEqIntegral([], 2, False);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntLimitBottomTwo' then begin
      AddEqIntegral([goLimitBottom], 2, False);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntIndexBottomTwo' then begin
      AddEqIntegral([goIndexBottom], 2, False);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntThree' then begin
      AddEqIntegral([], 3, False);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntLimitBottomThree' then begin
      AddEqIntegral([goLimitBottom], 3, False);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntIndexBottomThree' then begin
      AddEqIntegral([goIndexBottom], 3, False);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntOneRing' then begin
      AddEqIntegral([], 1, True);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntLimitBottomOneRing' then begin
      AddEqIntegral([goLimitBottom], 1, True);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntIndexBottomOneRing' then begin
      AddEqIntegral([goIndexBottom], 1, True);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntTwoRing' then begin
      AddEqIntegral([], 2, True);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntLimitBottomTwoRing' then begin
      AddEqIntegral([goLimitBottom], 2, True);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntIndexBottomTwoRing' then begin
      AddEqIntegral([goIndexBottom], 2, True);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntThreeRing' then begin
      AddEqIntegral([], 3, True);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntLimitBottomThreeRing' then begin
      AddEqIntegral([goLimitBottom], 3, True);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntIndexBottomThreeRing' then begin
      AddEqIntegral([goIndexBottom], 3, True);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'Sum' then begin
      AddEqSumma([]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'SumLimitBottom' then begin
      AddEqSumma([goLimitBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'SumLimitBottomTop' then begin
      AddEqSumma([goLimitTop, goLimitBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'SumIndexBottom' then begin
      AddEqSumma([goIndexBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'SumIndexBottomTop' then begin
      AddEqSumma([goIndexTop, goIndexBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'Multiply' then begin
      AddEqMultiply([]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'MultiplyLimitBottom' then begin
      AddEqMultiply([goLimitBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'MultiplyLimitBottomTop' then begin
      AddEqMultiply([goLimitTop, goLimitBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'MultiplyIndexBottom' then begin
      AddEqMultiply([goIndexBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'MultiplyBottomTop' then begin
      AddEqMultiply([goIndexTop, goIndexBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'CoMult' then begin
      AddEqCoMult([]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'CoMultLimitBottom' then begin
      AddEqCoMult([goLimitBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'CoMultLimitBottomTop' then begin
      AddEqCoMult([goLimitTop, goLimitBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'CoMultIndexBottom' then begin
      AddEqCoMult([goIndexBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'CoMultBottomTop' then begin
      AddEqCoMult([goIndexTop, goIndexBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'Intersection' then begin
      AddEqIntersection([]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntersectionLimitBottom' then begin
      AddEqIntersection([goLimitBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntersectionLimitBottomTop' then begin
      AddEqIntersection([goLimitTop, goLimitBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntersectionIndexBottom' then begin
      AddEqIntersection([goIndexBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'IntersectionBottomTop' then begin
      AddEqIntersection([goIndexTop, goIndexBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'Join' then begin
      AddEqJoin([]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'JoinLimitBottom' then begin
      AddEqJoin([goLimitBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'JoinLimitBottomTop' then begin
      AddEqJoin([goLimitTop, goLimitBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'JoinIndexBottom' then begin
      AddEqJoin([goIndexBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'JoinBottomTop' then begin
      AddEqJoin([goIndexTop, goIndexBottom]);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;

    if ExprArray[i].ClassName = 'ArrowkaRightaeTop' then begin
      AddEqArrow([kaRight], aeTop);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'ArrowkaLeftaeTop' then begin
      AddEqArrow([kaLeft], aeTop);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'ArrowkaRightkaLeftaeTop' then begin
      AddEqArrow([kaRight, kaLeft], aeTop);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'ArrowkaRightaeBottom' then begin
      AddEqArrow([kaRight], aeBottom);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'ArrowkaLeftaeBottom' then begin
      AddEqArrow([kaLeft], aeBottom);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'ArrowkaRightkaLeftaeBottom' then begin
      AddEqArrow([kaRight, kaLeft], aeBottom);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'Square' then begin
      AddEqSquare;
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'Division' then begin
      AddEqDivision;
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'VectoraeBottom' then begin
      AddEqVector([], aeBottom);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'VectorkaDoubleaeBottom' then begin
      AddEqVector([kaDouble], aeBottom);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'VectoraeTop' then begin
      AddEqVector([], aeTop);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'VectorkaDoubleaeTop' then begin
      AddEqVector([kaDouble], aeTop);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'VectorkaRightaeBottom' then begin
      AddEqVector([kaRight], aeBottom);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'VectorkaLeftaeBottom' then begin
      AddEqVector([kaLeft], aeBottom);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'VectorkaRightkaLeftaeBottom' then begin
      AddEqVector([kaRight, kaLeft], aeBottom);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'VectorkaRightaeTop' then begin
      AddEqVector([kaRight], aeTop);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'VectorkaLeftaeTop' then begin
      AddEqVector([kaLeft], aeTop);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'VectorkaRightkaLeftaeTop' then begin
      AddEqVector([kaRight, kaLeft], aeTop);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'MatrixkmHoriz' then begin
      AddEqMatrix(kmHoriz, 0);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'MatrixkmVert' then begin
      AddEqMatrix(kmVert, 0);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
    if ExprArray[i].ClassName = 'MatrixkmSquare' then begin
      AddEqMatrix(kmSquare, 0);
      FEquationList.Items[FEquationIndex].Data:=ExprArray[i].ExprData;
      EquationIndex:=EquationIndex+1;
    end;
  end;
end;

procedure TEditArea.SetEquationIndex(AValue: Integer);
begin
  if (AValue>=0)and(AValue<=EquationList.Count) then FEquationIndex := AValue;
  RefreshCursor;
end;

procedure TEditArea.SetEquationList(AValue: TEquationList);
begin
  FEquationList := AValue;
end;

procedure TEditArea.WMLButtonDown(var Message: TWMLButtonDown);
begin
  MainArea.SetFocus;
  Active:=True;
end;


{
********************************** TEquation ***********************************
}
constructor TEquation.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Parent:=AOwner as TEditArea;
  Kp:=1;
end;

function TEquation.CalcHeight: Integer;
begin
  Result := 0;
end;

function TEquation.CalcWidth: Integer;
begin
  Result := 0;
end;

function TEquation.GetData: string;
begin
end;

function TEquation.GetMidLine: Integer;
begin
  Result:=Height div 2;
end;

function TEquation.GetParent: TEditArea;
begin
  Result := TEditArea(inherited Parent);
end;

procedure TEquation.Paint;
begin
end;

procedure TEquation.PutParent(AValue: TEditArea);
begin
  inherited Parent := AValue;
end;

procedure TEquation.SetCanvasFont;
begin
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Color:=BkColor;
  Canvas.Brush.Style := bsClear;
  Canvas.Brush.Color:=BkColor;
  Canvas.Font.Assign(Font);
end;

procedure TEquation.SetData(const AValue: string);
begin
end;

procedure TEquation.SetUpdateState(Updating: Boolean);
begin
  if not Updating then RefreshEditArea;
end;

procedure TEquation.WMLButtonDown(var Message: TWMLButtonDown);
begin
  Parent.WMLButtonDown(Message);
end;

{
********************************** TEqSimple ***********************************
}
function TEqSimple.CalcHeight: Integer;
begin
  SetCanvasFont;
  Result:=Canvas.TextHeight(Ch);
end;

function TEqSimple.CalcWidth: Integer;
begin
  SetCanvasFont;
  Result:=Canvas.TextWidth(Ch);
end;

function TEqSimple.GetData: string;
begin
  Result:=Ch;
end;

procedure TEqSimple.Paint;
begin
  Canvas.TextOut(0,0,Ch);
end;

procedure TEqSimple.RefreshDimensions;
begin
  Height:=CalcHeight;
  Width:=CalcWidth;
end;

{
********************************* TEqExtSymbol *********************************
}
function TEqExtSymbol.CalcHeight: Integer;
var
  Size: TSize;
begin
  SetCanvasFont;
  GetTextExtentPoint32W(Canvas.Handle,@Symbol,1,Size);
  Result:=Size.CY
end;

function TEqExtSymbol.CalcWidth: Integer;
var
  Size: TSize;
begin
  SetCanvasFont;
  GetTextExtentPoint32W(Canvas.Handle,@Symbol,1,Size);
  Result:=Size.CX;
end;

function TEqExtSymbol.GetData: string;
begin
  Result:=IntToStr(Integer(Symbol));
end;

procedure TEqExtSymbol.Paint;
begin
  TextOutW(Canvas.Handle,0,0,@Symbol,1)
end;

procedure TEqExtSymbol.RefreshDimensions;
begin
  Height:=CalcHeight;
  Width:=CalcWidth;
end;

{
********************************** TEqParent ***********************************
}
constructor TEqParent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditAreaList:=TEditAreaList.Create;
  FEditAreaIndex:=0;
end;

destructor TEqParent.Destroy;
begin
  FEditAreaList.Free;
  inherited;
end;

function TEqParent.GetData: string;
begin
  Result:=Format('EditArea(%s)',[EditAreaList.Items[0].Data]);
end;

procedure TEqParent.InsertEditArea;
begin
  FEditAreaList.Insert(FEditAreaIndex, TEditArea.Create(Self));
  FEditAreaList.Items[FEditAreaIndex].Parent:=Self;
  FEditAreaList.Items[FEditAreaIndex].MainArea:=Parent.MainArea;
  FEditAreaList.Items[FEditAreaIndex].Font:=Font;
  FEditAreaList.Items[FEditAreaIndex].Font.Size:=Round(Font.Size*Kp);
  FEditAreaList.Items[FEditAreaIndex].BkColor:=Parent.BkColor;
  FEditAreaList.Items[FEditAreaIndex].Index:=FEditAreaIndex;
  FEditAreaList.Items[FEditAreaIndex].RefreshDimensions;
  RefreshEditArea(FEditAreaIndex);
  FEditAreaList.Items[FEditAreaIndex].Active:=True;
end;

procedure TEqParent.SetBkColor(AValue: TColor);
var
  i: Integer;
begin
  FBkColor := AValue;
  for i:=0 to FEditAreaList.Count-1 do begin
    FEditAreaList.Items[i].BkColor:=FBkColor;
  end;
  Repaint;
end;

procedure TEqParent.SetData(const AValue: string);
var
  ExprArray: TExprArray;
begin
  FEditAreaIndex:=0;
  ExprArray:=GetExprData(AValue);
  if Length(ExprArray)>0 then begin
    if ExprArray[0].ClassName = 'EditArea' then begin
      FEditAreaList.Items[0].Data:=ExprArray[0].ExprData;
    end;
  end;
end;

{
********************************** TEqGroupOp **********************************
}
function TEqGroupOp.CalcHeight: Integer;
begin
  Result:=TopMargin+GetCommonHeight;
  if goIndexBottom in FGroupOptions then Result:=Result+FIndexBottom.Height div 2;
  if goLimitBottom in FGroupOptions then Result:=Result+FLimitBottom.Height;
end;                      

function TEqGroupOp.CalcSymbolHeight: Integer;
var
  Sz: TSize;
begin
  SetCanvasFont;
  GetTextExtentPoint32W(Canvas.Handle,@FSymbol,1,Sz);
  Result:=Sz.cy;
end;

function TEqGroupOp.CalcSymbolWidth: Integer;
var
  Sz: TSize;
begin
  SetCanvasFont;
  GetTextExtentPoint32W(Canvas.Handle,@FSymbol,1,Sz);
  Result:=Sz.cx*FSize+FSize;
end;

function TEqGroupOp.CalcWidth: Integer;
begin
  Result:=GetCommonWidth+FEditAreaList.Items[0].Width;
end;

constructor TEqGroupOp.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Symbol:=WideChar(0);
  FGroupOptions:=[];
  FRing:=False;
  FSize:=1;
  FEditAreaIndex:=0;
  InsertEditArea;
end;

function TEqGroupOp.GetCommonHeight: Integer;
begin
  Result:=Max(SymbolHeight,EditAreaList.Items[0].Height);
end;

function TEqGroupOp.GetCommonWidth: Integer;
var EAWidth: Integer;
begin
  Result:=SymbolWidth;
  EAWidth:=0;
  if (goLimitTop in FGroupOptions)or(goLimitBottom in FGroupOptions) then begin
    if goLimitTop in FGroupOptions then EAWidth:=Max(EAWidth, FLimitTop.Width);
    if goLimitBottom in FGroupOptions then EAWidth:=Max(EAWidth, FLimitBottom.Width);
    Result:=Max(Result, EAWidth);
  end;
  if (goIndexTop in FGroupOptions)or(goIndexBottom in FGroupOptions) then begin
    if goIndexTop in FGroupOptions then EAWidth:=Max(EAWidth, FIndexTop.Width);
    if goIndexBottom in FGroupOptions then EAWidth:=Max(EAWidth, FIndexBottom.Width);
    Result:=Result+EAWidth;
  end;
end;

function TEqGroupOp.GetMidLine: Integer;
begin
  Result:=TopMargin+CalcSymbolHeight div 2;
end;

function TEqGroupOp.GetTopMargin: Integer;
begin
  Result:=0;
  if goIndexTop in FGroupOptions then Result:=FIndexTop.Height div 2;
  if goLimitTop in FGroupOptions then Result:=FLimitTop.Height;
end;

function TEqGroupOp.GetSymbolHeight: Integer;
begin
  Result:=CalcSymbolHeight;
end;

function TEqGroupOp.GetSymbolWidth: Integer;
begin
  Result:=CalcSymbolWidth;
end;

procedure TEqGroupOp.Paint;
var
  Sz: TSize;
  SymbolLeft, SymbolTop: Integer;
  procedure DrawSymbol;
  var i: Integer;
  begin
    for i:=0 to FSize-1 do begin
      TextOutW(Canvas.Handle,SymbolLeft+(Sz.cx+1)*i,SymbolTop,@Symbol,1);
    end;
  end;
  procedure DrawRing();
  var MLine: Integer;
  begin
    MLine:=SymbolTop+SymbolHeight div 2;
    Canvas.Pen.Style:=psSolid;
    Canvas.Pen.Width:=Font.Size div 15;
    Canvas.Pen.Color:=Font.Color;
    Canvas.Brush.Style:=bsClear;
    Canvas.Ellipse(SymbolLeft,
                   MLine-Font.Size div 3,
                   SymbolLeft+Sz.cx*FSize+FSize,
                   MLine+Font.Size div 3);
  end;
begin
  SetCanvasFont;
  GetTextExtentPoint32W(Canvas.Handle,@Symbol,1,Sz);
  SymbolLeft:=0;
  if (goLimitTop in FGroupOptions)or(goLimitBottom in FGroupOptions) then
    SymbolLeft:=(GetCommonWidth-SymbolWidth) div 2;
  if (goIndexTop in FGroupOptions)or(goIndexBottom in FGroupOptions) then
    SymbolLeft:=0;
  SymbolTop:=TopMargin+(GetCommonHeight-SymbolHeight) div 2;
  Canvas.Rectangle(0, 0, Width, Height);
  DrawSymbol;
  if FRing then DrawRing;
end;

procedure TEqGroupOp.RefreshDimensions;
begin
  Height:=CalcHeight;
  Width:=CalcWidth;
end;

procedure TEqGroupOp.RefreshEA(AEditArea: TEditArea; AKp: Double);
begin
  AEditArea.BkColor:=Parent.BkColor;
  AEditArea.Font.Assign(Font);
  AEditArea.Font.Size:=Round(Font.Size*Kp*AKp);
  AEditArea.RefreshDimensions;
  AEditArea.Index:=FEditAreaList.IndexOf(AEditArea);
end;

procedure TEqGroupOp.RefreshEditArea(AEditAreaIndex: Integer = 0);
var
  CommonHeight, CommonWidth: Integer;
begin
  if FUpdateCount>0 then Exit;
  if goLimitTop in FGroupOptions then RefreshEA(FLimitTop, 0.8);
  if goLimitBottom in FGroupOptions then RefreshEA(FLimitBottom, 0.8);
  if goIndexTop in FGroupOptions then RefreshEA(FIndexTop, 0.8);
  if goIndexBottom in FGroupOptions then RefreshEA(FIndexBottom, 0.8);
  CommonWidth:=GetCommonWidth;
  RefreshEA(EditAreaList.Items[0], 1);
  CommonHeight:=GetCommonHeight;
  if goLimitTop in FGroupOptions then begin
    FLimitTop.Top:=0;
    FLimitTop.Left:=(CommonWidth-FLimitTop.Width) div 2;
  end;
  if goIndexTop in FGroupOptions then begin
    FIndexTop.Top:=0;
    FIndexTop.Left:=SymbolWidth;
  end;
  if goLimitBottom in FGroupOptions then begin
    FLimitBottom.Top:=TopMargin+CommonHeight;
    FLimitBottom.Left:=(CommonWidth-FLimitBottom.Width) div 2;
  end;
  if goIndexBottom in FGroupOptions then begin
    FIndexBottom.Top:=TopMargin+CommonHeight-FIndexBottom.Height div 2;
    FIndexBottom.Left:=SymbolWidth;
  end;
  EditAreaList.Items[0].Left:=CommonWidth;
  EditAreaList.Items[0].Top:=TopMargin+(CommonHeight-EditAreaList.Items[0].Height) div 2;
  Parent.RefreshEquations;
end;

function TEqGroupOp.GetData: string;
begin
  Result:=Format('EditArea(%s)',[EditAreaList.Items[0].Data]);
  if goLimitBottom in FGroupOptions then Result:=Result+Format('EditArea(%s)',[FLimitBottom.Data]);
  if goLimitTop in FGroupOptions then Result:=Result+Format('EditArea(%s)',[FLimitTop.Data]);
  if goIndexBottom in FGroupOptions then Result:=Result+Format('EditArea(%s)',[FIndexBottom.Data]);
  if goIndexTop in FGroupOptions then Result:=Result+Format('EditArea(%s)',[FIndexTop.Data]);
end;

procedure TEqGroupOp.SetData(const AValue: String);
var
  i: Integer;
  ExprArray: TExprArray;
begin
  ExprArray:=GetExprData(AValue);
  for i:=0 to Length(ExprArray)-1 do begin
    if ExprArray[i].ClassName = 'EditArea' then if i<FEditAreaList.Count then begin
      FEditAreaList.Items[i].Data:=ExprArray[i].ExprData;
    end;
  end;
end;

procedure TEqGroupOp.SetGroupOptions(Value: TGroupOptions);
begin
  FGroupOptions:=Value;
  BeginUpdate;
  FEditAreaIndex:=1;
  if goLimitTop in FGroupOptions then begin
    InsertEditArea;
    FLimitTop:=EditAreaList.Items[EditAreaIndex];
  end;
  if goIndexTop in FGroupOptions then begin
    InsertEditArea;
    FIndexTop:=EditAreaList.Items[EditAreaIndex];
  end;
  if goLimitBottom in FGroupOptions then begin
    InsertEditArea;
    FLimitBottom:=EditAreaList.Items[EditAreaIndex];
  end;
  if goIndexBottom in FGroupOptions then begin
    InsertEditArea;
    FIndexBottom:=EditAreaList.Items[EditAreaIndex];
  end;
  EndUpdate;
  RefreshEditArea;
end;

procedure TEqGroupOp.SetRing(ARing: Boolean);
begin
  FRing := ARing;
  Repaint;
end;

procedure TEqGroupOp.SetSize(ASize: Integer);
begin
  if ASize in [1..3] then FSize:=ASize;
  Repaint;
end;

procedure TEqGroupOp.SetSymbol(Value: WideChar);
begin
  FSymbol := Value;
  Repaint;
end;

{
********************************* TEqIntegral **********************************
}
constructor TEqIntegral.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Symbol:=WideChar(8747);
end;
{
********************************** TEqSumma ************************************
}
constructor TEqSumma.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Symbol:=WideChar(8721);
end;
{
********************************* TEqMultiply **********************************
}
constructor TEqMultiply.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Symbol:=WideChar(8719);
end;
{
******************************* TEqIntersection ********************************
}
constructor TEqIntersection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Symbol:=WideChar(8745);
end;
{
*********************************** TEqJoin ************************************
}
constructor TEqJoin.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Symbol:=WideChar(85);
end;
{
********************************** TEqCoMult ***********************************
}
constructor TEqCoMult.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Symbol:=WideChar(1062);
end;
{
*********************************** TEqIndex************************************
}
constructor TEqIndex.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Kp:=0.7;
  FGroupOptions:=[];
end;

function TEqIndex.CalcHeight: Integer;
begin
  Result:=Font.Size div 2;
  if goIndexTop in FGroupOptions then Result:=Result+FIndexTop.Height;
  if goIndexBottom in FGroupOptions then Result:=Result+FIndexBottom.Height;
end;

function TEqIndex.CalcWidth: Integer;
begin
  Result:=0;
  if goIndexTop in FGroupOptions then Result:=FIndexTop.Width;
  if goIndexBottom in FGroupOptions then Result:=Max(Result, FIndexBottom.Width);
end;

procedure TEqIndex.Paint;
begin
  SetCanvasFont;
  Canvas.Rectangle(0, 0, Width, Height);
end;

procedure TEqIndex.RefreshDimensions;
begin
  Height:=CalcHeight;
  Width:=CalcWidth;
end;

procedure TEqIndex.RefreshEA(AEditArea: TEditArea);
begin
  AEditArea.BkColor:=Parent.BkColor;
  AEditArea.Font.Assign(Font);
  AEditArea.Font.Size:=Round(Font.Size*Kp);
  AEditArea.RefreshDimensions;
  AEditArea.Index:=FEditAreaList.IndexOf(AEditArea);
end;

procedure TEqIndex.RefreshEditArea(AEditAreaIndex: Integer = 0);
begin
  if FUpdateCount>0 then Exit;
  if goIndexTop in FGroupOptions then begin
    RefreshEA(FIndexTop);
    FIndexTop.Top:=0;
    FIndexTop.Left:=0;
  end;
  if goIndexBottom in FGroupOptions then begin
    RefreshEA(FIndexBottom);
    FIndexBottom.Top:=Font.Size div 2;
    if goIndexTop in FGroupOptions then FIndexBottom.Top:=FIndexBottom.Top+FIndexTop.Height;
    FIndexBottom.Left:=0;
  end;
  Parent.RefreshEquations;
end;

procedure TEqIndex.SetGroupOptions(const Value: TGroupOptions);
begin
  FGroupOptions := Value;
  BeginUpdate;
  if goIndexTop in FGroupOptions then begin
    InsertEditArea;
    FIndexTop:=EditAreaList.Items[EditAreaIndex];
  end;
  if goIndexBottom in FGroupOptions then begin
    InsertEditArea;
    FIndexBottom:=EditAreaList.Items[EditAreaIndex];
  end;
  EndUpdate;
end;

function TEqIndex.GetData: string;
begin
  Result:='';
  if goIndexBottom in FGroupOptions then Result:=Result+Format('EditArea(%s)',[FIndexBottom.Data]);
  if goIndexTop in FGroupOptions then Result:=Result+Format('EditArea(%s)',[FIndexTop.Data]);
end;

procedure TEqIndex.SetData(const AValue: String);
var
  i: Integer;
  ExprArray: TExprArray;
begin
  ExprArray:=GetExprData(AValue);
  for i:=0 to Length(ExprArray)-1 do begin
    if ExprArray[i].ClassName = 'EditArea' then if i<FEditAreaList.Count then begin
      FEditAreaList.Items[i].Data:=ExprArray[i].ExprData;
    end;
  end;
end;
{
********************************* TEqBrackets **********************************
}
constructor TEqBrackets.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  InsertEditArea;
  RefreshEditArea;
end;

function TEqBrackets.CalcSymbolHeight: Integer;
var
  Sz: TSize;
begin
  SetCanvasFont;
  GetTextExtentPoint32W(Canvas.Handle,@FLSymbol,1,Sz);
  Result:=Sz.cy;
end;

function TEqBrackets.CalcSymbolWidth: Integer;
var
  Sz: TSize;
begin
  SetCanvasFont;
  GetTextExtentPoint32W(Canvas.Handle,@FLSymbol,1,Sz);
  Result:=Sz.cx;
end;

function TEqBrackets.CalcHeight: Integer;
begin
  SetCanvasFont;
  Result:=Max(FEditAreaList.Items[0].Height,CalcSymbolHeight);
end;

function TEqBrackets.CalcWidth: Integer;
begin
  SetCanvasFont;
  Result:=FEditAreaList.Items[0].Width+CalcSymbolWidth*2;
end;

function TEqBrackets.GetCommonHeight: Integer;
begin
  Result:=Max(CalcSymbolHeight,EditAreaList.Items[0].Height);
end;

procedure TEqBrackets.Paint;
var CommonHeight: Integer;
begin
  CommonHeight:=GetCommonHeight;
  Canvas.Rectangle(0, 0, Width, Height);
  TextOutW(Canvas.Handle,0,(CommonHeight-CalcSymbolHeight) div 2,@FLSymbol,1);
  TextOutW(Canvas.Handle,CalcSymbolWidth+FEditAreaList.Items[0].Width,
           (CommonHeight-CalcSymbolHeight) div 2,@FRSymbol,1);
end;

procedure TEqBrackets.RefreshDimensions;
begin
  Height:=CalcHeight;
  Width:=CalcWidth;
end;

procedure TEqBrackets.RefreshEditArea(AEditAreaIndex: Integer = 0);
begin
  FEditAreaList.Items[0].BkColor:=Parent.BkColor;
  FEditAreaList.Items[0].Font:=Font;
  FEditAreaList.Items[0].Font.Size:=Round(Font.Size*Kp);
  FEditAreaList.Items[0].RefreshDimensions;
  FEditAreaList.Items[0].Index:=0;
  FEditAreaList.Items[0].Left:=CalcSymbolWidth;
  FEditAreaList.Items[0].Top:=(GetCommonHeight-FEditAreaList.Items[0].Height) div 2;
  Parent.RefreshEquations;
end;

procedure TEqBrackets.SetKindBracket(AValue: TKindBracket);
begin
  FKindBracket:=AValue;
  case FKindBracket of
    kbRound: begin
      FLSymbol:=WideChar(64830);
      FRSymbol:=WideChar(64831);
    end;
    kbSquare: begin
      FLSymbol:=WideChar(91);
      FRSymbol:=WideChar(93);
    end;
    kbFigure: begin
      FLSymbol:=WideChar(123);
      FRSymbol:=WideChar(125);
    end;
    kbCorner: begin
      FLSymbol:=WideChar(8249);
      FRSymbol:=WideChar(8250);
    end;
    kbModule: begin
      FLSymbol:=WideChar(9474);
      FRSymbol:=WideChar(9474);
    end;
    kbDModule: begin
      FLSymbol:=WideChar(9553);
      FRSymbol:=WideChar(9553);
    end;
  end;
  RefreshEditArea;
end;

procedure TEqBrackets.SetLSymbol(Value: WideChar);
begin
  FLSymbol:=Value;
  Repaint;
end;

procedure TEqBrackets.SetRSymbol(Value: WideChar);
begin
  FRSymbol:=Value;
  Repaint;
end;
{
*********************************** TEqArrow ***********************************
}
function TEqArrow.CalcHeight: Integer;
begin
  Result:=FEditAreaList.Items[0].Height+ArrowHeight+7;
end;

function TEqArrow.CalcWidth: Integer;
begin
  Result:=FEditAreaList.Items[0].Width * 2;
end;

constructor TEqArrow.Create(AOwner: TComponent);
begin
  inherited;
  Kp:=0.7;
  FKindArrow:=[];
  FAlignEA:=aeTop;
  InsertEditArea;
  RefreshEditArea;
end;

function TEqArrow.GetMidLine: Integer;
begin
  Result:=Height div 2;
  case FAlignEA of
    aeTop:     Result:=FEditAreaList.Items[0].Height+3;
    aeBottom:  Result:=3;
  end;
end;

procedure TEqArrow.Paint;
var LineTop: Integer;
  procedure DrawArrow;
  begin
    Canvas.Pen.Color := Font.Color;
    Canvas.Pen.Style := psSolid;
    Canvas.Rectangle(0, LineTop, Width, LineTop+LineHeight);
    if kaRight in FKindArrow then begin
      Canvas.MoveTo(Width-15, LineTop - ArrowHeight div 2);
      Canvas.LineTo(Width, LineTop);
      Canvas.MoveTo(Width, LineTop+LineHeight div 2);
      Canvas.LineTo(Width-15, LineTop+LineHeight div 2 + ArrowHeight div 2);
    end;
    if kaLeft in FKindArrow then begin
      Canvas.MoveTo(15, LineTop - ArrowHeight div 2);
      Canvas.LineTo(0, LineTop);
      Canvas.MoveTo(0, LineTop+LineHeight div 2);
      Canvas.LineTo(15, LineTop+LineHeight div 2 + ArrowHeight div 2);
    end;
  end;
begin
  case FAlignEA of
    aeTop:     LineTop:=FEditAreaList.Items[0].Height+ArrowHeight div 2;
    aeBottom:  LineTop:=3;
  end;
  SetCanvasFont;
  Canvas.Rectangle(0, 0, Width, Height);
  DrawArrow;
end;

procedure TEqArrow.RefreshDimensions;
begin
  Height:=CalcHeight;
  Width:=CalcWidth;
  ArrowHeight:=Font.Size div 5;
  LineHeight:=Font.Size div 10;
end;

procedure TEqArrow.RefreshEditArea(AEditAreaIndex: Integer = 0);
begin
  FEditAreaList.Items[0].BkColor:=Parent.BkColor;
  FEditAreaList.Items[0].Font:=Font;
  FEditAreaList.Items[0].Font.Size:=Round(Font.Size*Kp);
  FEditAreaList.Items[0].RefreshDimensions;
  FEditAreaList.Items[0].Index:=0;
  FEditAreaList.Items[0].Left:=(CalcWidth-FEditAreaList.Items[0].Width) div 2;
  case FAlignEA of
    aeTop:     FEditAreaList.Items[0].Top:=0;
    aeBottom:  FEditAreaList.Items[0].Top:=ArrowHeight+4;
  end;
  Parent.RefreshEquations;
end;

procedure TEqArrow.SetAlignEA(const Value: TAlignEA);
begin
  FAlignEA := Value;
  RefreshEditArea;
end;

procedure TEqArrow.SetKindArrow(Value: TKindArrow);
begin
  FKindArrow:=Value;
  Repaint;
end;
{
********************************** TEqSquare ***********************************
}
function TEqSquare.CalcHeight: Integer;
begin
  Result:=FEditAreaList.Items[0].Height+LineHeight;
end;

function TEqSquare.CalcWidth: Integer;
begin
  Result:=FEditAreaList.Items[0].Width + GalkaLeft + LineHeight;
end;

constructor TEqSquare.Create(AOwner: TComponent);
begin
  inherited;
  Kp:=0.9;

  InsertEditArea;
  RefreshDimensions;
  RefreshEditArea;
end;

function TEqSquare.GetMidLine: Integer;
begin
  Result:=Height div 2 - LineHeight;
end;

procedure TEqSquare.Paint;

  procedure DrawSquare;
  begin
    Canvas.Pen.Color := Font.Color;
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Width:=LineHeight;
    Canvas.MoveTo(0, FEditAreaList.Items[0].Height div 2);
    Canvas.LineTo(GalkaLeft div 2, FEditAreaList.Items[0].Height);
    Canvas.LineTo(GalkaLeft, 0);
    Canvas.LineTo(FEditAreaList.Items[0].Width+GalkaLeft+LineHeight, 0);
  end;

begin
  SetCanvasFont;
  Canvas.Rectangle(0, 0, Width, Height);
  DrawSquare;
end;

procedure TEqSquare.RefreshDimensions;
begin
  Height:=CalcHeight;
  Width:=CalcWidth;
  GalkaLeft:=Font.Size div 2;
  LineHeight:=Font.Size div 8;
end;

procedure TEqSquare.RefreshEditArea(AEditAreaIndex: Integer = 0);
begin
  FEditAreaList.Items[0].BkColor:=Parent.BkColor;
  FEditAreaList.Items[0].Font:=Font;
  FEditAreaList.Items[0].Font.Size:=Round(Font.Size*Kp);
  FEditAreaList.Items[0].RefreshDimensions;
  FEditAreaList.Items[0].Index:=0;
  FEditAreaList.Items[0].Left:=GalkaLeft+LineHeight;//(CalcWidth-FEditAreaList.Items[0].Width) div 2;
  FEditAreaList.Items[0].Top:=LineHeight;//+Font.Size div 2;//;ArrowHeight+4;

  Parent.RefreshEquations;
end;

{
********************************* TEqDivision **********************************
}
function TEqDivision.CalcHeight: Integer;
begin
  Result:=FEditAreaList.Items[0].Height+ArrowHeight+FEditAreaList.Items[1].Height;
end;

function TEqDivision.CalcWidth: Integer;
begin
  Result:=Max(FEditAreaList.Items[0].Width, FEditAreaList.Items[1].Width);
end;

constructor TEqDivision.Create(AOwner: TComponent);
begin
  inherited;
  Kp:=0.7;
  BeginUpdate;
  InsertEditArea;
  InsertEditArea;
  EndUpdate;
  RefreshEditArea;
end;

function TEqDivision.GetMidLine: Integer;
begin
  Result:=FEditAreaList.Items[0].Height+ArrowHeight div 2;
end;

procedure TEqDivision.Paint;
var LineTop: Integer;
  procedure DrawArrow;
  begin
    Canvas.Pen.Color := Font.Color;
    Canvas.Pen.Style := psSolid;
    Canvas.Rectangle(0, LineTop, Width, LineTop+LineHeight);
  end;
begin     
  LineTop:=FEditAreaList.Items[0].Height+ArrowHeight div 2;
  SetCanvasFont;
  Canvas.Rectangle(0, 0, Width, Height);
  DrawArrow;
end;

procedure TEqDivision.RefreshDimensions;
begin
  Height:=CalcHeight;
  Width:=CalcWidth;
  ArrowHeight:=Font.Size div 5;
  LineHeight:=Font.Size div 10;
end;

procedure TEqDivision.RefreshEA(AEditArea: TEditArea);
begin
  AEditArea.BkColor:=Parent.BkColor;
  AEditArea.Font:=Font;
  AEditArea.Font.Size:=Round(Font.Size*Kp);
  AEditArea.RefreshDimensions;
  AEditArea.Left:=(CalcWidth-AEditArea.Width) div 2;
end;

procedure TEqDivision.RefreshEditArea(AEditAreaIndex: Integer = 0);
begin
  if FUpdateCount>0 then Exit;
  RefreshEA(FEditAreaList.Items[0]);
  FEditAreaList.Items[0].Top:=0;
  RefreshEA(FEditAreaList.Items[1]);
  FEditAreaList.Items[1].Top:=FEditAreaList.Items[0].Height+ArrowHeight;

  Parent.RefreshEquations;
end;

function TEqDivision.GetData: String;
begin
  Result:=Format('EditArea(%s)',[EditAreaList.Items[0].Data])+Format('EditArea(%s)',[EditAreaList.Items[1].Data]);
end;

procedure TEqDivision.SetData(const AValue: String);
var
  i: Integer;
  ExprArray: TExprArray;
begin
  ExprArray:=GetExprData(AValue);
  for i:=0 to Length(ExprArray)-1 do begin
    if ExprArray[i].ClassName = 'EditArea' then if i<FEditAreaList.Count then begin
      FEditAreaList.Items[i].Data:=ExprArray[i].ExprData;
    end;
  end;
end;

{
********************************** TEqVector ***********************************
}
function TEqVector.CalcHeight: Integer;
begin
  Result:=FEditAreaList.Items[0].Height+ArrowHeight+7;
end;

function TEqVector.CalcWidth: Integer;
begin
  Result:=FEditAreaList.Items[0].Width;
end;

constructor TEqVector.Create(AOwner: TComponent);
begin
  inherited;
  FKindArrow:=[];
  FAlignEA:=aeTop;
  InsertEditArea;
  RefreshEditArea;
end;

function TEqVector.GetMidLine: Integer;
begin
  Result:=Height div 2;
  case FAlignEA of
    aeTop:     Result:=FEditAreaList.Items[0].Height div 2;
    aeBottom:  Result:=ArrowHeight+4+FEditAreaList.Items[0].Height div 2;
  end;
end;

procedure TEqVector.Paint;
var LineTop: Integer;
  procedure DrawArrow;
  begin
    Canvas.Pen.Color := Font.Color;
    Canvas.Pen.Style := psSolid;
    Canvas.Rectangle(0, LineTop, Width, LineTop+LineHeight);
    if kaRight in FKindArrow then begin
      Canvas.MoveTo(Width-15, LineTop - ArrowHeight div 2);
      Canvas.LineTo(Width, LineTop);
      Canvas.MoveTo(Width, LineTop+LineHeight div 2);
      Canvas.LineTo(Width-15, LineTop+LineHeight div 2 + ArrowHeight div 2);
    end;
    if kaLeft in FKindArrow then begin
      Canvas.MoveTo(15, LineTop - ArrowHeight div 2);
      Canvas.LineTo(0, LineTop);
      Canvas.MoveTo(0, LineTop+LineHeight div 2);
      Canvas.LineTo(15, LineTop+LineHeight div 2 + ArrowHeight div 2);
    end;
    if kaDouble in FKindArrow then begin
      Canvas.Rectangle(0, LineTop+ArrowHeight, Width, LineTop+ArrowHeight+LineHeight);
    end;
  end;
begin
  case FAlignEA of
    aeTop:
      if kaDouble in FKindArrow then
        LineTop:=FEditAreaList.Items[0].Height
      else
        LineTop:=FEditAreaList.Items[0].Height+ArrowHeight div 2;
    aeBottom:
      if kaDouble in FKindArrow then
        LineTop:=1
      else
        LineTop:=3;
  end;
  SetCanvasFont;
  Canvas.Rectangle(0, 0, Width, Height);
  DrawArrow;
end;

procedure TEqVector.RefreshDimensions;
begin
  Height:=CalcHeight;
  Width:=CalcWidth;
  ArrowHeight:=Font.Size div 5;
  LineHeight:=Font.Size div 10;
end;

procedure TEqVector.RefreshEditArea(AEditAreaIndex: Integer = 0);
begin
  FEditAreaList.Items[0].BkColor:=Parent.BkColor;
  FEditAreaList.Items[0].Font:=Font;
  FEditAreaList.Items[0].Font.Size:=Round(Font.Size*Kp);
  FEditAreaList.Items[0].RefreshDimensions;
  FEditAreaList.Items[0].Index:=0;
  FEditAreaList.Items[0].Left:=0;
  case FAlignEA of
    aeTop:     FEditAreaList.Items[0].Top:=0;
    aeBottom:  FEditAreaList.Items[0].Top:=ArrowHeight+4;
  end;
  Parent.RefreshEquations;
end;

procedure TEqVector.SetAlignEA(const Value: TAlignEA);
begin
  FAlignEA := Value;
  RefreshEditArea;
end;

procedure TEqVector.SetKindArrow(Value: TKindArrow);
begin
  FKindArrow:=Value;
  RefreshEditArea;
end;

{
********************************** TEqMatrix ***********************************
}
function TEqMatrix.CalcHeight: Integer;
var i, dy: Integer;
begin
  Result:=0;
  dy:=GetDY;
  for i:=0 to dy-1 do Result:=Result+GetRowHeight(i)+10;
end;

function TEqMatrix.CalcWidth: Integer;
var i, dx: Integer;
begin
  Result:=0;
  dx:=GetDX;
  for i:=0 to dx-1 do Result:=Result+GetColWidth(i)+10;
end;

constructor TEqMatrix.Create(AOwner: TComponent);
begin
  inherited;
  InsertEditArea;
  FCountEA:=0;
  FKindMatrix:=kmSquare;
end;

function TEqMatrix.GetColWidth(ACol: Integer): Integer;
var i, dx: Integer;
begin
  dx:=GetDX;
  i:=ACol;
  Result:=FEditAreaList.Items[i].Width;
  while i<FCountEA do begin
    Result:=Max(Result, FEditAreaList.Items[i].Width);
    Inc(i, dx);
  end;
end;

function TEqMatrix.GetRowHeight(ARow: Integer): Integer;
var i, dy: Integer;
begin
  dy:=GetDY;
  i:=ARow;
  Result:=FEditAreaList.Items[i].Height;
  while i<FCountEA do begin
    Result:=Max(Result, FEditAreaList.Items[i].Height);
    Inc(i, dy);
  end;
end;

function TEqMatrix.GetData: string;
var i: Integer;
begin
  Result:='';
  for i:=0 to FEditAreaList.Count-1 do Result:=Result+Format('EditArea(%s)',[EditAreaList.Items[i].Data]);
end;

procedure TEqMatrix.SetData(const AValue: String);
var
  i: Integer;
  ExprArray: TExprArray;
begin
  ExprArray:=GetExprData(AValue);
  CountEA:=Length(ExprArray);
  for i:=0 to Length(ExprArray)-1 do begin
    if ExprArray[i].ClassName = 'EditArea' then if i<FEditAreaList.Count then begin
      FEditAreaList.Items[i].Data:=ExprArray[i].ExprData;
    end;
  end;
  Parent.RefreshRecurse;
  Parent.MainArea.Change;
end;

function TEqMatrix.GetDX: Integer;
begin
  Result:=0;
  case FKindMatrix of
    kmHoriz: Result:=FCountEA;
    kmVert:  Result:=1;
    kmSquare: begin
      Result:=Round(Sqrt(FCountEA));
    end;
  end;
end;

function TEqMatrix.GetDY: Integer;
begin
  Result:=0;
  case FKindMatrix of
    kmHoriz:  Result:=1;
    kmVert:   Result:=FCountEA;
    kmSquare: begin
      Result:=Round(Sqrt(FCountEA));
    end;
  end;
end;

function TEqMatrix.GetMidLine: Integer;
begin
  Result:=Height div 2;
end;

procedure TEqMatrix.Paint;
begin
  SetCanvasFont;
  Canvas.Rectangle(0, 0, Width, Height);
end;

procedure TEqMatrix.RefreshDimensions;
begin
  Height:=CalcHeight;
  Width:=CalcWidth;
end;

procedure TEqMatrix.RefreshEditArea(AEditAreaIndex: Integer = 0);
var i,j, dx, dy, CommonHeight, CommonWidth, RowHeight, ColWidth: Integer;
begin
  if FUpdateCount>0 then Exit;
  dx:=GetDX; dy:=GetDY;
  for i:=0 to FCountEA-1 do RefreshEA(FEditAreaList.Items[i]);
  CommonHeight:=0;
  for i:=0 to dy-1 do begin
    RowHeight:=GetRowHeight(i);
    for j:=0 to dx-1 do
      FEditAreaList.Items[i*dx+j].Top:=CommonHeight+(RowHeight-FEditAreaList.Items[i*dx+j].Height) div 2;

    Inc(CommonHeight,RowHeight+10);
  end;
  CommonWidth:=0;
  for j:=0 to dx-1 do begin
    ColWidth:=GetColWidth(j);
    for i:=0 to dy-1 do begin
      FEditAreaList.Items[i*dx+j].Left:=CommonWidth+(ColWidth-FEditAreaList.Items[i*dx+j].Width) div 2;
    end;
    Inc(CommonWidth,ColWidth+10);
  end;

  Parent.RefreshEquations;
end;

procedure TEqMatrix.RefreshEA(AEditArea: TEditArea);
begin
  AEditArea.BkColor:=Parent.BkColor;
  AEditArea.Font.Assign(Font);
  AEditArea.Font.Size:=Round(Font.Size*Kp);
  AEditArea.RefreshDimensions;
  AEditArea.Index:=FEditAreaList.IndexOf(AEditArea);
end;

procedure TEqMatrix.SetKindMatrix(const Value: TKindMatrix);
begin
  FKindMatrix := Value;
  RefreshEditArea;
end;

procedure TEqMatrix.SetCountEA(const Value: Integer);
begin
  FCountEA:=EditAreaList.Count;
  BeginUpdate;
  while FCountEA < Value do begin
    FEditAreaIndex:=FCountEA-1;
    InsertEditArea;
    Inc(FCountEA);
  end;
  EndUpdate;
end;


end.
