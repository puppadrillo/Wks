object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 524
  ClientWidth = 1018
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 1018
    Height = 41
    Align = alTop
    Caption = 'TopPanel'
    ShowCaption = False
    TabOrder = 0
    object UrlLabel: TLabel
      Left = 16
      Top = 13
      Width = 13
      Height = 13
      Caption = 'Url'
    end
    object ResultLabel: TLabel
      AlignWithMargins = True
      Left = 960
      Top = 4
      Width = 41
      Height = 36
      Margins.Right = 16
      Align = alRight
      Caption = 'Result'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      ExplicitHeight = 16
    end
    object GoButton: TButton
      Left = 261
      Top = 8
      Width = 42
      Height = 25
      Caption = 'Go'
      TabOrder = 0
      OnClick = GoButtonClick
    end
    object GoThreadButton: TButton
      Left = 373
      Top = 8
      Width = 41
      Height = 25
      Caption = 'Start'
      TabOrder = 1
      OnClick = GoThreadButtonClick
    end
    object RepeatEdit: TEdit
      Left = 329
      Top = 10
      Width = 38
      Height = 21
      TabOrder = 2
      Text = 'RepeatEdit'
    end
    object ClearAtStartCheckBox: TCheckBox
      Left = 488
      Top = 12
      Width = 81
      Height = 17
      Caption = 'Clear at start'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object LogActivityOnlyCheckBox: TCheckBox
      Left = 583
      Top = 12
      Width = 98
      Height = 17
      Caption = 'Log activity only'
      TabOrder = 4
    end
    object ClearButton: TButton
      AlignWithMargins = True
      Left = 895
      Top = 8
      Width = 49
      Height = 25
      Margins.Top = 7
      Margins.Right = 13
      Margins.Bottom = 7
      Align = alRight
      Caption = 'Clear'
      TabOrder = 5
      OnClick = ClearButtonClick
    end
    object LogCheckBox: TCheckBox
      Left = 441
      Top = 12
      Width = 41
      Height = 17
      Caption = 'Log'
      Checked = True
      State = cbChecked
      TabOrder = 6
    end
    object UrlComboBox: TComboBox
      Left = 38
      Top = 10
      Width = 217
      Height = 21
      TabOrder = 7
      Text = 'UrlComboBox'
    end
  end
  object LogMemo: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 44
    Width = 1012
    Height = 477
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'LogMemo')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
  end
end
