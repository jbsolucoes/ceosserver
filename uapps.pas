{********************************************************}
{ CeosServer Apps Form                                   }
{                                                        }
{ Copyright (c) 2013 JBS Soluções.                       }
{                                                        }
{********************************************************}
unit uapps;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, memds, FileUtil, Forms, Controls, Graphics, Dialogs,
  Buttons, ExtCtrls, DBGrids;

type

  { TfrmApps }

  TfrmApps = class(TForm)
    Datasource1: TDatasource;
    DBGrid1: TDBGrid;
    dstApps: TMemDataset;
    Panel1: TPanel;
    spAdd: TSpeedButton;
    spEdit: TSpeedButton;
    spDelete: TSpeedButton;
    procedure DBGrid1DblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure spAddClick(Sender: TObject);
    procedure spEditClick(Sender: TObject);
    procedure spDeleteClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure LoadConfig;
    procedure SaveConfig;

  end;

var
  frmApps: TfrmApps;

implementation

uses uappform;

{$R *.lfm}

{ TfrmApps }

procedure TfrmApps.FormCreate(Sender: TObject);
begin
  dstApps.CreateTable;
  dstApps.open;

  LoadConfig;
end;

procedure TfrmApps.spAddClick(Sender: TObject);
begin
  dstApps.append;
  application.createform(TfrmAppForm,frmAppForm);
  frmAppForm.showmodal;
  frmAppForm.free;
  frmAppForm := nil;
end;

procedure TfrmApps.spEditClick(Sender: TObject);
begin
  dstApps.edit;
  application.createform(TfrmAppForm,frmAppForm);
  frmAppForm.showmodal;
  frmAppForm.free;
  frmAppForm := nil;
end;

procedure TfrmApps.spDeleteClick(Sender: TObject);
begin
  if messagedlg('Delete application configuration?',mtConfirmation,[mbYes,mbNo],0) = mrNo then
    exit;

  dstApps.delete;
end;

procedure TfrmApps.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveConfig;
end;

procedure TfrmApps.DBGrid1DblClick(Sender: TObject);
begin
  spEdit.click;
end;

procedure TfrmApps.LoadConfig;
var
  i, iPosEnd: Integer;
  sDirConfig: string;
  sAlias, sApp, sAux: string;
  slConfig: TStringlist;
begin
  try
    sDirConfig := '';

    slConfig := TStringlist.create;

    dstApps.Close;
    dstApps.open;

    if fileexists(extractfilepath(paramstr(0)) + 'ceosapps.conf') then
      slConfig.loadfromfile(extractfilepath(paramstr(0)) + 'ceosapps.conf');

    for i := 0 to slConfig.count -1 do
    begin
      if Pos('ScriptAlias', slConfig[i]) > 0 then
      begin
        sAux := copy(slConfig[i],Pos('/',slConfig[i]) +1,length(slConfig[i]) -1);

        iPosEnd := Pos(' ',sAux);

        sAlias := copy(sAux,0,iPosEnd);

        sApp := stringreplace(copy(sAux,iPosEnd + 1,length(sAux) -1),'"','',[rfReplaceAll]);

        dstApps.append;
        dstApps.fields[0].value := trim(sAlias);
        dstApps.fields[1].value := trim(stringreplace(sApp,'/','\',[rfReplaceAll]));
        dstApps.post;
      end;
    end;

  finally
    freeandnil(slConfig);
  end;

end;

procedure TfrmApps.SaveConfig;
var
  slConfig: TStringlist;
  sDir, sAlias, sApps: string;
begin
  try
    slConfig := TStringlist.create;

    slConfig.Add('#CeosServer Applications Settings');

    slConfig.Add('<IfModule mod_fcgid.c>');
    slConfig.Add('');

    dstApps.first;

    while not dstApps.eof do
    begin
      sDir := trim(stringreplace(extractfilepath(dstApps.fields[1].value),'\','/',[rfReplaceAll])) ;

      if Pos(format('<Directory "%s">',[sDir]),slConfig.text) <= 0 then
      begin
        slConfig.Add(format('  <Directory "%s">',[sDir]));
        slConfig.Add('    SetHandler fcgid-script');
        slConfig.Add('    Order allow,deny');
        slConfig.Add('    Allow from all');
        slConfig.Add('  </Directory>');
        slConfig.Add('');
      end;

      sAlias := dstApps.fields[0].value;
      sApps  := stringreplace(dstApps.fields[1].value,'\','/',[rfReplaceAll]);

      slConfig.Add(format('  #%s App',[sAlias]));
      slConfig.Add(format('  ScriptAlias /%s "%s"',[sAlias,trim(sApps)]));
      slConfig.Add('');

      dstApps.next;
    end;

    slConfig.Add('');
    slConfig.Add('</IfModule>');
  finally
    slConfig.savetofile(extractfilepath(paramstr(0)) + 'ceosapps.conf');
    freeandnil(slConfig);
  end;

end;

end.

