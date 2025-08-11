object SQLGReader: TSQLGReader
  OldCreateOrder = False
  DisplayName = 'SQL Server VSS Reader'
  OnExecute = ServiceExecute
  Left = 301
  Top = 204
  Height = 191
  Width = 210
  object pSerial: TApdComPort
    Baud = 5700
    Tracing = tlOn
    TraceName = 'APRO.TRC'
    TraceAllHex = True
    LogName = 'APRO.LOG'
    OnTriggerAvail = pSerialTriggerAvail
    OnTriggerData = pSerialTriggerData
    Left = 112
    Top = 28
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 48
    Top = 96
  end
  object ClientSocket1: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnect = ClientSocket1Connect
    OnDisconnect = ClientSocket1Disconnect
    OnRead = ClientSocket1Read
    Left = 51
    Top = 29
  end
  object Timer2: TTimer
    Interval = 200
    OnTimer = Timer2Timer
    Left = 112
    Top = 100
  end
end
