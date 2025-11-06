# setup_env.ps1

# --- 1. VIRTUAL ENVIRONMENT SETUP ---
# Check if the .venv directory exists. If not, create it.
if (-not (Test-Path -Path .\.venv -PathType Container)) {
    Write-Host "Virtual environment '.venv' not found. Creating..." -ForegroundColor Yellow
    try {
        # Use the 'py' launcher for better compatibility with multiple Python versions on Windows.
        python3 -m venv .venv
        Write-Host "Virtual environment created successfully." -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to create the virtual environment." -ForegroundColor Red
        Write-Host "Please ensure Python is installed and the 'py' command is available in your PATH." -ForegroundColor Red
        # Stop the script if venv creation fails.
        return
    }
} else {
    Write-Host "Virtual environment '.venv' already exists."
}


# --- 2. ACTIVATE VIRTUAL ENVIRONMENT ---
# Define the path to the activation script.
$activateScript = ".\.venv\Scripts\Activate.ps1"

if (Test-Path $activateScript) {
    try {
        # Activate the virtual environment by "dot sourcing" the activation script.
        # This runs the script in the current scope, modifying the environment.
        . $activateScript
        Write-Host "Virtual environment activated." -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to activate the virtual environment." -ForegroundColor Red
        return
    }
} else {
    Write-Host "ERROR: Activation script not found at '$activateScript'." -ForegroundColor Red
    return
}


# --- 3. INSTALL DEPENDENCIES ---
# Check for a requirements.txt file and install dependencies if it exists.
$pyprojectFile = ".\pyproject.toml"
if (Test-Path $pyprojectFile) {
    Write-Host "Found pyproject.toml. Installing dependencies..." -ForegroundColor Yellow
    try {
        # Upgrade pip and install packages from the requirements file.
        python3 -m pip install --upgrade pip
        pip install -e .
        Write-Host "Dependencies installed successfully." -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to install dependencies from pyproject.toml" -ForegroundColor Red
        return
    }
} else {
    Write-Host "requirements.txt not found. Skipping dependency installation."
}


# --- 4. LOAD ENVIRONMENT VARIABLES FROM .env FILE ---
# Define the path to the .env file.
$envFilePath = ".\.env"

if (Test-Path -Path $envFilePath) {
    Write-Host "Found .env file. Loading environment variables..."
    
    # Read the .env file line by line.
    Get-Content $envFilePath | ForEach-Object {
        # Trim leading/trailing whitespace from the line.
        $line = $_.Trim()

        # Process the line only if it's not empty and not a comment (starting with #).
        if ($line -and $line -notlike '#*') {
            
            # Split the line into a key and a value at the first '=' sign.
            $parts = $line.Split('=', 2)
            
            if ($parts.Length -eq 2) {
                $key = $parts[0].Trim()
                $value = $parts[1].Trim()

                # Remove quotes (single or double) that might surround the value.
                if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                    $value = $value.Substring(1, $value.Length - 2)
                }

                # Set the environment variable for the current PowerShell session using Set-Item.
                Set-Item -Path "Env:\$key" -Value $value
                Write-Host "  - Set variable: $key"
            }
        }
    }
    Write-Host "Environment variables loaded successfully." -ForegroundColor Green
} else {
    Write-Host ".env file not found. Skipping environment variable setup." -ForegroundColor Yellow
}

Write-Host "Project setup complete. Your environment is ready to use." -ForegroundColor Cyan

