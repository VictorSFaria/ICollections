program ICollectionsExample;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  DUnitX.TestFramework,
  DUnitX.TestRunner,
  DUnitX.Loggers.Console,
  DUnitX.Windows.Console,
  DUnitX.MemoryLeakMonitor.FastMM4,
  ICollections.List in 'ICollections.List.pas',
  ICollections.List.Test in 'ICollections.List.Test.pas',
  ICollections.Tree in 'ICollections.Tree.pas',
  ICollections.Tree.Test in 'ICollections.Tree.Test.pas',
  ICollections.Default in 'ICollections.Default.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
begin
  try
    runner := TDUnitX.CreateRunner;
    runner.UseRTTI := True;
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);

    results := runner.Execute;

    System.Write('Press <Enter> key to quit.');
    System.Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
