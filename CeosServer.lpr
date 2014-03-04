{********************************************************}
{ CeosServer - FastCGI Application Server                }
{                                                        }
{ Copyright (c) 2013 JBS Soluções.                       }
{                                                        }
{********************************************************}
program CeosServer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, memdslaz, umain, cwinsrvc, uapps, uappform, userverconfig
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

