unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Equations, SelectEquation, StdCtrls, ToolWin, ComCtrls, ImgList,
  ExtCtrls, Spin, Grids, DBGrids;

type
  TfrmMain = class(TForm)
    FontDialog1: TFontDialog;
    ColorDialog1: TColorDialog;
    Panel1: TPanel;
    Memo1: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    ComboBox1: TComboBox;
    Button1: TButton;
    Button2: TButton;
    SelectEquation1: TSelectEquation;
    QDSEquation1: TQDSEquation;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure QDSEquation1Change(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

  QDSEquation1: TQDSEquation;
  SelectEquation1: TSelectEquation;

implementation

{$R *.dfm}


procedure TfrmMain.FormCreate(Sender: TObject);
var Canvas: TCanvas;

begin


  QDSEquation1.Data:='EditArea(IntLimitBottomTopOne(EditArea(Simple(x)Simple(d)Simple(x))EditArea(Simple(0))EditArea(ExtSymbol(8734))))';
  ComboBox1Change(Self);
  Caption:=Format('%s v%s',[Caption,QDSEquation1.Version]);
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  FontDialog1.Font.Assign(QDSEquation1.Font);
  if FontDialog1.Execute then QDSEquation1.Font.Assign(FontDialog1.Font);
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin                             
  ColorDialog1.Color:=QDSEquation1.BkColor;
  if ColorDialog1.Execute then QDSEquation1.BkColor:=ColorDialog1.Color;
end;

procedure TfrmMain.QDSEquation1Change(Sender: TObject);
begin
  Memo1.Text:=QDSEquation1.Data;
end;

procedure TfrmMain.Memo1Change(Sender: TObject);
begin
  if QDSEquation1.Data<>Memo1.Text then
  QDSEquation1.Data:=Memo1.Text;
end;

procedure TfrmMain.ComboBox1Change(Sender: TObject);
begin
  case ComboBox1.ItemIndex of
    0:  SelectEquation1.Language:=lRussian;
    1:  SelectEquation1.Language:=lDeutsche;
    2:  SelectEquation1.Language:=lEnglish;
  end;
end;

end.


