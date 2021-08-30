@echo off

REM This script is to facilitate the process of installing dynr.
REM The detailed instrction is in InstallationForUser.pdf
REM Currently, InstallationForDevelopers and Adobe.lnk (the quick path of Acrobat) should be put in the same directory with same folder

setlocal ENABLEDELAYEDEXPANSION


echo [MSG] This installer needs to be run under administrator mode. Please check the top-left side of this window, you should see 'Administrator: Command Prompt'. Otherwise, please open a new command prompt under administrator mode by right clicking the icon of command prompt and selecting 'Run as administrator'.
echo.


echo [ACT] Will you contribute to code development for the dynr package (y/n)?
echo       (Please enter 'n' if you only want to install dynr on cran)
echo|<nul set /p =">> "
set /P is_developer=

echo.
echo Step 1.1: installation of R.

set "R_path=C:\Program Files\R"
dir /b /o-n "C:\Program Files\R" > "%temp%\temp.txt"

if exist "%temp%\temp.txt" (
	for /f "delims=^ tokens=*" %%d in ('findstr /r "R-[0-9].[0-9].[0-9]" "%temp%\temp.txt"') do (
		REM echo [TEST] Examine C:\Program Files\R\%%d\bin		
		if exist "C:\Program Files\R\%%d\bin\R.exe" (	
			set "r_bin_path=C:\Program Files\R\%%d\bin"
			set "r_path=C:\Program Files\R\%%d"
			echo [MSG] The installer found %%d on your computer in C:\Program Files\R\%%d\bin 
			@del "%temp%\temp.txt"
			goto R_version_check
		)
	)
	goto R_install_instruction
)
goto R_install_instruction

:R_version_check
echo [ACT] Is this the version of R to which you want to install dynr (y/n)?
echo|<nul set /p =">> "
set /P adopted_R=

if %adopted_R:~0,1% == y ( 
	goto R_install_finished
) else (
	goto R_install_instruction 
)

:R_install_instruction 
echo [MSG] Please enter the directory containting R.exe. By default, it should be put in 'C:\Program Files\R\R-3.6.3\bin' if the R version is 3.6.3. Enter a single 'i' to be redirected to the R website.
echo|<nul set /p =">> "
set /P installed_R=
REM echo [TESTING] %installed_R:~0,1%
if %installed_R:~0,1% == i (
	REM MessageBox.vbs msg_1_1.txt
	echo [MSG] Please goto https://www.r-project.org/ and install the latest R. The installer will open https://www.r-project.org/ for you.
	REM @ping 127.0.0.1 -n 2 -w 1000 > nul
	REM pause
	start https://www.r-project.org/ 
	
	echo [ACT] After R is installed, please enter the directory containting R.exe:
	echo|<nul set /p =">> "
	set /P R_bin_path=
	set R_path=%R_bin_path:~0,-4%
	goto R_install_finished
) else (
	set "R_bin_path=%installed_R%"
	set R_path=%R_bin_path:~0,-4%
	goto R_install_finished
)


:R_install_finished
REM echo [TESTING] Your R path is %R_path%
REM echo [TESTING] Your R bin path is %R_bin_path%

REM @ping 127.0.0.1 -n 3 -w 1000 > nul
REM pause

echo.
echo Step 1.2: installation of Rtools.
echo [MSG] Please ensure that the version of Rtools is compatible with your installed version of R. For instance, for R version 3.6.3, Rtools35 should be selected. See https://cran.r-project.org/bin/windows/Rtools/history.html for more information.
echo.

if exist C:\Rtools\bin\grep.exe (
	echo [MSG] The installer found a Rtools directory on your computer in C:\Rtools\bin. 
	goto Rtools_ask_installed
) else (
	goto Rtools_install_instruction
)

:Rtools_ask_installed
echo [ACT] Is this the Rtools to which you want to install dynr (y/n)?
echo|<nul set /p =">> "
set /P adopted_Rtools=
REM echo [TESTING] adopted_Rtools = %adopted_Rtools%

REM @ping 127.0.0.1 -n 3 -w 1000 > nul
REM pause

if %adopted_Rtools:~0,1% == y ( 
	set Rt_path=C:\Rtools
	goto Rtools_install_finished
) else (
	goto Rtools_install_instruction 
)

