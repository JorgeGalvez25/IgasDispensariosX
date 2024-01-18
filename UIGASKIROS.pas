unit UIGASKIROS;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  ScktComp, ExtCtrls, OoMisc, AdPort, IniFiles, ActiveX, ComObj, ULIBGRAL, CRCs,
  IdHashMessageDigest, IdHash, uLkJSON, ULIBLICENCIAS;

type
  Togcvdispensarios_kiros = class(TService)
    ServerSocket1: TServerSocket;
    pSerial: TApdComPort;
    Timer1: TTimer;
    procedure ServiceExecute(Sender: TService);
    procedure ServerSocket1ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
  private
    { Private declarations }
    SwPasoBien      :boolean;
    PosCiclo,ls,
    ContLeeVenta,
    NumPaso         :integer;
    SwAplicaCmnd,
    SwInicio,
    SwBring,
    SwEspera     :boolean;
  public
    ListaLog:TStringList;
    ListaLogPetRes:TStringList;
    rutaLog:string;
    confPos:string;
    licencia:string;
    detenido:Boolean;
    estado:Integer;
  // CONTROL TRAFICO COMANDOS
    ListaCmnd    :TStrings;  
    LinCmnd      :string;
    CharCmnd     :char;
    SwEsperaRsp  :boolean;
    FolioCmnd   :integer;
    DecimalesGilbarco :Integer;

    GtwDivPresetLts,        // Divisor preset litros           **
    GtwDivPresetPesos,      // Divisor preset pesos            **

    GtwDivPrecio,           // Divisor precio para lecturas y cambio de precios       **
    GtwDivImporte,          // Divisor importe para lecturas y ventas                 **
    GtwDivLitros,           // Divisor litros para ventas                             **

    GtwDivTotLts,           // Divisor totales litros     **
    GtwDivTotImporte,       // Divisor totales pesos      **

    GtwTimeOut,             // Timeout miliseg
    GtwTiempoCmnd :integer; // Tiempo entre comandos miliseg
    function GetServiceController: TServiceController; override;
    procedure AgregaLog(lin:string);
    procedure AgregaLogPetRes(lin: string);
    procedure Responder(socket:TCustomWinSocket;resp:string);
    function FechaHoraExtToStr(FechaHora:TDateTime):String;
    function CRC16(Data: string): string;
    function GuardarLog:string;
    function GuardarLogPetRes:string;
    function Login(mensaje: string): string;
    function Logout: string;
    function MD5(const usuario: string): string;
    function Bloquear(msj: string): string;
    function Desbloquear(msj: string): string;
    function Detener: string;
    function Iniciar: string;
    function Shutdown: string;
    function ObtenerEstado: string;
    function EjecutaComando(xCmnd:string):integer;
    function RespuestaComando(msj: string): string;
    function ResultadoComando(xFolio:integer):string;
    function ObtenerLog(r: Integer): string;
    function ObtenerLogPetRes(r: Integer): string;
    function ActivaModoPrepago(msj:string): string;
    function DesactivaModoPrepago(msj:string): string;
    function FinVenta(msj: string): string;
    function TransaccionPosCarga(msj: string): string;
    function EstadoPosiciones(msj: string): string;
    function TotalesBomba(msj: string): string;
    function Terminar: string;
    function IniciaPrecios(msj:string):string;
    function IniciaPSerial(datosPuerto:string): string;
    function AgregaPosCarga(posiciones: TlkJSONbase): string;
    function Inicializar(msj: string): string;
    function NoElemStrEnter(xstr:string):word;
    function ExtraeElemStrEnter(xstr:string;ind:word):string;
    function AutorizarVenta(msj: string): string;
    function DetenerVenta(msj: string): string;
    function ReanudarVenta(msj: string): string;
    { Public declarations }
  end;

type
     tiposcarga = record
       SwDesHabil   :boolean;
       DigitosGilbarco,
       DivImporte,
       DivLitros,
       estatus,
       estatusant   :integer;
       importe,
       volumen,
       precio       :real;
       Isla,
       Canal,
       PosActual    :integer; // Posicion del combustible en proceso: 1..NoComb
       NoComb       :integer; // Cuantos combustibles hay en la posicion
       TComb        :array[1..4] of integer; // Claves de los combustibles
       TPosx        :array[1..4] of integer;
       TMang        :array[1..4] of integer;
       TotalLitros  :array[1..4] of real;

       MontoPreset    :string;
       ImportePreset  :real;

       swprec,
       swestatus0,
       swautoriza,
       swcargando     :boolean;
       ModoOpera      :string[8];
       TipoPago       :integer;
       EsperaFinVenta :integer;

       SwFinVenta,
       SwLeeVenta,
       SwTotales,
       SwNivelPrecio,
       SwCambiaPrecio,
       SwRepitePos,
       //swaux,
       SwPreset       :boolean;
       HoraNivelPrecio:TDateTime;

       StPresetPos,
       StKairosFrec,
       StFluPos,
       FallosEstat    :integer;
     end;

     regprecios = record
       SwCambPrec:array[1..4] of boolean;
       NuevoPrec:array[1..4] of real;
     end;     

     RegCmnd = record
       SwActivo   :boolean;
       folio      :integer;
       hora       :TDateTime;
       Comando    :string[80];
       SwResp,
       SwNuevo    :boolean;
       Respuesta  :string[80];
     end;

