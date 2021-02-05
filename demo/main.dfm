object frmMain: TfrmMain
  Left = 200
  Top = 129
  Width = 1000
  Height = 476
  Caption = 'QDS Eqations'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 316
    Width = 984
    Height = 121
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      984
      121)
    object Label1: TLabel
      Left = 8
      Top = 20
      Width = 23
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Data'
    end
    object Label2: TLabel
      Left = 657
      Top = 1
      Width = 48
      Height = 13
      Anchors = [akRight, akBottom]
      Caption = 'Language'
    end
    object Memo1: TMemo
      Left = 1
      Top = 40
      Width = 982
      Height = 80
      Align = alBottom
      TabOrder = 0
      WantReturns = False
      OnChange = Memo1Change
    end
    object ComboBox1: TComboBox
      Left = 655
      Top = 14
      Width = 127
      Height = 24
      Style = csDropDownList
      Anchors = [akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Courier'
      Font.Style = []
      ItemHeight = 16
      ItemIndex = 0
      ParentFont = False
      TabOrder = 1
      Text = 'Russian'
      OnChange = ComboBox1Change
      Items.Strings = (
        'Russian'
        'Deutsche'
        'English')
    end
    object Button1: TButton
      Left = 802
      Top = 13
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Font..'
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 901
      Top = 13
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'BkColor..'
      TabOrder = 3
      OnClick = Button2Click
    end
  end
  object SelectEquation1: TSelectEquation
    Left = 0
    Top = 0
    Width = 984
    Height = 121
    Align = alTop
    Equation = QDSEquation1
    Language = lRussian
  end
  object QDSEquation1: TQDSEquation
    Left = 0
    Top = 121
    Width = 984
    Height = 195
    Align = alClient
    BkColor = clWhite
    Data = 'EditArea()'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlack
    Font.Height = -27
    Font.Name = 'Times New Roman'
    Font.Style = []
    OnChange = QDSEquation1Change
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
  end
  object ColorDialog1: TColorDialog
    Left = 32
  end
end