:Rtools_install_instruction
echo [ACT] Please identify an subfolder of Rtools containing grep.exe. By default, it should be put in 'C:\Rtools\bin'. Enter a single 'i' to be redirected to the Rtools website.
echo|<nul set /p =">> "
set /P installed_Rt= 
REM echo [TESTING] %installed_Rt%
if %installed_Rt% == i (
	REM MessageBox.vbs msg_1_2.txt
	echo [MSG] Install Rtools that is compatible with the installed R through https://cran.r-project.org/bin/windows/Rtools/history.html. I am going to open this website for you.
	echo [MSG] While installing Rtools, please uncheck the box 'Add Rtools to system PATH' in teh panel.
	start https://cran.r-project.org/bin/windows/Rtools/history.html
	REM @ping 127.0.0.1 -n 3 -w 1000 > nul
	REM pause
	echo [ACT] After Rtools is installed, Please identify an subfolder of Rtools containing grep.exe ^(by default, 'C:\Rtools\bin'^):
	echo|<nul set /p =">> "
	set /P Rt_path2=
) else (
	set "Rt_path2=%installed_Rt%"
	REM echo [TESTING] Rt_path= %Rt_path%
)
set "Rt_path=!Rt_path2:~0,-4!"
echo.

:Rtools_install_finished
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | findstr /i "x86" > NUL && set OS=32bit || set OS=64bit
echo [MSG] Your OS is %OS%.
if %OS:~0,5% == 32bit (
	goto check_os_32
) 
:32_no
if %OS:~0,5% == 64bit (
	goto check_os_64
)

:64_no
echo [MSG] Identify the path of the subfolder of !Rt_path! containing a file named gcc.exe:
echo       - For 32-bit computers, this is typically in !Rt_path!\mingw_32\bin. 
echo       - For 64-bit computers, this is typically in !Rt_path!\mingw_64\bin.
explorer "%Rt_path%"
REM @ping 127.0.0.1 -n 3 -w 1000 > nul
echo|<nul set /p =">> "
set /P gcc_bin_path=
goto Rt_end

:check_os_32
if exist "%Rt_path%\mingw_32\bin\gcc.exe" (
	set "gcc_bin_path=%Rt_path%\mingw_32\bin"
	goto Rt_end
) else (
	goto 32_no
)

:check_os_64
if exist "%Rt_path%\mingw_64\bin\gcc.exe" (
	set "gcc_bin_path=%Rt_path%\mingw_64\bin"
	goto Rt_end
) else (
	goto 64_no
)



:Rt_end
REM echo [TESTING] Rt_path= %Rt_path%
REM echo [TESTING] gcc_bin_path= %gcc_bin_path%



set "new_bin_path=%Rt_path%\bin;%gcc_bin_path%;%r_bin_path%"
REM echo [TESTING] new_bin_path= %new_bin_path%.
REM echo [MSG] According to your inputs, the binary files of R and Rtools are in '%new_bin_path%'. 
REM pause


if "%is_developer%" == "n" (
	goto cygwin_end
)

echo.
echo Step 1.6 Cygwin

if exist "C:\cygwin64" (
	goto cygwin_ask
) else (
	goto cygwin_install
)

:cygwin_ask
echo [ACT] A cygwin folder is found in C:\cygwin64. Is it the version of cygwin to which you want to install dynr?
echo|<nul set /p =">> "
set /P installed_cygwin=
if %installed_cygwin% == y (
	set cygwin_path=C:\cygwin64\bin
	goto cygwin_end
)

:cygwin_install
REM MessageBox.vbs msg_1_6.txt
echo [MSG] Please goto https://cygwin.com/index.html and install the latest Cygwin.
echo       When prompted, select to install the following packages in cygwin:
echo       (a) git (under Devel): "Distributed version control system"
echo       (b) gcc (under Devel): "gcc-core: GNU Compiler Collection (C, OpenMP)"
echo       (c) make (under Devel): "The GNU version of the 'make' utility"
echo       (d) perl: (under Perl): "Perl programming language interpreter"

start https://cygwin.com/index.html
if exist "C:\cygwin64" (
	set cygwin_path=C:\cygwin64\bin
) else (
	set cygwin_path=
	echo [MSG] Please enter the directory containing make.exe, by default, it is C:\cygwin64\bin:
	echo|<nul set /p =">> "
	set /P cygwin_path=
	
)

echo [MSG] According to your inputs, the binary files of cygwin are in '%cygwin_path%'. 

:cygwin_end

REM echo [TESTING] cygwin_path=%cygwin_path%