const idSTX = #2;
      idETX = #3;
      idACK = #6;
      idNAK = #21;
      MaximoDePosiciones = 32;

type TMetodos = (NOTHING_e, INITIALIZE_e, PARAMETERS_e, LOGIN_e, LOGOUT_e,
             PRICES_e, AUTHORIZE_e, STOP_e, START_e, SELFSERVICE_e, FULLSERVICE_e,
             BLOCK_e, UNBLOCK_e, PAYMENT_e, TRANSACTION_e, STATUS_e, TOTALS_e, HALT_e,
             RUN_e, SHUTDOWN_e, TERMINATE_e, STATE_e, TRACE_e, SAVELOGREQ_e, RESPCMND_e,
             LOG_e, LOGREQ_e, EJECCMND_e, FLUSTD_e, FLUMIN_e);  

var
  ogcvdispensarios_kiros: Togcvdispensarios_kiros;
  key:OleVariant;
  claveCre,key3DES:string;
  Token:string;
  Licencia3Ok  :Boolean;
  MaxPosCarga:integer;
  TabCmnd  :array[1..200] of RegCmnd;
  TPosCarga   :array[1..32] of tiposcarga;
  TPrecios    :array[1..16] of regprecios;
  SwCmndPend  :boolean;
  IdCmndPend,
  PosCmndPend  :integer;
  Tagx        :array[1..3] of integer;
  EstatusAct,EstatusAnt  :string;
  Swflu       :boolean;
  TAdicf        :array[1..32,1..3] of integer;   

implementation

uses TypInfo, StrUtils, Variants;

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ogcvdispensarios_kiros.Controller(CtrlCode);
end;

function Togcvdispensarios_kiros.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure Togcvdispensarios_kiros.ServiceExecute(Sender: TService);
var
  config:TIniFile;
  lic:string;
  razonSocial,licAdic:String;
  esLicTemporal:Boolean;
  fechaVenceLic:TDateTime;
begin
  try
    config:= TIniFile.Create(ExtractFilePath(ParamStr(0)) +'PDISPENSARIOS.ini');
    rutaLog:=config.ReadString('CONF','RutaLog','C:\ImagenCo');
    ServerSocket1.Port:=config.ReadInteger('CONF','Puerto',1001);         
    licencia:=config.ReadString('CONF','Licencia','');
    ListaCmnd:=TStringList.Create;
    ServerSocket1.Active:=True;
    detenido:=True;
    estado:=-1;
    ListaLog:=TStringList.Create;
    ListaLogPetRes:=TStringList.Create;

    CoInitialize(nil);
    Key:=CreateOleObject('HaspDelphiAdapter.HaspAdapter');
    lic:=Key.GetKeyData(ExtractFilePath(ParamStr(0)),licencia);

    if UpperCase(ExtraeElemStrSep(lic,1,'|'))='FALSE' then begin
      ListaLog.Add('Error al validad licencia: '+Key.StatusMessage);
      ListaLog.SaveToFile(rutaLog+'\LogDispPetRes'+FiltraStrNum(FechaHoraToStr(Now))+'.txt');
      ServiceThread.Terminate;
      Exit;
    end
    else begin
      claveCre:=ExtraeElemStrSep(lic,2,'|');
      key3DES:=ExtraeElemStrSep(lic,3,'|');
    end;

    //LicenciaAdic
    razonSocial:=config.ReadString('CONF','RazonSocial','');
    licAdic:=config.ReadString('CONF','LicCVL7','');
    esLicTemporal:=config.ReadString('CONF','LicCVL7FechaVence','')<>'';
    fechaVenceLic:=StrToDateDef(config.ReadString('CONF','LicCVL7FechaVence','01/01/1900'),0);

    try
      Licencia3Ok:=LicenciaValida2(razonSocial,'CVL7','3.1','Abierta',licAdic,1,esLicTemporal,fechaVenceLic);
    except
      Licencia3Ok:=false;
    end;

    if not Licencia3Ok then
      ListaLog.Add('Datos Licencia: '+razonSocial+'-'+licAdic+'-'+BoolToStr(esLicTemporal)+'-'+DateToStr(fechaVenceLic));

    while not Terminated do
      ServiceThread.ProcessRequests(True);
    ServerSocket1.Active := False;
    CoUninitialize;        
  except
    on e:exception do begin
      ListaLog.Add('Error al iniciar servicio: '+e.Message);
      ListaLog.SaveToFile(rutaLog+'\LogDispPetRes'+FiltraStrNum(FechaHoraToStr(Now))+'.txt');
    end;
  end;
end;

procedure Togcvdispensarios_kiros.ServerSocket1ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
  var
    mensaje,comando,checksum,parametro:string;
    i:Integer;
    chks_valido:Boolean;
    metodoEnum:TMetodos;
begin
  mensaje:=Socket.ReceiveText;
  if StrToIntDef(mensaje,-99) in [0,1] then begin
    if Licencia3Ok then begin
      pSerial.Open:=mensaje='1';
      Socket.SendText('1');
    end
    else
      Socket.SendText('False|Licencia CVL7 invalida|');       
    Exit;
  end;
  if UpperCase(ExtraeElemStrSep(mensaje,1,'|'))='DISPENSERSX' then begin
    try
      AgregaLogPetRes('R '+mensaje);

      if NoElemStrSep(mensaje,'|')>=2 then begin

        comando:=UpperCase(ExtraeElemStrSep(mensaje,2,'|'));

        if NoElemStrSep(mensaje,'|')>2 then begin
          for i:=3 to NoElemStrSep(mensaje,'|') do
            parametro:=parametro+ExtraeElemStrSep(mensaje,i,'|')+'|';

          if parametro[Length(parametro)]='|' then
            Delete(parametro,Length(parametro),1);
        end;

        metodoEnum := TMetodos(GetEnumValue(TypeInfo(TMetodos), comando+'_e'));

        case metodoEnum of
          EJECCMND_e:
            Socket.SendText('DISPENSERSX|EJECCMND|True|'+IntToStr(EjecutaComando(parametro))+'|');
