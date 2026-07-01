object SQLBReader: TSQLBReader
  OldCreateOrder = False
  DisplayName = 'SQL Server VSS Reader'
  OnExecute = ServiceExecute
  Left = 1119
  Top = 349
  Height = 194
  Width = 290
  object ClientSocket1: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Host = '127.0.0.1'
    Port = 1004
    OnConnect = ClientSocket1Connect
    OnDisconnect = ClientSocket1Disconnect
    OnRead = ClientSocket1Read
    Left = 34
    Top = 32
  end
  object pSerial: TApdComPort
    TraceName = 'APRO.TRC'
    LogName = 'APRO.LOG'
    OnTriggerAvail = pSerialTriggerAvail
    Left = 100
    Top = 31
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 150
    OnTimer = Timer1Timer
    Left = 47
    Top = 96
  end
  object Timer2: TTimer
    Enabled = True
    Interval = 1000
    OnTimer = Timer2Timer
    Left = 116
    Top = 96
  end
end