echo.
echo Step 1.5 Path
echo [MSG] According to your inputs, the installer are going to add '%new_bin_path%;%cygwin_path%' at the beginning of the environment variable PATH.
set new_path=
if %is_developer% == y (
	@echo "%PATH%" | findstr /c:"%new_bin_path%;%cygwin_path%">nul
	echo [TESTING] !errorlevel!
	if !errorlevel! equ 1 (
		set "new_path=%new_bin_path%;%cygwin_path%"
	)
	
	REM @echo "%PATH%" | findstr /c:"%new_bin_path%">nul
	REM echo [TESTING] !errorlevel!
	REM if !errorlevel! equ 1 ( 
	REM 	set new_path=%new_bin_path%;%cygwin_path% 
	REM )
) else (
	@echo "%PATH%" | findstr /c:"%new_bin_path%">nul
	echo [TESTING] !errorlevel!
	if !errorlevel! equ 1 set new_path=%new_bin_path%
)
REM @ping 127.0.0.1 -n 2 -w 1000 > nul
SETX /m PATH "!new_path!;%PATH%"
REM echo [MSG] The path is set to be '!path!'.


echo print ("hello") > "%cd%\hello.R"
REM MessageBox.vbs msg_1_5.txt
echo [MSG] Open another command prompt window. Navigate (cd) to %cd%, which also contains a file named 'hello.R'. At the prompt, execute this R script by typing 'Rscript hello.R'.
echo.
REM @ping 127.0.0.1 -n 2 -w 1000 > nul
echo [MSG] Does the command prompt output '[1] hello' sucssessfully (y/n)?
echo|<nul set /p =">> "
set /P path_successful= 
REM echo [TESTING] %path_successful%
REM @ping 127.0.0.1 -n 2 -w 1000 > nul
REM pause


echo.
echo Step 1.3 GSL library
if exist "%Rt_path%\local323\lib" (
	echo [MSG] The installer found a GSL directory on your computer in %Rt_path%\local323. 
	goto GSL_installed_finished
) else (
	goto GSL_install_instruction
)

:GSL_install_instruction
REM if exist "%Rt_path%\local323\lib" (
REM	echo [MSG] The local323 folder is already in %Rt_path%. 
REM	@ping 127.0.0.1 -n 3 -w 1000 > nul
REM	goto GSL_installed_finished
REM)

REM MessageBox.vbs msg_1_3.txt
echo [MSG] Please goto http://www.stats.ox.ac.uk/pub/Rtools/libs.html and download local323.zip.
echo       I am going to open this website.
REM @ping 127.0.0.1 -n 3 -w 1000 > nul
start http://www.stats.ox.ac.uk/pub/Rtools/libs.html

if exist "C:\Users\%username%\Downloads\local323.zip" (
	set gsl_file=C:\Users\"%username%"\Downloads\local323.zip
) else (
	echo [ACT] Please enter the directory of your downloaded file:
	echo "     (e.g.,C:\Users\%username%\Downloads\local323.zip)"
	echo|<nul set /p =">> "
	set /P gsl_file=
)

md "%Rt_path%\local323"
if exist "%gsl_file%" (
	echo [MSG] ... unzipping the file into %Rt_path%\local323 ...
	REM echo [TESTING] "%Rt_path%\bin\unzip" -qu "%gsl_file%" -d "%Rt_path%\local323"
	"%Rt_path%\bin\unzip" -qu "%gsl_file%" -d "%Rt_path%\local323"
)

:GSL_installed_finished
if not exist "%Rt_path%\local323\lib" (
	echo [ERROR] %Rt_path%\local323 still does not exist. Please unzip the local323.zip manually into %Rt_path%, specificlly, there should be a folder local323 in %Rt_path% that contains lib and include folders in local323.zip. 
)
REM @ping 127.0.0.1 -n 3 -w 1000 > nul
REM pause



echo.
echo Step 1.4 Setting of LIB_GSL
set "Rt_path=%Rt_path:\=/%"
echo [MSG] The installer will set a environmental variable LIB_GSL as %Rt_path%^/local323.
SETX /m LIB_GSL "%Rt_path%/local323"
REM @ping 127.0.0.1 -n 1 -w 1000 > nul
REM pause

echo.
echo Step 1.7 LIB_GSL Examination
REM MessageBox.vbs msg_1_7.txt
echo [MSG] Open an Rstudio window. If the editor is opened before running the installer, reopen it.
echo.
REM @ping 127.0.0.1 -n 1 -w 1000 > nul
echo [MSG] Type 'shell(^"echo %%LIB_GSL%%^")' in the Rstudio prompt. 
echo       It should return ^"%Rt_path%^/local323^" if everything is set up correctly.
echo.
REM @ping 127.0.0.1 -n 1 -w 1000 > nul