//          FLUSTD_e:
//            Socket.SendText('DISPENSERSX|FLUSTD|'+FluStd(parametro));
//          FLUMIN_e:
//            Socket.SendText('DISPENSERSX|FLUMIN|'+FluMin);
          RESPCMND_e:
            Socket.SendText('DISPENSERSX|RESPCMND|'+RespuestaComando(parametro));
        else
          Socket.SendText('DISPENSERSX|'+comando+'|False|Comando desconocido|');
        end;
      end
      else
        Socket.SendText('DISPENSERSX|'+mensaje+'|False|Comando desconocido|');
    except
      on e:Exception do begin
        AgregaLogPetRes('Error ServerSocket1ClientRead: '+e.Message);
        GuardarLogPetRes;
        Socket.SendText('DISPENSERSX|'+comando+'|False|'+e.Message+'|');
      end;
    end;
  end
  else begin
    try
      mensaje:=Key.Decrypt(ExtractFilePath(ParamStr(0)),key3DES,mensaje);
      AgregaLogPetRes('R '+mensaje);
      for i:=1 to Length(mensaje) do begin
        if mensaje[i]=#2 then begin
          mensaje:=Copy(mensaje,i+1,Length(mensaje));
          Break;
        end;
      end;
      for i:=Length(mensaje) downto 1 do begin
        if mensaje[i]=#3 then begin
          checksum:=Copy(mensaje,i+1,4);
          mensaje:=Copy(mensaje,1,i-1);
          Break;
        end;
      end;
      chks_valido:=checksum=CRC16(mensaje);
      if mensaje[1]='|' then
        Delete(mensaje,1,1);
      if mensaje[Length(mensaje)]='|' then
        Delete(mensaje,Length(mensaje),1);
      if NoElemStrSep(mensaje,'|')>=2 then begin
        if UpperCase(ExtraeElemStrSep(mensaje,1,'|'))<>'DISPENSERS' then begin
          Responder(Socket,'DISPENSERS|False|Este servicio solo procesa solicitudes de dispensarios|');
          Exit;
        end;

        comando:=UpperCase(ExtraeElemStrSep(mensaje,2,'|'));

        if not chks_valido then begin
          Responder(Socket,'DISPENSERS|'+comando+'|False|Checksum invalido|');
          Exit;
        end;

        if NoElemStrSep(mensaje,'|')>2 then begin
          for i:=3 to NoElemStrSep(mensaje,'|') do
            parametro:=parametro+ExtraeElemStrSep(mensaje,i,'|')+'|';

          if parametro[Length(parametro)]='|' then
            Delete(parametro,Length(parametro),1);
        end;
