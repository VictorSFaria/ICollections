{***************************************************************************}
{                                                                           }
{  ICollections - Copyright (C) 2013 - Víctor de Souza Faria                }
{                                                                           }
{  victor@victorfaria.com                                                   }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit ICollections.Tree;

interface

uses
  System.Generics.Defaults,
  ICollections.Default;

type
  INode<T> = interface
    procedure SetContent(node: T);
    function GetContent: T;
    property Content: T read GetContent write SetContent;
  end;


  ITree<T> = interface(ICollections.Default.IEnumerable<T>)
    function GetRoot: INode<T>;
    property Root: INode<T> read GetRoot;
    function Add(value: T): INode<T>;
    function GetNode(value: T): INode<T>;
    function Remove(value: T): Boolean;
    function Count: Integer;
  end;


  TNodeColor = (Black, Red);

  IRBNode<T> = interface(INode<T>)
    procedure SetLeft(node: IRBNode<T>);
    function GetLeft: IRBNode<T>;
    property Left: IRBNode<T> read GetLeft write SetLeft;
    procedure SetRight(node: IRBNode<T>);
    function GetRight: IRBNode<T>;
    property Right: IRBNode<T> read GetRight write SetRight;
    procedure SetParent(node: IRBNode<T>);
    function GetParent: IRBNode<T>;
    property Parent: IRBNode<T> read GetParent write SetParent;
    procedure SetColor(color: TNodeColor);
    function GetColor: TNodeColor;
    property Color: TNodeColor read GetColor write SetColor;
    function Grandparent: IRBNode<T>;
  end;


  TRBNode<T> = class(TInterfacedObject, IRBNode<T>)
  private
    FLeft: IRBNode<T>;
    FRight: IRBNode<T>;
    FParent: IRBNode<T>;
    FContent: T;
    FColor: TNodeColor;
    procedure SetLeft(node: IRBNode<T>);
    function GetLeft: IRBNode<T>;
    procedure SetRight(node: IRBNode<T>);
    function GetRight: IRBNode<T>;
    procedure SetParent(node: IRBNode<T>);
    function GetParent: IRBNode<T>;
    procedure SetColor(color: TNodeColor);
    function GetColor: TNodeColor;
    procedure SetContent(value: T);
    function GetContent: T;
  public
    property Right: IRBNode<T> read GetRight write SetRight;
    property Parent: IRBNode<T> read GetParent write SetParent;
    property Left: IRBNode<T> read GetLeft write SetLeft;
    property Color: TNodeColor read GetColor write SetColor;
    property Content: T read GetContent write SetContent;
    function Grandparent: IRBNode<T>;
  end;

  TTreeRB<T> = class(TInterfacedObject, ITree<T>)
  private
    FComparer: IComparer<T>;
    FRoot: IRBNode<T>;
    FCount: Integer;
    procedure Balance2(node: IRBNode<T>);
    function Successor(node: IRBNode<T>): IRBNode<T>;
    procedure DeleteBalance(node: IRBNode<T>);
    procedure RotateLeft(node: IRBNode<T>);
    procedure RotateRight(node: IRBNode<T>);
    function GetRoot: INode<T>;
    function FindValue(value: T; node: IRBNode<T>): IRBNode<T>;
  public
    constructor Create; overload;
    constructor Create(comparer: IComparer<T>); overload;
    property Root: INode<T> read GetRoot;
    function Add(value: T): INode<T>;
    function Count: Integer;
    function GetNode(value: T): INode<T>;
    function Remove(value: T): Boolean;
    function GetEnumerator: IEnumerator<T>;
    type
      TEnumerator = class(TInterfacedObject, IEnumerator<T>)
      private
        FITems: array of T;
        FIndex: Integer;
        function GetCurrent: T;
        procedure FillArray(node: IRBNode<T>);
      public
        constructor Create(tree: TTreeRB<T>);
        property Current: T read GetCurrent;
        function MoveNext: Boolean;
      end;
  end;

