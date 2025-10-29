@echo off
setlocal enabledelayedexpansion

:: Iterate through all directories in the current location
for /d %%D in (*) do (
    :: Check if __pycache__ folder exists and delete it
    if exist "%%D\__pycache__" (
        echo Deleting __pycache__ in %%D
        rmdir /s /q "%%D\__pycache__"
    )

    :: Check if migrations folder exists
    if exist "%%D\migrations" (
        echo Deleting migrations in %%D
        rmdir /s /q "%%D\migrations"
    )

    :: Create new migrations folder and __init__.py file
    echo Creating new migrations folder in %%D
    mkdir "%%D\migrations"
    echo. > "%%D\migrations\__init__.py"
)

echo Operation completed.