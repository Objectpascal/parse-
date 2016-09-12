unit Operations;

interface

uses classes, sysutils;

type
  Toperator = record
    ch: string;
    priority: integer;
    NumArg: integer;
  end;

const
 ArrOperator: array [0 .. 11] of Toperator =
  (
     (ch: '^'; priority: 3; NumArg: 2)
    ,(ch: '*'; priority: 2; NumArg: 2)
    ,(ch: '/'; priority: 2; NumArg: 2)
    ,(ch: '+'; priority: 1; NumArg: 2)
    ,(ch: '-'; priority: 1; NumArg: 2)
    ,(ch: 'sqrt'; priority: 3; NumArg: 1)
    ,(ch: 'cos'; priority: 3; NumArg: 1)
    ,(ch: 'sin'; priority: 3; NumArg: 1)
    ,(ch:'exp';priority:3;NumArg:1)
    ,(ch:'tan';priority:3;NumArg:1)
    ,(ch:'ln';priority:3;NumArg:1)
    ,(ch:'pi';priority:3;NumArg:0)

    );

type
  TArrStack = array of string;

  TstackClass = class
  private
    FStack: TStringList;
    Ftop: integer;
  public
    procedure move(from_index, to_index: integer);
    procedure clearStack();
    procedure Push(const val: string);
    function getString(index: integer): string;
    function pop(): string;
    function getTop: integer;
    function isEmpty(): boolean;
    constructor create();
    destructor Destroy; override;
  end;

  TequationParsing = class
  private
    FStack: TstackClass;
    Fpostfin: TstackClass;
    Fstr: string;
    function getOperationMethod(const op: string; num1: double;
      num2: double = 0): double;
    function isOperation(op: string): boolean;
    function getEndOfNumber(const str: string; strPos: integer): integer;
    function isOperation_haveArg(op: string; NumArgs: integer): boolean;
    procedure CalcOperation(op: string);
    procedure addOperation(op: string);
    function getpriority(op: string): integer;
    procedure MoveToPostfin();

    procedure Fix_Input();
  public
    constructor create(str: string);
    procedure fill();
    procedure CalcResult();
    procedure setNewString(const str: string);
    procedure displayStack;
    procedure DisplayPostfin;
    destructor Destroy; override;

  end;

implementation

uses math;
{ TstackClass }

procedure TstackClass.clearStack;
begin
  FStack.Clear;
  Ftop := -1;
end;

constructor TstackClass.create;
begin
  FStack := TStringList.create();
  Ftop := -1;

end;

destructor TstackClass.Destroy;
begin
  if Assigned(FStack) then
    FreeAndNil(FStack);
  inherited;
end;

function TstackClass.getString(index: integer): string;
begin
  result := '';
  if isEmpty then
    raise Exception.create('Stack is Empty');
  result := FStack[index];
end;

function TstackClass.getTop: integer;
begin
  result := Ftop;
end;

procedure TstackClass.move(from_index, to_index: integer);
begin
  FStack.move(from_index, to_index);
end;

function TstackClass.isEmpty: boolean;
begin
  result := (Ftop <= -1);

end;

function TstackClass.pop: string;
var
  res: string;
begin
  if isEmpty() then
    raise Exception.create('Empty Satck pop');
  res := FStack[Ftop];
  FStack.Delete(Ftop);
  Dec(Ftop);
  result := res;
end;

procedure TstackClass.Push(const val: string);
begin
  inc(Ftop, 1);
  FStack.Add(val);
end;

{ TequationParsing }

procedure TequationParsing.addOperation(op: string);
var
  op_p: integer;
  r_p: integer;
  r_op: string;

begin
  op_p := getpriority(op);
  r_p := getpriority(FStack.getString(FStack.getTop));
  if (op_p > r_p) or (r_p = -1) then
    FStack.Push(op)
  else
  begin
    r_op := FStack.pop;
    Fpostfin.Push(r_op);
    addOperation(op);
  end;
end;

procedure TequationParsing.CalcOperation(op: string);
var
  Strnum2, Strnum1: string;
  num1_Val, num2_Val: double;
  res: double;
begin

 res:=0;
 if isOperation_haveArg(op, 0) then
  begin
    res := getOperationMethod(op,0);
  end
  else
  if isOperation_haveArg(op, 1) then
  begin
    Strnum1 := FStack.pop;
    num1_Val := StrToFloat(Strnum1);
    res := getOperationMethod(op, num1_Val);
  end
  else
  if isOperation_haveArg(op, 2) then
  begin
    try
    Strnum1 := FStack.pop;
    num1_Val := StrToFloat(Strnum1);
    if not FStack.isEmpty then
      Strnum2 := FStack.pop;
      if trim(Strnum2)='' then
        num2_Val:=0
      else
        num2_Val := StrToFloat(Strnum2);
    except
      num2_Val:=0;

    end;
    res := getOperationMethod(op,num2_Val,num1_Val);
  end;

    FStack.Push(FloatToStr(res));
end;

procedure TequationParsing.CalcResult;
var
  count: integer;
  max: integer;
  val: string;