implementation

{ TTreeRB<T> }

function TTreeRB<T>.Add(value: T): INode<T>;
var
  node, newNode, parent: IRBNode<T>;
  i: Integer;
begin
  newNode := TRBNode<T>.Create;
  newNode.Content := value;

  if FRoot = nil then begin
    FRoot := newNode;
    newNode.Color := Black;
  end
  else begin
    node := FRoot;
    repeat
    begin
      parent := node;

      i := FComparer.Compare(parent.Content, newNode.Content);
      if i < 0 then begin
        node := parent.Right;
      end
      else begin
        if i > 0 then begin
          node := parent.Left;
        end;
      end;
    end;
    until not Assigned(node);

    newNode.Color := Red;
    newNode.Parent := parent;
    if i < 0 then begin
      parent.Right := newNode;
    end
    else begin
      parent.Left := newNode;
    end;
    Balance2(newNode);
  end;
  Inc(FCount);
  Result := newNode;
end;

procedure TTreeRB<T>.Balance2(node: IRBNode<T>);
var
  node2: IRBNode<T>;
begin
  node.Color := RED;
  while (node.Parent <> nil) and (node.Parent.Color = Red) do begin
    if node.Parent = node.Grandparent.Left then begin
      node2 := node.Grandparent.Right;
      if (node2 <> nil) and (node2.Color = Red) then begin
        node.Parent.Color := Black;
        node2.Color := Black;
        node2.Grandparent.Color := Red;
        node := node.Grandparent;
      end
      else begin
        if node = node.Parent.Right then begin
          node := node.Parent;
          RotateLeft(node);
        end;
        node.Parent.Color := Black;
        node.Grandparent.Color := Red;
        RotateRight(node.Grandparent);
      end;
    end
    else begin
      node2 := node.Grandparent.Left;
      if (node2 <> nil) and (node2.Color = Red) then begin
        node.Parent.Color := Black;
        node2.Color := Black;
        node.Grandparent.Color := Red;
        node := node.Grandparent;
      end
      else begin
        if node = node.Parent.Left then begin
          node := node.Parent;
          RotateRight(node);
        end;
        node.Parent.Color := Black;
        node.Grandparent.Color := Red;
        RotateLeft(node.Grandparent);
      end;
    end;
  end;
  FRoot.Color := Black;
end;

function TTreeRB<T>.Count: Integer;
begin
  Result := FCount;
end;

constructor TTreeRB<T>.Create(comparer: IComparer<T>);
begin
  FComparer := comparer;
  FCount := 0;
end;

constructor TTreeRB<T>.Create;
begin
  Create(TComparer<T>.Default);
end;

procedure TTreeRB<T>.DeleteBalance(node: IRBNode<T>);
var
  sibling: IRBNode<T>;
begin
  while(node <> FRoot) and (node.Color = Black) and (node <> nil) do begin
    if (node.Parent.Left <> nil) and (node = node.Parent.Left) then begin
      sibling := node.Parent.Right;
      if (sibling <> nil) and (sibling.Color = Red) then begin
        sibling.Color := Black;
        node.Parent.Color := Red;
        RotateLeft(node.Parent);
        sibling := node.Parent.Right;
      end;

      if ((sibling.Left = nil) or (sibling.Left.Color = Black)) and
        ((sibling.Right = nil) or  (sibling.Right.Color = Black)) then begin
        sibling.Color := Red;
        node := node.Parent;
      end
      else begin
        if (sibling.Right = nil) and (sibling.Right.Color = Black) then begin
          sibling.Left.Color := Black;
          sibling.Color := Red;
          RotateRight(sibling);
          sibling := node.Parent.Right;
        end;
        sibling.Color := node.Parent.Color;
        node.Parent.Color := Black;
        sibling.Right.Color := Black;
        RotateLeft(node.Parent);
        node := FRoot;
      end;
    end
    else begin
      sibling := node.Parent.Left;
      if (sibling <> nil) and (sibling.Color = Red) then begin
        sibling.Color := Black;
        node.Parent.Color := Red;
        RotateRight(node.Parent);
        sibling := node.Parent.Left;
      end;

      if (sibling = nil) or ((sibling <> nil) and ((sibling.Left = nil) or (sibling.Left.Color = Black)) and ((sibling.Right = nil) or(sibling.Right.Color = Black))) then begin
        if (sibling <> nil) then
          sibling.Color := Red;
        node := node.Parent;
      end
      else begin
        if (sibling <> nil) and ((sibling.Left = nil) or (sibling.Left.Color = Black)) then begin
          sibling.Right.Color := Black;
          sibling.Color := Red;
          RotateLeft(sibling);
          sibling := node.Parent.Left;
        end;
        if (sibling <> nil) then begin
          sibling.Color := node.Parent.Color;
          if (sibling.Left <> nil) then begin
            sibling.Left.Color := Black;
          end;
        end;
        node.Parent.Color := Black;
        RotateRight(node.Parent);
        node := FRoot;
      end;
    end;
  end;
