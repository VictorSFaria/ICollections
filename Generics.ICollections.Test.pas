unit Generics.ICollections.Test;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TIListTest = class
  public
    [Test]
    procedure ListInitialization;
    [Test]
    procedure AddElements;
    [Test]
    procedure FindElements;
    [Test]
    procedure RemoveLastElement;
    [Test]
    procedure RemoveFirstElement;
    [Test]
    procedure RemoveMiddleElement;
    [Test]
    procedure RemoveNonExistingElement;
    [Test]
    procedure AccessByIndex;
    [Test]
    procedure IndexOf;
    [Test]
    procedure Iterator;
  end;

implementation

{ TIListTest }

uses
  Generics.ICollections,
  Winapi.Windows,
  SysUtils;

procedure TIListTest.AccessByIndex;
var
  list: IList<String>;
begin
  list := TIntList<String>.Create;
  list.Add('hello');
  list.Add('world');
  list.Add('!!!');
  Assert.AreEqual<String>(list[0], 'hello');
  Assert.AreEqual<String>(list[1], 'world');
  Assert.AreEqual<String>(list[2], '!!!');
end;

procedure TIListTest.AddElements;
var
  list: IList<String>;
begin
  list := TIntList<String>.Create;
  list.Add('hello');
  Assert.AreEqual<Integer>(1, list.Count);
  Assert.AreEqual<String>(list[0], 'hello');
end;

procedure TIListTest.FindElements;
var
  list: IList<String>;
begin
  list := TIntList<String>.Create;
  list.Add('hello');
  list.Add('world');
  list.Add('!!!');
  Assert.AreEqual<Boolean>(list.Contains('!!!'), True);
  Assert.AreEqual<String>(list.First, 'hello');
  Assert.AreEqual<String>(list.Last, '!!!');
end;

procedure TIListTest.IndexOf;
var
  list: IList<String>;
begin
  list := TIntList<String>.Create;
  list.Add('hello');
  list.Add('world');
  list.Add('!!!');
  Assert.AreEqual<Integer>(list.IndexOf('hello'), 0);
  Assert.AreEqual<Integer>(list.IndexOf('world'), 1);
  Assert.AreEqual<Integer>(list.IndexOf('!!!'), 2);
end;

procedure TIListTest.Iterator;
var
  list: IList<String>;
  item: String;
  i: Integer;
begin
  list := TIntList<String>.Create;
  list.Add('hello');
  list.Add('world');
  i := 0;
  for item in list do begin
    Inc(i);
  end;
  Assert.AreEqual<Integer>(2, i);
end;

procedure TIListTest.ListInitialization;
var
  list: IList<String>;
begin
  list := TIntList<String>.Create;
  Assert.AreEqual<Integer>(0, list.Count);
  Assert.AreEqual<Integer>(0, list.Capacity);

  // using the gorwth algorithm
  list := TIntList<String>.Create(5);
  Assert.AreEqual<Integer>(0, list.Count);
  Assert.AreEqual<Integer>(8, list.Capacity);
end;

procedure TIListTest.RemoveFirstElement;
var
  list: IList<String>;
begin
  list := TIntList<String>.Create;
  list.Add('hello');
  list.Add('world');
  list.Remove('hello');
  Assert.AreEqual<Integer>(1, list.Count);
end;

procedure TIListTest.RemoveLastElement;
var
  list: IList<String>;
begin
  list := TIntList<String>.Create;
  list.Add('hello');
  list.Add('world');
  list.Remove('world');
  Assert.AreEqual<Integer>(1, list.Count);
end;

procedure TIListTest.RemoveMiddleElement;
var
  list: IList<String>;
begin
  list := TIntList<String>.Create;
  list.Add('hello');
  list.Add('world');
  list.Add('!!!');
  list.Remove('world');
  Assert.AreEqual<Integer>(2, list.Count);
end;

procedure TIListTest.RemoveNonExistingElement;
var
  list: IList<String>;
begin
  list := TIntList<String>.Create;
  list.Add('hello');
  list.Add('world');
  list.Add('!!!');
  list.Remove('word');
  Assert.AreEqual<Integer>(3, list.Count);
end;

initialization
  TDUnitX.RegisterTestFixture(TIListTest);

end.