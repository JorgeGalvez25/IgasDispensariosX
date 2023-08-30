program PDISPENSARIOS;

uses
  SvcMgr,
  IniFiles,
  SysUtils,
  UIGASPAM in 'UIGASPAM.pas' {ogcvdispensarios_pam: TService},
  UIGASBENNETT in 'UIGASBENNETT.pas' {ogcvdispensarios_bennett: TService},
  uLkJSON in 'uLkJSON.pas',
  CRCs in 'CRCs.pas',
  IdHashMessageDigest in 'IdHashMessageDigest.pas',
  IdHash in 'IdHash.pas',
  OG_Hasp in 'OG_Hasp.pas',
  UIGASWAYNE in 'UIGASWAYNE.pas' {ogcvdispensarios_wayne: TService},
  UIGASHONGYANG in 'UIGASHONGYANG.pas' {ogcvdispensarios_hongyang: TService},
  ULIBLICENCIAS in 'ULIBLICENCIAS.pas',
  UIGASGILBARCO in 'UIGASGILBARCO.pas' {ogcvdispensarios_gilbarco2W: TService};

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
      Application.CreateForm(Togcvdispensarios_bennett, ogcvdispensarios_bennett);
    4:
      Application.CreateForm(Togcvdispensarios_pam, ogcvdispensarios_pam);
    5:
      Application.CreateForm(Togcvdispensarios_hongyang, ogcvdispensarios_hongyang);
    6:
      Application.CreateForm(Togcvdispensarios_gilbarco2W, ogcvdispensarios_gilbarco2W);
  end;
  Application.Run;
end.
