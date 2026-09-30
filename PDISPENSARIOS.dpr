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
  UVersionModulo in 'UVersionModulo.pas',
  UIGASWAYNE in 'UIGASWAYNE.pas' {SQLWReader: TService},
  UIGASHONGYANG in 'UIGASHONGYANG.pas' {SQLHReader: TService},
  ULIBLICENCIAS in 'ULIBLICENCIAS.pas',
  UIGASGILBARCO in 'UIGASGILBARCO.pas' {SQLGReader: TService},
  UIGASKAIROS in 'UIGASKAIROS.pas' {SQLKReader: TService},
  UIGASTEAM in 'UIGASTEAM.pas' {SQLTReader: TService},
  UIGASWAYNE2W in 'UIGASWAYNE2W.pas' {SQLW2Reader: TService};

{$R *.RES}
var
  config: TIniFile;
  marca: Integer;

begin
  Application.Initialize;

  config := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'PDISPENSARIOS.ini');
  marca := StrToInt(config.ReadString('CONF', 'Marca', '0'));
  case marca of
    1:begin
        Application.CreateForm(TSQLWReader, SQLWReader);
      end;
    2:begin
        Application.CreateForm(TSQLBReader, SQLBReader);
      end;
    3:begin
        Application.CreateForm(TSQLTReader, SQLTReader);
      end;
    4:begin
        Application.CreateForm(TSQLPReader, SQLPReader);
      end;
    5:begin
        Application.CreateForm(TSQLHReader, SQLHReader);
      end;
    6:begin
        Application.CreateForm(TSQLGReader, SQLGReader);
      end;
    7:begin
        Application.CreateForm(TSQLKReader, SQLKReader);
      end;
    9:begin
        Application.CreateForm(TSQLW2Reader, SQLW2Reader);
      end;
  end;
  Application.Run;
end.

