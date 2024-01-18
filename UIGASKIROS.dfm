object ogcvdispensarios_kiros: Togcvdispensarios_kiros
  OldCreateOrder = False
  DisplayName = 'ogcvdispensarios_kiros'
  OnExecute = ServiceExecute
  Left = 441
  Top = 302
  Height = 165
  Width = 224
  object ServerSocket1: TServerSocket
    Active = False
    Port = 1001
    ServerType = stNonBlocking
    OnClientRead = ServerSocket1ClientRead
    Left = 24
    Top = 22
  end
  object pSerial: TApdComPort
    ComNumber = 1
    Baud = 5700
    Parity = pEven
    Tracing = tlOn
    TraceSize = 15000
    TraceName = 'APRO.TRC'
    TraceAllHex = True
    LogName = 'APRO.LOG'
    Left = 81
    Top = 47
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 280
    Left = 144
    Top = 20
  end
end
