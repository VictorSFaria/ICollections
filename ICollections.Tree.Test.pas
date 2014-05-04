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

unit ICollections.Tree.Test;

interface

uses
  DUnitX.TestFramework,
  ICollections.Tree;

type
  [TestFixture]
  TRBTreeTest = class
  private
    procedure CheckNode<T>(node: IRBNode<T>);
    procedure CheckTree<T>(tree: ITree<T>);
  public
    [Test]
    procedure Add;
    [Test]
    procedure Remove;
    [Test]
    procedure ItemNotFound;
    [Test]
    procedure Enum;
  end;

implementation

{ TRBTreeTest }

procedure TRBTreeTest.Add;
var
  tree: ITree<Integer>;
  i: Integer;
begin
  tree := TTreeRB<Integer>.Create;

  for i := 0 to 1000 do begin
    tree.Add(i);
  end;
  CheckTree<Integer>(tree);
end;

procedure TRBTreeTest.CheckNode<T>(node: IRBNode<T>);
begin
  if (node <> nil) then begin
    if (node.Color = Red) then begin
      if (node.Left <> nil) then begin
        Assert.IsTrue(node.Left.Color = Black);
      end;
      if (node.Right <> nil) then begin
        Assert.IsTrue(node.Right.Color = Black);
      end;
    end;
    CheckNode(node.Left);
    CheckNode(node.Right);
  end;
end;

procedure TRBTreeTest.CheckTree<T>(tree: ITree<T>);
begin
  Assert.IsTrue(IRBNode<T>(tree.Root).Color = Black);
  CheckNode<T>(IRBNode<T>(tree.Root));
end;

procedure TRBTreeTest.Enum;
var
  tree: ITree<Integer>;
  i, value: Integer;
begin
  tree := TTreeRB<Integer>.Create;

  for i := 0 to 1000 do begin
    tree.Add(i);
  end;

  i := 0;
  for value in tree do begin
    Assert.AreEqual(i, value);
    Inc(i);
  end;
end;

procedure TRBTreeTest.ItemNotFound;
var
  tree: ITree<Integer>;
begin
  tree := TTreeRB<Integer>.Create;
  Assert.IsFalse(tree.Remove(1));
end;

procedure TRBTreeTest.Remove;
var
  tree: ITree<Integer>;
  i, value: Integer;
begin
  tree := TTreeRB<Integer>.Create;

  for i := 0 to 10000 do begin
    tree.Add(i);
  end;

  for i := 5000 to 10000 do begin
    Assert.IsTrue(tree.Remove(i));
  end;

  i := 0;
  for value in tree do begin
    Assert.AreEqual(i, value);
    Inc(i);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TRBTreeTest);

end.
