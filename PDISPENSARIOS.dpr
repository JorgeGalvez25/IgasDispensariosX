program PDISPENSARIOS;

uses
  SvcMgr,
  IniFiles,
  SysUtils,
  UIGASPAM in 'UIGASPAM.pas' {SQLPReader: TService},
  UIGASBENNETT in 'UIGASBENNETT.pas' {SQLBReader: TService},
  uLkJSON in 'uLkJSON.pas',
  CRCs in 'CRCs.pas',
  IdHashMessageDigest in 'IdHashMessageDigest.pas',
  IdHash in 'IdHash.pas',
  OG_Hasp in 'OG_Hasp.pas',
  UIGASWAYNE in 'UIGASWAYNE.pas' {ogcvdispensarios_wayne: TService},
  UIGASHONGYANG in 'UIGASHONGYANG.pas' {ogcvdispensarios_hongyang: TService},
  ULIBLICENCIAS in 'ULIBLICENCIAS.pas',
  UIGASGILBARCO in 'UIGASGILBARCO.pas' {SQLGReader: TService},
  UIGASKIROS in 'UIGASKIROS.pas' {ogcvdispensarios_kiros: TService};

{$R *.RES}
var
  config:TIniFile;
  marca:Integer;
begin
  Application.Initialize;

  config:= TIniFile.Create(ExtractFilePath(ParamStr(0)) +'PDISPENSARIOS.ini');
  marca:=StrToInt(config.ReadString('CONF','Marca','0'));
  case marca of
    1:
      Application.CreateForm(Togcvdispensarios_wayne, ogcvdispensarios_wayne);
    2:
      Application.CreateForm(TSQLBReader, SQLBReader);
    4:
      Application.CreateForm(TSQLPReader, SQLPReader);
    5:
      Application.CreateForm(Togcvdispensarios_hongyang, ogcvdispensarios_hongyang);
    6:
      Application.CreateForm(TSQLGReader, SQLGReader);
    7:
      Application.CreateForm(Togcvdispensarios_kiros, ogcvdispensarios_kiros);
  end;
  Application.Run;
end.
