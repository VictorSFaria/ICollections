unit Generics.ICollections;

interface

uses
  System.SysUtils,
  System.Generics.Defaults;

type
  IEnumerator<T> = interface
    function GetCurrent: T;
    property Current: T read GetCurrent;
    function MoveNext: Boolean;
  end;

  IEnumerable<T> = interface
    function GetEnumerator: IEnumerator<T>;
  end;

  IList<T> = interface(IEnumerable<T>)
    ['{5A627266-1B07-4348-8E3B-547D8F8EDE6D}']
    function GetItem(Index: Integer): T;
    procedure SetItem(Index: Integer; const Value: T);
    function Add(const Value: T): Integer;
    function Contains(const Value: T): Boolean;
    function First: T;
    function Last: T;
    function Remove(const Value: T): Integer;
    function IndexOf(const Value: T): Integer;
    procedure Clear;
    function GetCapacity: Integer;
    procedure SetCapacity(Value: Integer);
    function GetCount: Integer;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: T read GetItem write SetItem; default;
  end;

  TIntList<T> = class(TInterfacedObject, IList<T>)
  strict private
    FITems: array of T;
    FCount: Integer;
    FCapacity: Integer;
    FComparer: IComparer<T>;
    procedure Resize(NewSize: Integer);
    function GetCapacity: Integer;
    procedure SetCapacity(Value: Integer);
    function GetCount: Integer;
    function GetItem(Index: Integer): T;
    procedure SetItem(Index: Integer; const Value: T);
  public
    constructor Create; overload;
    constructor Create(Capacity: Integer); overload;
    constructor Create(Capacity: Integer; Comparer: IComparer<T>); overload;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: T read GetItem write SetItem; default;
    function IndexOf(const Value: T): Integer;
    function Add(const Value: T): Integer;
    function Contains(const Value: T): Boolean;
    procedure Clear;
    function First: T;
    function Last: T;
    function Remove(const Value: T): Integer;
    function GetEnumerator: IEnumerator<T>;

    type
      TEnumerator = class(TInterfacedObject, IEnumerator<T>)
      private
        FList: IList<T>;
        FIndex: Integer;
        function GetCurrent: T;
      public
        constructor Create(List: IList<T>);
        property Current: T read GetCurrent;
        function MoveNext: Boolean;
      end;
  end;

implementation

uses
  System.RTLConsts;


function TIntList<T>.Add(const Value: T): Integer;
begin
  if FCapacity <= FCount then begin
    if FCapacity = 0 then begin
      Capacity := 1;
    end
    else begin
      Capacity := FCapacity * 2;
    end;
  end;
  FITems[FCount] := Value;
  Inc(FCount);
end;

procedure TIntList<T>.Clear;
begin
  FillChar(FItems[Count], SizeOf(T), 0);
  FCount := 0;
end;

function TIntList<T>.Contains(const Value: T): Boolean;
begin
  Result := IndexOf(Value) >= 0;
end;

constructor TIntList<T>.Create(Capacity: Integer; Comparer: IComparer<T>);
begin
  inherited Create;
  FCount := 0;
  Self.Capacity := Capacity;
  FComparer := Comparer;
end;

constructor TIntList<T>.Create(Capacity: Integer);
begin
  Create(Capacity, TComparer<T>.Default);
end;

function TIntList<T>.First: T;
begin
  if Count > 0 then begin
    Result := FItems[0];
  end;
end;

constructor TIntList<T>.Create;
begin
  Create(0, TComparer<T>.Default);
end;

function TIntList<T>.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TIntList<T>.GetCount: Integer;
begin
  Result := FCount;
end;

function TIntList<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := TIntList<T>.TEnumerator.Create(Self);
end;

function TIntList<T>.GetItem(Index: Integer): T;
begin
  if (Index >= FCount) or (Index < 0) then begin
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  end;
  Result := FITems[Index];
end;

function TIntList<T>.IndexOf(const Value: T): Integer;
var
  i: Integer;
  found: Boolean;
begin
  i := -1;
  found := False;
  while (i < FCount) and not found do begin
    Inc(i);
    found := FComparer.Compare(FITems[i], Value) = 0;
  end;

  if found then begin
    Result := i;
  end
  else begin
    Result := -1;
  end;
end;

function TIntList<T>.Last: T;
begin
  Result := FITems[Count - 1];
end;

function TIntList<T>.Remove(const Value: T): Integer;
var
  index: Integer;
begin
  index := IndexOf(Value);
  if (index > -1) then begin
    //Force lose of reference to desalocate memory
    FItems[index] := Default(T);
    System.Move(FItems[index + 1], FItems[index], (Count - index) * SizeOf(T));
    FillChar(FItems[Count], SizeOf(T), 0);
    Dec(FCount);
  end;
end;

procedure TIntList<T>.Resize(NewSize: Integer);
var
  newAllocation: Integer;
begin
  // Based on Python Implementation
  if (FCapacity >= NewSize) then begin
    exit;
  end;

  newAllocation := (newsize Shr 3);
  if newsize < 9 then
    newAllocation := newAllocation + 3
  else
    newAllocation := newAllocation + 6;

  FCapacity := NewSize + newAllocation;
  SetLength(FITems, FCapacity);
end;

procedure TIntList<T>.SetCapacity(Value: Integer);
begin
  Resize(Value);
end;

procedure TIntList<T>.SetItem(Index: Integer; const Value: T);
begin
  if Index >= FCount then begin
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  end;
  FITems[Index] := Value;
end;

{ TIntList<T>.TEnumerator<T> }

constructor TIntList<T>.TEnumerator.Create(List: IList<T>);
begin
  FList := List;
  FIndex := -1;
end;

function TIntList<T>.TEnumerator.GetCurrent: T;
begin
  Result := FList[FIndex];
end;

function TIntList<T>.TEnumerator.MoveNext: Boolean;
begin
  if (FIndex < FList.Count - 1)  then begin
    Inc(FIndex);
    Result := True;
  end
  else begin
    Result := False;
  end;
end;

end.