//
//        if (Transmitiendo) and (UpperCase(comando)='AUTHORIZE') then begin
//          Responder(Socket,'DISPENSERS|'+comando+'|False|Comandos en proceso, favor de reintentar|');
//          Exit;
//        end;

        metodoEnum := TMetodos(GetEnumValue(TypeInfo(TMetodos), comando+'_e'));

        case metodoEnum of
          NOTHING_e:
            Responder(Socket, 'DISPENSERS|NOTHING|True|');
          INITIALIZE_e:
            Responder(Socket, 'DISPENSERS|INITIALIZE|'+Inicializar(parametro));
          PARAMETERS_e:
            Responder(Socket, 'DISPENSERS|PARAMETERS|True|');
          LOGIN_e:
            Responder(Socket, 'DISPENSERS|LOGIN|'+Login(parametro));
          LOGOUT_e:
            Responder(Socket, 'DISPENSERS|LOGOUT|'+Logout);
          PRICES_e:
            Responder(Socket, 'DISPENSERS|PRICES|'+IniciaPrecios(parametro));
          AUTHORIZE_e:
            Responder(Socket, 'DISPENSERS|AUTHORIZE|'+AutorizarVenta(parametro));
          STOP_e:
            Responder(Socket, 'DISPENSERS|STOP|'+DetenerVenta(parametro));
          START_e:
            Responder(Socket, 'DISPENSERS|START|'+ReanudarVenta(parametro));
          SELFSERVICE_e:
            Responder(Socket, 'DISPENSERS|SELFSERVICE|'+ActivaModoPrepago(parametro));
          FULLSERVICE_e:
            Responder(Socket, 'DISPENSERS|FULLSERVICE|'+DesactivaModoPrepago(parametro));
          BLOCK_e:
            Responder(Socket, 'DISPENSERS|BLOCK|'+Bloquear(parametro));
          UNBLOCK_e:
            Responder(Socket, 'DISPENSERS|UNBLOCK|'+Desbloquear(parametro));
          PAYMENT_e:
            Responder(Socket, 'DISPENSERS|PAYMENT|'+FinVenta(parametro));
          TRANSACTION_e:
            Responder(Socket, 'DISPENSERS|TRANSACTION|'+TransaccionPosCarga(parametro));
          STATUS_e:
            Responder(Socket, 'DISPENSERS|STATUS|'+EstadoPosiciones(parametro));
          TOTALS_e:
            Responder(Socket, 'DISPENSERS|TOTALS|'+TotalesBomba(parametro));
          HALT_e:
            Responder(Socket, 'DISPENSERS|HALT|'+Detener);
          RUN_e:
            Responder(Socket, 'DISPENSERS|RUN|'+Iniciar);
          SHUTDOWN_e:
            Responder(Socket, 'DISPENSERS|SHUTDOWN|'+Shutdown);
          TERMINATE_e:
            Responder(Socket, 'DISPENSERS|TERMINATE|'+Terminar);
          STATE_e:
            Responder(Socket, 'DISPENSERS|STATE|'+ObtenerEstado);
          TRACE_e:
            Responder(Socket, 'DISPENSERS|TRACE|'+GuardarLog);
          SAVELOGREQ_e:
            Responder(Socket, 'DISPENSERS|SAVELOGREQ|'+GuardarLogPetRes);
          RESPCMND_e:
            Responder(Socket, 'DISPENSERS|RESPCMND|'+RespuestaComando(parametro));
          LOG_e:
            Socket.SendText(Key.Encrypt(ExtractFilePath(ParamStr(0)), key3DES, 'DISPENSERS|LOG|'+ObtenerLog(StrToIntDef(parametro, 0))));
          LOGREQ_e:
            Socket.SendText(Key.Encrypt(ExtractFilePath(ParamStr(0)), key3DES, 'DISPENSERS|LOGREQ|'+ObtenerLogPetRes(StrToIntDef(parametro, 0))));
        else
          Responder(Socket, 'DISPENSERS|'+comando+'|False|Comando desconocido|');
        end;
      end
      else
        Responder(Socket,'DISPENSERS|'+mensaje+'|False|Comando desconocido|');
    except
      on e:Exception do begin
        if (claveCre<>'') and (key3DES<>'') then
          AgregaLogPetRes('Error ServerSocket1ClientRead: '+e.Message+'//Clave CRE: '+claveCre+'//Terminacion de Key 3DES: '+copy(key3DES,Length(key3DES)-3,4))
        else
          AgregaLogPetRes('Error ServerSocket1ClientRead: '+e.Message);
        GuardarLog;
        Responder(Socket,'DISPENSERS|'+comando+'|False|'+e.Message+'|');
      end;
    end;
  end;
end;

procedure Togcvdispensarios_kiros.AgregaLog(lin: string);
var lin2:string;
    i:integer;
begin
  lin2:=FechaHoraExtToStr(now)+' ';
  for i:=1 to length(lin) do
    case lin[i] of
      #1:lin2:=lin2+'<SOH>';
      #2:lin2:=lin2+'<STX>';
      #3:lin2:=lin2+'<ETX>';
      #6:lin2:=lin2+'<ACK>';
      #21:lin2:=lin2+'<NAK>';
      #23:lin2:=lin2+'<ETB>';
      else lin2:=lin2+lin[i];
    end;
  while ListaLog.Count>10000 do
    ListaLog.Delete(0);
  ListaLog.Add(lin2);
end;

procedure Togcvdispensarios_kiros.AgregaLogPetRes(lin: string);
var lin2:string;
    i:integer;
begin
  lin2:=FechaHoraExtToStr(now)+' ';
  for i:=1 to length(lin) do
    case lin[i] of
      #1:lin2:=lin2+'<SOH>';
      #2:lin2:=lin2+'<STX>';
      #3:lin2:=lin2+'<ETX>';
      #6:lin2:=lin2+'<ACK>';
      #21:lin2:=lin2+'<NAK>';
      #23:lin2:=lin2+'<ETB>';
      else lin2:=lin2+lin[i];
    end;  
  while ListaLogPetRes.Count>10000 do
    ListaLogPetRes.Delete(0);
  ListaLogPetRes.Add(lin2);
end;

procedure Togcvdispensarios_kiros.Responder(socket: TCustomWinSocket;
  resp: string);
