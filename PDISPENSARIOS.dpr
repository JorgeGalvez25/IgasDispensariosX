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
  UIGASWAYNE in 'UIGASWAYNE.pas' {SQLWReader: TService},
  UIGASHONGYANG in 'UIGASHONGYANG.pas' {ogcvdispensarios_hongyang: TService},
  ULIBLICENCIAS in 'ULIBLICENCIAS.pas',
  UIGASGILBARCO in 'UIGASGILBARCO.pas' {SQLGReader: TService},
  UIGASKAIROS in 'UIGASKAIROS.pas' {SQLKReader: TService},
  UIGASTEAM in 'UIGASTEAM.pas' {SQLTReader: TService};

{$R *.RES}
var
  config:TIniFile;
  marca:Integer;
  version:String;
begin
  Application.Initialize;

  version:='17cec27d7ad6eaa00123b2191b823eb73d644d16';
  config:= TIniFile.Create(ExtractFilePath(ParamStr(0)) +'PDISPENSARIOS.ini');
  marca:=StrToInt(config.ReadString('CONF','Marca','0'));
  case marca of
    1:
      begin
        Application.CreateForm(TSQLWReader, SQLWReader);
        SQLWReader.version:=version;
      end;
    2:
      begin
        Application.CreateForm(TSQLBReader, SQLBReader);
        SQLBReader.version:=version;
      end;
    3:
      begin
        Application.CreateForm(TSQLTReader, SQLTReader);
        SQLTReader.version:=version;
      end;        
    4:
      begin
        Application.CreateForm(TSQLPReader, SQLPReader);
        SQLPReader.version:=version;
      end;
    6:
      begin
        Application.CreateForm(TSQLGReader, SQLGReader);
        SQLGReader.version:=version;
      end;
    7:
      begin
        Application.CreateForm(TSQLKReader, SQLKReader);
        SQLKReader.version:=version;
      end;
  end;
  Application.Run;
end.
