unit Principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Integra.Onvio;

type
  TForm4 = class(TForm)
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    Button2: TButton;
    edCode: TEdit;
    edToken: TEdit;
    edRefreshToken: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button3: TButton;
    Label4: TLabel;
    Memo1: TMemo;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edCallbackURL: TEdit;
    edUsername: TEdit;
    edPassword: TEdit;
    cbAmbiente: TComboBox;
    Label8: TLabel;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    FOnvio : TIntegraOnvio;
  public
    { Public declarations }
    procedure OnExecuteReq(aRequestType : TRequestType;aResponse : String; aStatusCode : Integer);
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

procedure TForm4.Button1Click(Sender: TObject);
begin
  Memo1.Text :=
    FOnvio
      .callbackURI(edCallbackURL.Text)
      .ClientID(edUsername.Text)
      .ClientSecret(edPassword.Text)
      .GetAuth
      .Format;

  edToken.Text := FOnvio.Token;
  edRefreshToken.Text := FOnvio.RefreshToken;
end;

procedure TForm4.Button2Click(Sender: TObject);
begin
  FOnvio
    .Ambiente(TAmbiente(cbAmbiente.ItemIndex))
    .Login;

  edCode.Text := FOnvio.Code;
end;

procedure TForm4.Button3Click(Sender: TObject);
var
  Msg : String;
begin
  if OpenDialog1.Execute then
    begin
      FOnvio.Token := edToken.Text;
      FOnvio.RefreshToken := edRefreshToken.Text;

      if FOnvio.SendFile(OpenDialog1.FileName, Msg) then
        Memo1.Lines.Add('Sucesso:' + Msg)
      else
        Memo1.Lines.Add('Erro:' + Msg);
    end;
end;

procedure TForm4.Button4Click(Sender: TObject);
var
  vID, CallBackStr : String;
begin
  if InputQuery('Digite o ID', 'ID:', vID) then
    begin
      if FOnvio.StatusFile(vID, CallBackStr) then
        Memo1.Lines.Add('Sucesso: ' +CallBackStr)
      else
        Memo1.Lines.Add('Erro: ' +CallBackStr);
    end;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  FOnvio := TIntegraOnvio.Create;
  FOnvio.onExecuteRequest := OnExecuteReq;

  cbAmbiente.ItemIndex := 0;
end;

procedure TForm4.FormDestroy(Sender: TObject);
begin
  FOnvio.Free;
end;

procedure TForm4.OnExecuteReq(aRequestType: TRequestType; aResponse: String;
  aStatusCode: Integer);
begin
  case aRequestType of
    rtLogin: Memo1.Lines.Add('rtLogin');
    rtGetToken: Memo1.Lines.Add('rtGetToken');
    rtRefreshToken: Memo1.Lines.Add('rtRefreshToken');
    rtSendFile: Memo1.Lines.Add('rtSendFile');
    rtReadStatusFile: Memo1.Lines.Add('rtReadStatusFile');
  end;

  Memo1.Lines.Add(aResponse);

  Label4.Caption := aStatusCode.ToString;
end;

end.