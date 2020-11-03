REM Use like;
REM
REM . .\java.env <webapp>
REM
REM e.g.
REM
REM . .\java.env pda-odb-dev
REM
REM and this will add the variables below into your terminal session.
REM

REM This allows recursive assignment within a for loop see http://jamesewelch.wordpress.com/2008/05/06/how-to-set-variables-in-a-dos-for-loop/
SETLOCAL ENABLEDELAYEDEXPANSION

SET WEBAPP=%CATALINA_HOME%\webapps\%1

REM SET PATH=%PATH%;%JAVA_HOME%\bin

REM Add on extra jar files to CLASSPATH
for %%i in (%CATALINA_HOME%\COMMON\lib\*.jar) do (
  SET CLASSPATH=!CLASSPATH!;%%i
)

for %%i in (%WEBAPP%\WEB-INF\lib\*.jar) do (
  SET CLASSPATH=!CLASSPATH!;%%i
)

SET CLASSPATH=%CLASSPATH%;%WEBAPP%\WEB-INF\classes
SET CLASSPATH=%CLASSPATH%;%CATALINA_HOME%\classes

REM These are the additions to the CLASSPATH required to compile the packages.
SET CLASSPATH=%CLASSPATH%;%WEBAPP%\WEB-INF\classes\com\db
SET CLASSPATH=%CLASSPATH%;%WEBAPP%\WEB-INF\classes\com\dbb
SET CLASSPATH=%CLASSPATH%;%WEBAPP%\WEB-INF\classes\com\vsb
SET CLASSPATH=%CLASSPATH%;%WEBAPP%\WEB-INF\classes\com\ws
SET CLASSPATH=%CLASSPATH%;%WEBAPP%\WEB-INF\classes\com\dmn
SET CLASSPATH=%CLASSPATH%;%WEBAPP%\WEB-INF\classes\com\map
SET CLASSPATH=%CLASSPATH%;%WEBAPP%\WEB-INF\classes\com\servlets
SET CLASSPATH=%CLASSPATH%;%WEBAPP%\WEB-INF\classes\com\filters
SET CLASSPATH=%CLASSPATH%;%WEBAPP%\WEB-INF\classes\com\utils
SET CLASSPATH=%CLASSPATH%;%WEBAPP%\WEB-INF\classes\com\utils\soundex
SET CLASSPATH=%CLASSPATH%;%WEBAPP%\WEB-INF\classes\com\utils\date
SET CLASSPATH=%CLASSPATH%;%WEBAPP%\WEB-INF\classes\com\utils\compare
SET CLASSPATH=%CLASSPATH%;%WEBAPP%\WEB-INF\classes\pharaoh\web\databases