program Project1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Operations in 'Operations.pas';
var
  ep:TequationParsing;
  count:integer;
  dd:string;
begin
try

  ep:=TequationParsing.create('');

  repeat
  write('-->');
  readln(dd);
  ep.setNewString('('+dd+')');
  ep.CalcResult;
  ep.displayStack;
  ep.DisplayPostfin;
  until UpperCase(dd)='Q';

  finally
    FreeAndNil(ep);
  end;
 readln;
end.