echo [ACT] Does R return %Rt_path%^/local323 sucssessfully (y/n)?
echo|<nul set /p =">> "
set /P examination_successful= 
REM echo [TESTING] %examination_successful%

if %path_successful% == n (
	goto manually_action
) 

if !examination_successful! == n (
	goto manually_action
)
goto both_successful


:manually_action
echo.
echo Step 1.8 Manual Action (Optional)
REM MessageBox.vbs msg_1_8.txt
echo [MSG] Oops, it seems that the script does not set up the environment for dynr successfully. Please follow the steps to set up manually:

echo       1. Install R 3.6.3 in 'C:\Program Files\R'. After that, you should be able to find a file R.exe in the directory 'C:\Program Files\R\R-3.6.3\bin'.

echo       2. Copy the Rtools folder in Step 1.2 to 'C:\'. After that, you should be able to find a file gcc.exe in 'C:\Rtools\mingw_32\bin' (when the OS is 32-bit) or 'C:\Rtools\mingw_64\bin' (when the OS is 64-bit)
echo       3. Copy the 'local323' folder in Step 1.3 to 'C:\Rtools'.
echo       4. Add the string 'C:\Program Files\R\R-3.6.3\bin;C:\Rtools\bin;C:\Rtools\mingw_64\bin;C:\cygwin\bin' to the beginning of the environmental variable PATH.
echo       5. After setting everything, close the command prompt and open another one under administrator. Re-execute this script to examine that everything is set up successfully.
 



:both_successful

echo.
echo Step 1.9 Setting R Libary Path ^& Install roxygen2

echo [MSG] The installation of dynr requires the roxygen2 libaray. The roxygen2 needs to be installed in the system library (look like %R_path%\library), not the personal library (look like C:\Users\%username%\Documents\R\win-library\3.5).
echo       Thus, the installer is going to set a user variable R_LIBS_USER to '%R_path%\library', to make sure roxygen2 can be installed and accessed correctly. 
set "R_LIBS_USER=%R_path%\library"
REM @ping 127.0.0.1 -n 3 -w 1000 > nul
REM pause

echo [MSG] The roxygen2 needs to be installed in %R_path%\library. The installer is examining whether roxygen2 is already installed.
echo.




if exist "!R_path!\library\roxygen2\DESCRIPTION" (
	echo [MSG] Good. I found roxygen2 already installed on your computer in !R_path!\library.
) else (
	echo [MSG] I did not find roxygen2 already installed on your computer in !R_path!\library.
	echo       Please install roxygen2 via the following steps:
	echo       1. Please open Rstudio under administrator mode and type ^"install.packages^('roxygen2'^)^" in the prompt of Rstudio to install roxygen2.
	echo          ^(To run Rstudio under administrator, right click the icon of Rstudio and select 'Run as administrator'^)
	echo       2. Please Type the command^".libPaths^(^)^" in the Rstudio window, and ensure that the path '%R_path%\library' is the first element of the output.
	echo          If not, please try to modify the file Rprofile.site in folder %R_path%\etc. Specifically, add a line '.libPaths^('%R_path%\library'^)' at the last of the file Rprofile.site.
	echo       3. Please open a new Rstudio window and type ^"install.packages^('roxygen2'^)^" in the prompt of Rstudio.
)


echo.
echo Step 3: Install dynr from Bitbucket Repositrary
if !is_developer! == y (
	REM MessageBox.vbs msg_3_developer.txt
	echo [MSG] Please follow the steps:
	echo       1. Open a command prompt, go to the folder of dynr.
	echo       2. Type ^"git clone https:^/^/^<your_account^>^@github.com^/mhunter1^/dynr.git^" in the command prompt, press enter. 
	echo       3. Type ^"make clean install^".
	echo       4. Open RGui like Rstudio or whatever editor you use to run R. 
	echo       5. Type ^"demo^('LinearSDE',package='dynr'^)^" in Rstudio.
) else (
	REM MessageBox.vbs msg_3_user.txt
	echo [MSG] Please follow the steps:
	echo       1. Open a Rstudio window.
	echo       2. Type ^"install.packages^('dynr'^)^" in the Rstudio prompt.
	echo       3. Type ^"require^('dynr'^)^" in the Rstudio prompt.
	echo       4. Type ^"demo^(`LinearSDE',package='dynr'^)^" in the Rstudio prompt.

)