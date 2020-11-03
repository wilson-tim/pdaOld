cd %CATALINA_HOME%\webapps\%1\WEB-INF\classes

for /R %%i in (*.java) do (
  javac -target 1.3 %%i
)

cd %CATALINA_HOME%\bin