end;

function TTreeRB<T>.FindValue(value: T; node: IRBNode<T>): IRBNode<T>;
var
  cmp: Integer;
begin
  Result := nil;
  if node <> nil then begin
    cmp := FComparer.Compare(node.Content, value);
    if cmp = 0 then begin
      Result := node;
    end
    else begin
      if cmp < 0 then begin
        Result := FindValue(value, node.Right);
      end
      else begin
        Result := FindValue(value, node.Left);
      end;
    end;
  end;
end;

function TTreeRB<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := TTreeRB<T>.TEnumerator.Create(self);
end;

function TTreeRB<T>.GetNode(value: T): INode<T>;
begin
  Result := FindValue(value, FRoot);
end;

function TTreeRB<T>.GetRoot: INode<T>;
begin
  Result := FRoot;
end;

function TTreeRB<T>.Remove(value: T): Boolean;
var
  currentNode: IRBNode<T>;
  successorNode: IRBNode<T>;
  replace: IRBNode<T>;
begin
  Dec(FCount);
  currentNode := FindValue(value, FRoot);
  Result := False;
  if currentNode <> nil then begin
    if (currentNode.Left <> nil) and (currentNode.Right <> nil) then begin
      successorNode := Successor(currentNode);
      currentNode.Content := successorNode.Content;
      currentNode := successorNode;
    end;

    if (currentNode.Left <> nil) then begin
      replace := currentNode.Left;
    end
    else begin
      replace := currentNode.Right;
    end;

    if (replace <> nil) then begin
      replace.Parent := currentNode.Parent;

      if (currentNode.Parent = nil) then begin
        FRoot := replace;
      end
      else begin
        if (currentNode = currentNode.Parent.Left) then begin
          currentNode.Parent.Left := replace;
        end
        else begin
          currentNode.Parent.Right := replace;
        end;
      end;

      currentNode.Left := nil;
      currentNode.Right := nil;
      currentNode.Parent := nil;

      if currentNode.Color = Black then begin
        DeleteBalance(replace);
      end;
    end
    else begin
      if (currentNode.Parent = nil) then begin
        FRoot := nil;
      end
      else begin
        if currentNode.Color = Black then begin
          DeleteBalance(currentNode);
        end;

        if currentNode.Parent <> nil then begin
          if currentNode = currentNode.Parent.Left then begin
            currentNode.Parent.Left := nil;
          end
          else begin
            if currentNode = currentNode.Parent.Right then begin
              currentNode.Parent.Right := nil;
            end;
          end;
          currentNode.Parent := nil;
        end;
      end;
    end;
    Result := True;
  end;
end;

procedure TTreeRB<T>.RotateLeft(node: IRBNode<T>);
var
  rigth: IRBNode<T>;