begin
  socket.SendText(Key.Encrypt(ExtractFilePath(ParamStr(0)),key3DES,#1#2+resp+#3+CRC16(resp)+#23));
  AgregaLogPetRes('E '+#1#2+resp+#3+CRC16(resp)+#23);
end;

function Togcvdispensarios_kiros.FechaHoraExtToStr(
  FechaHora: TDateTime): String;
begin
  result:=FechaPaq(FechaHora)+' '+FormatDatetime('hh:mm:ss.zzz',FechaHora);
end;

function Togcvdispensarios_kiros.CRC16(Data: string): string;
var
  aCrc:TCRC;
  pin : Pointer;
  insize:Cardinal;
begin
  insize:=Length(Data);
  pin:=@Data[1];
  aCrc:=TCRC.Create(CRC16Desc);
  aCrc.CalcBlock(pin,insize);
  Result:=UpperCase(IntToHex(aCrc.Finish,4));
  aCrc.Destroy;
end;

function Togcvdispensarios_kiros.Bloquear(msj: string): string;
var
  xpos:Integer;
begin
  try
    xpos:=StrToIntDef(msj,-1);

    if xpos<0 then begin
      Result:='False|Favor de indicar correctamente la posicion de carga|';
      Exit;
    end;

    if (xpos<=MaximoDePosiciones) then begin
      if xpos=0 then begin
        for xpos:=1 to MaxPosCarga do
          TPosCarga[xpos].SwDesHabil:=True;
        Result:='True|';
      end
      else if (xpos in [1..maxposcarga]) then begin
        TPosCarga[xpos].SwDesHabil:=True;
        Result:='True|';
      end;
    end
    else Result:='False|Posicion no Existe|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.Desbloquear(msj: string): string;
var
  xpos:Integer;
begin
  try
    xpos:=StrToIntDef(msj,-1);

    if xpos<0 then begin
      Result:='False|Favor de indicar correctamente la posicion de carga|';
      Exit;
    end;

    if (xpos<=MaximoDePosiciones) then begin
      if xpos=0 then begin
        for xpos:=1 to MaxPosCarga do
          TPosCarga[xpos].SwDesHabil:=False;
        Result:='True|';
      end
      else if (xpos in [1..maxposcarga]) then begin
        TPosCarga[xpos].SwDesHabil:=False;
        Result:='True|';
      end;
    end
    else Result:='False|Posicion no Existe|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.Detener: string;
begin
  try
    if estado=-1 then begin
      Result:='False|El proceso no se ha iniciado aun|';
      Exit;
    end;

    if not detenido then begin
      pSerial.Open:=False;
      pSerial.Tracing:= tlOff;
      pSerial.Open:= false;
      pSerial.DTR:= false;
      pSerial.RTS:= false;
      Timer1.Enabled:=False;
      detenido:=True;
      estado:=0;
      Result:='True|';
    end
    else
      Result:='False|El proceso ya habia sido detenido|'
  except
    on e:Exception do
      Result:='False|'+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.GuardarLog: string;
begin
  try
    ListaLog.SaveToFile(rutaLog+'\LogDisp'+FiltraStrNum(FechaHoraToStr(Now))+'.txt');
    GuardarLogPetRes;
    Result:='True|'+rutaLog+'\LogDisp'+FiltraStrNum(FechaHoraToStr(Now))+'.txt|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.GuardarLogPetRes: string;
begin
  try
    ListaLogPetRes.SaveToFile(rutaLog+'\LogDispPetRes'+FiltraStrNum(FechaHoraToStr(Now))+'.txt');
    Result:='True|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.Iniciar: string;
begin
  try
    if (not pSerial.Open) then begin
      if (estado=-1) then begin
        Result:='False|No se han recibido los parametros de inicializacion|';
        Exit;
      end
      else if detenido then
        pSerial.Open:=True;
    end;

    detenido:=False;
    estado:=1;
    numPaso:=0;
    SwPasoBien:=true;
    PosCiclo:=1;
    swespera:=False;
    Timer1.Enabled:=True;
    Result:='True|';
  except
    on e:Exception do
      Result:='False|'+e.Message+'|';
  end;
end;
function Togcvdispensarios_kiros.Login(mensaje: string): string;
var
  usuario,password:string;
begin
  usuario:=ExtraeElemStrSep(mensaje,1,'|');
  password:=ExtraeElemStrSep(mensaje,2,'|');
  if MD5(usuario+'|'+FormatDateTime('yyyy-mm-dd',Date)+'T'+FormatDateTime('hh:nn',Now))<>password then
    Result:='False|Password invalido|'
  else begin
    Token:=MD5(usuario+'|'+FormatDateTime('yyyy-mm-dd',Date)+'T'+FormatDateTime('hh:nn',Now));
    Result:='True|'+Token+'|';
  end;
end;

function Togcvdispensarios_kiros.Logout: string;
begin
  Token:='';
  Result:='True|';
end;

function Togcvdispensarios_kiros.MD5(const usuario: string): string;
var
  idmd5:TIdHashMessageDigest5;
  hash:T4x4LongWordRecord;
begin
  idmd5 := TIdHashMessageDigest5.Create;
  hash := idmd5.HashValue(usuario);
  Result := idmd5.AsHex(hash);
  Result := AnsiLowerCase(Result);
  idmd5.Destroy;
end;

function Togcvdispensarios_kiros.ObtenerEstado: string;
begin
  Result:='True|'+IntToStr(estado)+'|';
end;

function Togcvdispensarios_kiros.Shutdown: string;
begin
  if estado>0 then
    Result:='False|El servicio esta en proceso, no fue posible detenerlo|'
  else begin
    ServiceThread.Terminate;
    Result:='True|';
  end;
end;

function Togcvdispensarios_kiros.EjecutaComando(xCmnd: string): integer;
var ind:integer;
begin
  // busca un registro disponible
  ind:=0;
  repeat
    inc(ind);
    if (TabCmnd[ind].SwActivo)and((now-TabCmnd[ind].hora)>tmMinuto) then begin
      TabCmnd[ind].SwActivo:=false;
      TabCmnd[ind].SwResp:=false;
      TabCmnd[ind].SwNuevo:=true;
    end;
  until (not TabCmnd[ind].SwActivo)or(ind>200);
  // Si no lo encuentra se sale
  if ind>200 then begin
    result:=0;
    exit;
  end;
  // envia el comando
  with TabCmnd[ind] do begin
    inc(FolioCmnd);
    if FolioCmnd<=0 then
      FolioCmnd:=1;
    Folio:=FolioCmnd;
    hora:=Now;
    SwActivo:=true;
    Comando:=xCmnd;
    SwResp:=false;
    Respuesta:='';
    TabCmnd[ind].SwNuevo:=true;
  end;
  Result:=FolioCmnd;
end;

function Togcvdispensarios_kiros.RespuestaComando(msj: string): string;
var
  resp:string;
begin
  try
    if StrToIntDef(msj,-1)=-1 then begin
      Result:='False|Favor de indicar correctamente el numero de folio de comando|';
      Exit;
    end;

    resp:=ResultadoComando(StrToInt(msj));

    if (UpperCase(Copy(resp,1,2))='OK') then begin
      if Length(resp)>2 then
        resp:=copy(resp,3,Length(resp)-2)
      else
        resp:='';
      Result:='True|'+resp;
    end
    else
      Result:='False|'+resp+'|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.ResultadoComando(xFolio: integer): string;
var i:integer;
begin
  Result:='*';
  for i:=1 to 40 do
    if (TabCmnd[i].folio=xfolio)and(TabCmnd[i].SwResp) then
      result:=TabCmnd[i].Respuesta;
end;

function Togcvdispensarios_kiros.ActivaModoPrepago(msj: string): string;
var
  xpos:Integer;
begin
  try
    xpos:=StrToIntDef(msj,-1);
    if xpos=-1 then begin
      Result:='False|Favor de indicar correctamente la posicion de carga|';
      Exit;
    end;

    if xpos=0 then begin
      for xpos:=1 to MaxPosCarga do
        TPosCarga[xpos].ModoOpera:='Prepago';
    end
    else if (xpos in [1..maxposcarga]) then
      TPosCarga[xpos].ModoOpera:='Prepago';

    Result:='True|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.DesactivaModoPrepago(msj: string): string;
var
  xpos:Integer;
begin
  try
    xpos:=StrToIntDef(msj,-1);
    if xpos=-1 then begin
      Result:='False|Favor de indicar correctamente la posicion de carga|';
      Exit;
    end;

    if xpos=0 then begin
      for xpos:=1 to MaxPosCarga do
        TPosCarga[xpos].ModoOpera:='Prepago';
    end
    else if (xpos in [1..maxposcarga]) then
      TPosCarga[xpos].ModoOpera:='Prepago';

    Result:='True|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.AgregaPosCarga(
  posiciones: TlkJSONbase): string;
begin
    //
end;

function Togcvdispensarios_kiros.EstadoPosiciones(msj: string): string;
var
  xpos:Integer;
begin
  try
    xpos:=StrToIntDef(msj,-1);
    if xpos<0 then begin
      Result:='False|Favor de indicar correctamente la posicion de carga|';
      Exit;
    end;

    if EstatusAct='' then begin
      Result:='False|Error de comunicacion|';
      Exit;
    end;    

    if xpos>0 then
      Result:='True|'+EstatusAct[xpos]+'|'
    else
      Result:='True|'+EstatusAct+'|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.ExtraeElemStrEnter(xstr: string;
  ind: word): string;
var i,cont,nc:word;
    ss:string;
begin
  xstr:=xstr+' ';
  cont:=1;ss:='';
  i:=1;nc:=length(xstr);
  while (cont<ind)and(i<nc) do begin
    if (xstr[i]=#13)and(xstr[i+1]=#10) then begin
      inc(i);
      inc(cont);
    end;
    inc(i);
  end;
  while (i<nc) do begin
    if (xstr[i]=#13)and(xstr[i+1]=#10) then
      i:=nc
    else ss:=ss+xstr[i];
    inc(i);
  end;
  result:=limpiastr(ss);
end;

function Togcvdispensarios_kiros.FinVenta(msj: string): string;
begin
  try
    if StrToIntDef(msj,-1)=-1 then begin
      Result:='False|Favor de indicar correctamente la posicion de carga|';
      Exit;
    end;

    Result:='True|'+IntToStr(EjecutaComando('FINV '+msj))+'|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.Inicializar(msj: string): string;
var
  js: TlkJSONBase;
  consolas,dispensarios,productos: TlkJSONbase;
  i,productID: Integer;
  datosPuerto,json,variables,variable:string;
begin
  try
    if estado>-1 then begin
      Result:='False|El servicio ya habia sido inicializado|';
      Exit;
    end;

    json:=ExtraeElemStrSep(msj,1,'|');
    variables:=ExtraeElemStrSep(msj,2,'|');

    js := TlkJSON.ParseText(json);
    consolas := js.Field['Consoles'];

    datosPuerto:=VarToStr(consolas.Child[0].Field['Connection'].Value);

    Result:=IniciaPSerial(datosPuerto);

    if Result<>'' then
      Exit;

    dispensarios := js.Field['Dispensers'];

    DecimalesGilbarco:=2;
    GtwDivPresetLts:=100;
    GtwDivPresetPesos:=100;
    GtwDivPrecio:=100;
    GtwDivImporte:=100;
    GtwDivLitros:=100;
    GtwDivTotLts:=100;
    GtwDivTotImporte:=100;
    GtwTimeout:=1000;
    GtwTiempoCmnd:=100;

    for i:=1 to NoElemStrEnter(variables) do begin
      variable:=ExtraeElemStrEnter(variables,i);
      if UpperCase(ExtraeElemStrSep(variable,1,'='))='DECIMALESGILBARCO' then
        DecimalesGilbarco:=StrToInt(ExtraeElemStrSep(variable,2,'='))
      else if UpperCase(ExtraeElemStrSep(variable,1,'='))='GTWDIVPRESETLTS' then
        GtwDivPresetLts:=StrToIntDef(ExtraeElemStrSep(variable,2,'='),100)
      else if UpperCase(ExtraeElemStrSep(variable,1,'='))='GTWDIVPRESETPESOS' then
        GtwDivPresetPesos:=StrToIntDef(ExtraeElemStrSep(variable,2,'='),100)
      else if UpperCase(ExtraeElemStrSep(variable,1,'='))='GTWDIVPRECIO' then
        GtwDivPrecio:=StrToIntDef(ExtraeElemStrSep(variable,2,'='),100)
      else if UpperCase(ExtraeElemStrSep(variable,1,'='))='GTWDIVIMPORTE' then
        GtwDivImporte:=StrToIntDef(ExtraeElemStrSep(variable,2,'='),100)
      else if UpperCase(ExtraeElemStrSep(variable,1,'='))='GTWDIVLITROS' then
        GtwDivLitros:=StrToIntDef(ExtraeElemStrSep(variable,2,'='),100)
      else if UpperCase(ExtraeElemStrSep(variable,1,'='))='GTWDIVTOTLTS' then
        GtwDivTotLts:=StrToIntDef(ExtraeElemStrSep(variable,2,'='),100)
      else if UpperCase(ExtraeElemStrSep(variable,1,'='))='GTWDIVTOTIMPORTE' then
        GtwDivTotImporte:=StrToIntDef(ExtraeElemStrSep(variable,2,'='),100)
      else if UpperCase(ExtraeElemStrSep(variable,1,'='))='GTWTIMEOUT' then
        GtwTimeout:=StrToIntDef(ExtraeElemStrSep(variable,2,'='),1000)
      else if UpperCase(ExtraeElemStrSep(variable,1,'='))='GTWTIEMPOCMND' then
        GtwTiempoCmnd:=StrToIntDef(ExtraeElemStrSep(variable,2,'='),100);
    end;

    Result:=AgregaPosCarga(dispensarios);

    if Result<>'' then
      Exit;

    productos := js.Field['Products'];

//    for i:=0 to productos.Count-1 do begin
//      productID:=productos.Child[i].Field['ProductId'].Value;
//      if productos.Child[i].Field['Price'].Value<0 then begin
//        Result:='False|El precio '+IntToStr(productID)+' es incorrecto|';
//        Exit;
//      end;
//      LPrecios[productID]:=productos.Child[i].Field['Price'].Value;
//    end;

    estado:=0;
    Result:='True|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.IniciaPrecios(msj: string): string;
begin
  try
    if EjecutaComando('CPREC '+msj)>0 then
      Result:='True|'
    else
      Result:='False|No fue posible aplicar comando de cambio de precios|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.IniciaPSerial(
  datosPuerto: string): string;
var
  puerto:string;
begin
  try
    if pSerial.Open then begin
      Result:='False|El puerto ya se encontraba abierto|';
      Exit;
    end;

    puerto:=ExtraeElemStrSep(datosPuerto,2,',');
    if Length(puerto)>=4 then begin
      if StrToIntDef(Copy(puerto,4,Length(puerto)-3),-99)=-99 then begin
        Result:='False|Favor de indicar un numero de puerto correcto|';
        Exit;
      end
      else
        pSerial.ComNumber:=StrToInt(Copy(puerto,4,Length(puerto)-3));
    end
    else begin
      if StrToIntDef(ExtraeElemStrSep(datosPuerto,2,','),-99)=-99 then begin
        Result:='False|Favor de indicar un numero de puerto correcto|';
        Exit;
      end
      else
        pSerial.ComNumber:=StrToInt(ExtraeElemStrSep(datosPuerto,2,','));
    end;

    if StrToIntDef(ExtraeElemStrSep(datosPuerto,3,','),-99)=-99 then begin
      Result:='False|Favor de indicar los baudios correctos|';
      Exit;
    end
    else
      pSerial.Baud:=StrToInt(ExtraeElemStrSep(datosPuerto,3,','));

    if ExtraeElemStrSep(datosPuerto,4,',')<>'' then begin
      case ExtraeElemStrSep(datosPuerto,4,',')[1] of
        'N':pSerial.Parity:=pNone;
        'E':pSerial.Parity:=pEven;
        'O':pSerial.Parity:=pOdd;
        else begin
          Result:='False|Favor de indicar una paridad correcta [N,E,O]|';
          Exit;
        end;
      end;
    end
    else begin
      Result:='False|Favor de indicar una paridad [N,E,O]|';
      Exit;
    end;

    if StrToIntDef(ExtraeElemStrSep(datosPuerto,5,','),-99)=-99 then begin
      Result:='False|Favor de indicar los bits de datos correctos|';
      Exit;
    end
    else
      pSerial.DataBits:=StrToInt(ExtraeElemStrSep(datosPuerto,5,','));

    if StrToIntDef(ExtraeElemStrSep(datosPuerto,6,','),-99)=-99 then begin
      Result:='False|Favor de indicar los bits de paro correctos|';
      Exit;
    end
    else
      pSerial.StopBits:=StrToInt(ExtraeElemStrSep(datosPuerto,6,','));

    pSerial.TraceAllHex:= true;
    pSerial.TraceName:= 'c:\OGTrace.txt';
    pSerial.Tracing:= tlOn;
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.NoElemStrEnter(xstr: string): word;
var i,cont,nc:word;
begin
  xstr:=xstr+' ';
  cont:=1;
  i:=1;nc:=length(xstr);
  while (i<nc) do begin
    if (xstr[i]=#13)and(xstr[i+1]=#10) then begin
      inc(i);
      inc(cont);
    end;
    inc(i);
  end;
  result:=cont;
end;

function Togcvdispensarios_kiros.ObtenerLog(r: Integer): string;
var
  i:Integer;
begin
  if r=0 then begin
    Result:='False|No se indico el numero de registros|';
    Exit;
  end;

  if ListaLog.Count<1 then begin
    Result:='False|No hay registros en el log|';
    Exit;
  end;

  i:=ListaLog.Count-(r+1);
  if i<1 then i:=0;

  Result:='True|';

  for i:=i to ListaLog.Count-1 do
    Result:=Result+ListaLog[i]+'|';
end;

function Togcvdispensarios_kiros.ObtenerLogPetRes(r: Integer): string;
var
  i:Integer;
begin
  if r=0 then begin
    Result:='False|No se indico el numero de registros|';
    Exit;
  end;

  if ListaLogPetRes.Count<1 then begin
    Result:='False|No hay registros en el log de peticiones|';
    Exit;
  end;

  i:=ListaLogPetRes.Count-(r+1);
  if i<1 then i:=0;

  Result:='True|';

  for i:=i to ListaLogPetRes.Count-1 do
    Result:=Result+ListaLogPetRes[i]+'|';
end;

function Togcvdispensarios_kiros.Terminar: string;
begin
  if estado>0 then
    Result:='False|El servicio no esta detenido, no es posible terminar la comunicacion|'
  else begin
    Timer1.Enabled:=False;
    pSerial.Open:=False;
    estado:=-1;
    Result:='True|';
  end;
end;

function Togcvdispensarios_kiros.TotalesBomba(msj: string): string;
var
  xpos,xfolioCmnd:Integer;
  valor:string;
begin
  try
    xpos:=StrToIntDef(msj,-1);
    if xpos<1 then begin
      Result:='False|Favor de indicar correctamente la posicion de carga|';
      Exit;
    end;

    xfolioCmnd:=EjecutaComando('TOTAL'+' '+IntToStr(xpos));

    valor:=IfThen(xfolioCmnd>0, 'True', 'False');

    Result:=valor+'|0|0|0|0|0|0|'+IntToStr(xfolioCmnd)+'|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.TransaccionPosCarga(msj: string): string;
var
  xpos:Integer;
begin
  try
    xpos:=StrToIntDef(msj,-1);
    if xpos<0 then begin
      Result:='False|Favor de indicar correctamente la posicion de carga|';
      Exit;
    end;

    if xpos>MaxPosCarga then begin
      Result:='False|La posicion de carga no se encuentra registrada|';
      Exit;
    end;

//    with TPosCarga[xpos] do
//      Result:='True|'+FormatDateTime('yyyy-mm-dd',HoraOcc)+'T'+FormatDateTime('hh:nn',HoraOcc)+'|'+IntToStr(MangActual)+'|'+IntToStr(CombActual)+'|'+
//              FormatFloat('0.000',volumen)+'|'+FormatFloat('0.00',precio)+'|'+FormatFloat('0.00',importe)+'|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.AutorizarVenta(msj: string): string;
var
  cmd,cantidad,posCarga,comb,finv:string;
begin
  try

    if StrToFloatDef(ExtraeElemStrSep(msj,4,'|'),0)>0 then begin
      cmd:='OCL';
      cantidad:=ExtraeElemStrSep(msj,4,'|');
    end
    else if StrToFloatDef(ExtraeElemStrSep(msj,3,'|'),-99)<>-99 then begin
      cmd:='OCC';
      cantidad:=ExtraeElemStrSep(msj,3,'|');
    end
    else begin
      Result:='False|Favor de indicar la cantidad que se va a despachar|';
      Exit;
    end;

    posCarga:=ExtraeElemStrSep(msj,1,'|');

    if posCarga='' then begin
      Result:='False|Favor de indicar la posicion de carga|';
      Exit;
    end;

    comb:=ExtraeElemStrSep(msj,2,'|');

    if comb='' then
      comb:='00';

    finv:=ExtraeElemStrSep(msj,5,'|');

    if finv='0' then
      finv:='1'
    else
      finv:='0';

    Result:='True|'+IntToStr(EjecutaComando(cmd+' '+posCarga+' '+cantidad+' '+comb+' '+finv))+'|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.DetenerVenta(msj: string): string;
begin
  try
    if StrToIntDef(msj,-1)=-1 then begin
      Result:='False|Favor de indicar correctamente la posicion de carga|';
      Exit;
    end;

    Result:='True|'+IntToStr(EjecutaComando('DVC '+msj))+'|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

function Togcvdispensarios_kiros.ReanudarVenta(msj: string): string;
begin
  try
    if StrToIntDef(msj,-1)=-1 then begin
      Result:='False|Favor de indicar correctamente la posicion de carga|';
      Exit;
    end;

    Result:='True|'+IntToStr(EjecutaComando('REANUDAR '+msj))+'|';
  except
    on e:Exception do
      Result:='False|Excepcion: '+e.Message+'|';
  end;
end;

end.
