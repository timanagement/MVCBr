{ //************************************************************// }
{ //         Projeto MVCBr                                      // }
{ //         tireideletra.com.br  / amarildo lacerda            // }
{ //************************************************************// }
{ // Data: 03/03/2017                                           // }
{ //************************************************************// }
unit WS.Datamodule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Phys, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL,
{$IFDEF LINUX}
  FireDAC.CONSOLEUI.Wait,
{$ELSE}
  FireDAC.VCLUI.Wait,
  FireDAC.Phys.MSAcc,
  FireDAC.Phys.MSAccDef,
  FireDAC.Comp.UI,
{$ENDIF}
  FireDAC.DApt, FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL, FireDAC.Comp.Client,
  FireDAC.Phys.IBBase, Data.DB, FireDAC.Phys.PGDef, FireDAC.Phys.PG;

type
  TWSDatamodule = class(TDataModule)
    procedure FDManager1AfterLoadConnectionDefFile(Sender: TObject);
  private
    { Private declarations }
    procedure AfterConstruction; override;
  public
    { Public declarations }
  end;

  TFDQueryAuto = class(TFDQuery)
  public
    constructor create(AOwner: TComponent); override;
  end;

var
  WSDatamodule: TWSDatamodule;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }
// uses FireDAC.Adpt;
uses System.SyncObjs, WS.Common;

{$R *.dfm}

var
  ConnectionStrings: string;
{$IFDEF LINUX}
{$ELSE}
  FDGUIxWaitCursor1: TFDGUIxWaitCursor;
{$ENDIF}
  FDConnection1: TFDConnection;
  FDPhysFBDriverLink1: TFDPhysFBDriverLink;
  FDSchemaAdapter1: TFDSchemaAdapter;
  FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
  FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
  FDPhysPgDriverLink1: TFDPhysPgDriverLink;

  FDManager1: TFDManager;

procedure TWSDatamodule.AfterConstruction;
begin
  inherited;

 /// inicializa a estrutura do FireDAC
  FDConnection1 := TFDConnection.create(self);
  ConnectionStrings := FDConnection1.Params.Text;
  FDPhysFBDriverLink1 := TFDPhysFBDriverLink.create(self);
  FDSchemaAdapter1 := TFDSchemaAdapter.create(self);
  FDPhysMySQLDriverLink1 := TFDPhysMySQLDriverLink.create(self);
  FDPhysMSSQLDriverLink1:= TFDPhysMSSQLDriverLink.create(self);
  FDPhysPgDriverLink1:= TFDPhysPgDriverLink.create(self);

  FDManager1 := TFDManager.create(self);
{$IFDEF MSWINDOWS}
  FDGUIxWaitCursor1 := TFDGUIxWaitCursor.create(self);
{$ENDIF}
  /// conex�o default - sera trocado pela configura��o de usuario
  FDConnection1.ConnectionName := 'MVCBr_DB';
  FDConnection1.driverName := 'FB';

end;

procedure TWSDatamodule.FDManager1AfterLoadConnectionDefFile(Sender: TObject);
begin

end;

{ TFDQueryAuto }
var
  LQueryCount: Integer = 0;

constructor TFDQueryAuto.create(AOwner: TComponent);
var
  old: char;
begin
  inherited;
  ConnectionName := 'MVCBr_DB';
  TInterlocked.Add(LQueryCount, 0);

  name := '__query__' + LQueryCount.ToString;
  Connection := FDManager.AcquireConnection(ConnectionName, name);
  if Connection.Params.count = 0 then
  begin

  {  /// default de inicialzia��o
    Connection.Params.values['driverid'] := 'FB';
    Connection.Params.values['server'] := 'localhost';
    Connection.Params.values['database'] := 'mvcbr';
    Connection.Params.values['user_name'] := 'sysdba';
    Connection.Params.values['password'] := 'masterkey';
  }

    assert(WSConnectionString<>'','Falta configurar a conex�o de banco de dados');

    /// pega a configura��o de usuario
    if WSConnectionString <> '' then
    begin
      old := Connection.Params.Delimiter;
      try
        Connection.Params.Delimiter := ';';
        Connection.Params.DelimitedText := WSConnectionString;
      finally
        Connection.Params.Delimiter := old;
      end;
    end;

  end;
end;

end.