begin
  rigth := node.Right;
  node.Right := rigth.Left;
  if (rigth.Left <> nil) then begin
    rigth.Left.Parent := node;
  end;
  rigth.Left := node;

  if (node.Parent <> nil) then begin
    if (node.Parent.Right = node) then begin
      node.Parent.Right := rigth;
    end
    else begin
      node.Parent.Left := rigth;
    end;
    rigth.Parent := node.Parent;
  end
  else begin
    rigth.Parent := node.Parent;
    FRoot := rigth;
  end;
  node.Parent := rigth;
end;

procedure TTreeRB<T>.RotateRight(node: IRBNode<T>);
var
  left: IRBNode<T>;
begin
  left := node.Left;

  node.Left := left.Right;
  if (left.Right <> nil) then begin
    left.Right.Parent := node;
  end;

  left.Right := node;

  if (node.Parent <> nil) then begin
    if (node.Parent.Right = node) then begin
      node.Parent.Right := left;
    end
    else begin
      node.Parent.Left := left;
    end;
    left.Parent := node.Parent;
  end
  else begin
    left.Parent := node.Parent;
    FRoot := left;
  end;
  node.Parent := left;
end;



function TTreeRB<T>.Successor(node: IRBNode<T>): IRBNode<T>;
var
  currentNode: IRBNode<T>;
  nodeAux: IRBNode<T>;
begin
  if node = nil then begin
    Result := nil;
  end
  else begin
    if node.Right <> nil then begin
      currentNode := node.Right;
      while(currentNode.Left <> nil) do begin
        currentNode := currentNode.Left;
      end;
      Result := currentNode;
    end
    else begin
      currentNode := node.Parent;
      nodeAux := node;
      while(currentNode <> nil) and (nodeAux = currentNode.Right) do begin
        nodeAux := currentNode;
        currentNode := currentNode.Parent;
      end;
      Result := currentNode;
    end;

  end;
end;

{ TRBNode<T> }

function TRBNode<T>.GetColor: TNodeColor;
begin
  Result := FColor;
end;

function TRBNode<T>.GetContent: T;
begin
  Result := FContent;
end;

function TRBNode<T>.GetLeft: IRBNode<T>;
begin
  Result := FLeft;
end;

function TRBNode<T>.GetParent: IRBNode<T>;
begin
  Result := FParent;
end;

function TRBNode<T>.GetRight: IRBNode<T>;
begin
  Result := FRight;
end;

function TRBNode<T>.Grandparent: IRBNode<T>;
begin
  Result := nil;
  if Parent <> nil then begin
    Result := Parent.Parent;
  end;
end;

procedure TRBNode<T>.SetColor(color: TNodeColor);
begin
  FColor := color;
end;

procedure TRBNode<T>.SetContent(value: T);
begin
  FContent := value;
end;

procedure TRBNode<T>.SetLeft(node: IRBNode<T>);
begin
  FLeft := node;
end;

procedure TRBNode<T>.SetParent(node: IRBNode<T>);
begin
  FParent := node;
end;

procedure TRBNode<T>.SetRight(node: IRBNode<T>);
begin
  FRight := node;
end;

{ TTreeRB<T>.TEnumerator }

constructor TTreeRB<T>.TEnumerator.Create(tree: TTreeRB<T>);
begin
  SetLength(FITems, tree.FCount);
  FIndex := 0;
  FillArray(tree.FRoot);
  FIndex := -1;
end;

procedure TTreeRB<T>.TEnumerator.FillArray(node: IRBNode<T>);
begin
  if (node <> nil) then begin
    FillArray(node.Left);
    FITems[FIndex] := node.Content;
    Inc(FIndex);
    FillArray(node.Right);
  end;
end;

function TTreeRB<T>.TEnumerator.GetCurrent: T;
begin
  Result := FItems[FIndex];
end;

function TTreeRB<T>.TEnumerator.MoveNext: Boolean;
begin
  if (FIndex < (Length(FItems) - 1)) then begin
    Inc(FIndex);
    Result := True;
  end
  else begin
    Result := False;
  end;
end;

end.
