# PowerShell Script to Activate a Python Virtual Environment, Install Dependencies, and Run a Python Script

# --- Configuration Variables ---
# Define the path to your virtual environment.
# Replace '.\.venv' with the actual path if your venv is located elsewhere.
# Example: 'C:\Users\YourUser\Documents\MyProject\.venv'
$VenvPath = ".\.venv"

# Define the path to your requirements.txt file.
# Replace '.\requirements.txt' with the actual path if it's different.
$RequirementsFile = ".\requirements.txt"

# Define the path to your Python script that you want to run.
# Replace '.\main.py' with the actual path and filename of your script.
$PythonScript = ".\main.py"

# --- Script Logic ---

# 1. Check if the virtual environment directory exists.
if (-not (Test-Path $VenvPath -PathType Container)) {
    Write-Host "Error: Virtual environment not found at '$VenvPath'." -ForegroundColor Red
    Write-Host "Please ensure the virtual environment exists or update the '$VenvPath' variable." -ForegroundColor Yellow
    exit 1
}

# 2. Construct the path to the activate script.
# For Windows, the activate script is usually in Scripts\activate.ps1
$ActivateScript = Join-Path $VenvPath "Scripts\Activate.ps1"

# Check if the activate script exists.
if (-not (Test-Path $ActivateScript -PathType Leaf)) {
    Write-Host "Error: Virtual environment activation script not found at '$ActivateScript'." -ForegroundColor Red
    Write-Host "Please ensure the virtual environment is correctly set up." -ForegroundColor Yellow
    exit 1
}

Write-Host "Activating virtual environment from '$ActivateScript'..." -ForegroundColor Green

# 3. Activate the virtual environment.
# The '&' operator is used to run a script in the current scope.
# It's crucial to use '.\' for local scripts.
# Note: For this to work, your PowerShell execution policy might need to allow local scripts.
# You might need to run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` once.
try {
    & $ActivateScript
    Write-Host "Virtual environment activated successfully." -ForegroundColor Green
} catch {
    Write-Host "Error activating virtual environment: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check your PowerShell execution policy. You might need to run 'Set-ExecutionPolicy RemoteSigned -Scope CurrentUser'." -ForegroundColor Yellow
    exit 1
}

# 4. Install Python dependencies using pip.
# This step assumes pip is available in the activated virtual environment.
if (Test-Path $RequirementsFile -PathType Leaf) {
    Write-Host "Installing dependencies from '$RequirementsFile' using pip..." -ForegroundColor Green
    try {
        pip install -r $RequirementsFile
        Write-Host "Pip installation completed." -ForegroundColor Green
    } catch {
        Write-Host "Error during pip installation: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please ensure pip is installed and your requirements.txt is valid." -ForegroundColor Yellow
        # Continue to script execution even if pip fails, as user might not have dependencies.
    }
} else {
    Write-Host "No requirements.txt found at '$RequirementsFile'. Skipping pip installation." -ForegroundColor Yellow
}


# 5. Run the Python script.
if (Test-Path $PythonScript -PathType Leaf) {
    Write-Host "Running Python script: '$PythonScript'..." -ForegroundColor Green
    try {
        gcc -shared -o libhex.dll convert_to_hex.c
        python $PythonScript
        Write-Host "Python script execution completed." -ForegroundColor Green
    } catch {
        Write-Host "Error running Python script: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please ensure the Python script exists and is executable." -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "Error: Python script not found at '$PythonScript'." -ForegroundColor Red
    Write-Host "Please ensure the Python script exists or update the '$PythonScript' variable." -ForegroundColor Yellow
    exit 1
}

Write-Host "Script finished." -ForegroundColor Green