begin
  fill();
  max := Fpostfin.getTop;
  for count := 0 to max do
  begin
    val := Fpostfin.getString(count);
    if isOperation(val) then
    begin
      // writeln('add op:',val);
      CalcOperation(val);
    end
    else
    begin
      FStack.Push(val);
      // displayStack
    end;
  end;
end;

constructor TequationParsing.create(str: string);
begin
  inherited create;
  FStack := TstackClass.create;
  Fpostfin := TstackClass.create;
  setNewString(str);
end;

destructor TequationParsing.Destroy;
begin
  if Assigned(FStack) then
    FreeAndNil(FStack);
  if Assigned(Fpostfin) then
    FreeAndNil(Fpostfin);
  inherited;
end;

procedure TequationParsing.DisplayPostfin;
var
  top: integer;
begin
  top := Fpostfin.getTop;
  writeln;
  writeln('-----------------Dislpay postfin----------------');
  while (top >= 0) do
  begin
    writeln(Format('[%d] -> %s', [top, Fpostfin.getString(top)]));
    Dec(top, 1);
  end;

end;

procedure TequationParsing.displayStack;
var
  top: integer;
begin
  top := FStack.getTop;
  writeln;
  writeln('-----------------Dislpay Stack----------------');
  while (top >= 0) do
  begin
    writeln(Format('[%d] -> %s', [top, FStack.getString(top)]));
    Dec(top, 1);
  end;

end;

procedure TequationParsing.fill;
var
  val: string;
  copyStr: string;
  pos_index: integer;
  len_index: integer;
  count: integer;
begin
  FStack.clearStack;
  Fpostfin.clearStack;
  copyStr := Fstr;
  while copyStr <> '' do
  begin
    pos_index := 1;
    len_index := 1;
    val := Copy(copyStr, pos_index, len_index);
    if isOperation(val) then
    begin
      writeln('add op:', val);
      addOperation(val);
    end
    else if (val = '(') or (val = ')') then
    begin
      if val = '(' then
        FStack.Push(val)
      else
        MoveToPostfin();
    end
    else
    begin
      len_index := getEndOfNumber(copyStr, pos_index + 1);

      val := Copy(copyStr, pos_index, len_index);
      if isOperation(val) then
      begin
        writeln('add op:', val);
        addOperation(val);
      end
      else
        Fpostfin.Push(val);
    end;

    copyStr := Copy(copyStr, len_index + 1, length(copyStr));
  end;
end;

procedure TequationParsing.Fix_Input;
begin
  { TODO : fix input bug }

end;

function TequationParsing.getEndOfNumber(const str: string;
  strPos: integer): integer;
var
  count: integer;
  val: string;
begin
  result := -1;
  for count := strPos to length(str) do
  begin
    val := str[count];
    if isOperation(val) or (val = '(') or (val = ')') then
    begin
      result := count - 1;
      break;
    end;
  end;
end;

function TequationParsing.getOperationMethod(const op: string;
  num1, num2: double): double;

begin
  result := 0;
  if op = '+' then
    result := num1 + num2
  else if op = '-' then
    result := num1 - num2
  else if op = '*' then
    result := num1 * num2
  else if op = '/' then
    result := num1 / num2
  else if op = '^' then
    result := power(num1, num2)
  else if UpperCase(op) = 'SQRT' then
  begin
    result := sqrt(num1);
  end
  else if UpperCase(op) = 'COS' then
  begin
    result := cos(num1);
  end
  else if UpperCase(op) = 'SIN' then
  begin
    result := sin(num1);
  end
  else if UpperCase(op) = 'EXP' then
  begin
    result := exp(num1);
  end
  else if UpperCase(op) = 'TAN' then
  begin
    result := Tan(num1);
  end
   else if UpperCase(op) = 'PI' then
  begin
    result := pi;
  end
  else if UpperCase(op) = 'LN' then
  begin
    result := ln(num1);
  end;
end;

function TequationParsing.getpriority(op: string): integer;
var
  count: integer;
begin
  result := -1;
  for count := Low(ArrOperator) to High(ArrOperator) do
    if (ArrOperator[count].ch = op) then
    begin
      result := ArrOperator[count].priority;
      break;
    end;
end;

function TequationParsing.isOperation(op: string): boolean;
var
  count: integer;
begin
  result := false;
  for count := low(ArrOperator) to High(ArrOperator) do
  begin
    if UpperCase(ArrOperator[count].ch) = UpperCase(op) then
    begin
      result := true;
      break;
    end;
  end;
end;

function TequationParsing.isOperation_haveArg(op: string;
  NumArgs: integer): boolean;
var
  count: integer;
begin
  result := false;
  for count := Low(ArrOperator) to High(ArrOperator) do
  begin
    if UpperCase(ArrOperator[count].ch) = UpperCase(op) then
    begin
      result := ArrOperator[count].NumArg = NumArgs;
      break;
    end;

  end;

end;

procedure TequationParsing.MoveToPostfin();
var
  popString: string;
begin
  popString := FStack.pop;
  while (popString <> '(') do
  begin
    Fpostfin.Push(popString);
    popString := FStack.pop;
  end;

end;

procedure TequationParsing.setNewString(const str: string);
begin
  FStack.clearStack;
  Fpostfin.clearStack;
  Fstr := str;
  Fix_Input();
end;

end.
