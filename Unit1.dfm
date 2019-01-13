object Form1: TForm1
  Left = 679
  Top = 115
  Width = 566
  Height = 359
  Caption = 'CreateEvent/SetEvent Demo'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 128
    Top = 16
    Width = 83
    Height = 25
    Caption = 'create #1 wai1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 24
    Top = 88
    Width = 505
    Height = 225
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object Button2: TButton
    Left = 24
    Top = 48
    Width = 75
    Height = 25
    Caption = 'SetEvent'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 344
    Top = 16
    Width = 81
    Height = 25
    Caption = 'QAPC #2 wait2'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 232
    Top = 16
    Width = 81
    Height = 25
    Caption = 'create #2 sleep'
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button6: TButton
    Left = 24
    Top = 16
    Width = 75
    Height = 25
    Caption = 'CreateEvent'
    TabOrder = 5
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 344
    Top = 48
    Width = 81
    Height = 25
    Caption = 'QApc #2 SE'
    TabOrder = 6
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 448
    Top = 48
    Width = 75
    Height = 25
    Caption = 'SetThreadCtx'
    TabOrder = 7
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 128
    Top = 48
    Width = 83
    Height = 25
    Caption = 'create #1 wait2'
    TabOrder = 8
    OnClick = Button9Click
  end
end
