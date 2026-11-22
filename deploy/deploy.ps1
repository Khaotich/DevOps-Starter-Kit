param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("deploy", "rm", "redeploy")]
    [string]$Action
)

switch ($Action) {
    "deploy" {
        Write-Host "Starting deployment process (deploy)..." -ForegroundColor Green
        scp -r ../DevOps-Starter-Kit khaotic@192.168.0.245:~/DevOps-Starter-Kit
        ssh khaotic@192.168.0.245 "bash ~/DevOps-Starter-Kit/deploy/deploy.sh"
    }
    "rm" {
        Write-Host "Starting removal / cleanup process (rm)..." -ForegroundColor Red
        ssh khaotic@192.168.0.245 "bash ~/DevOps-Starter-Kit/deploy/rm.sh"
    }
    "redeploy" {
        Write-Host "Starting full redeployment process (redeploy)..." -ForegroundColor Yellow
        Write-Host "Step 1/3: Cleaning up existing deployment..." -ForegroundColor DarkYellow
        ssh khaotic@192.168.0.245 "bash ~/DevOps-Starter-Kit/deploy/rm.sh"
        
        Write-Host "Step 2/3: Uploading latest files via scp..." -ForegroundColor DarkYellow
        scp -r ../DevOps-Starter-Kit khaotic@192.168.0.245:~/DevOps-Starter-Kit
        
        Write-Host "Step 3/3: Running deployment script..." -ForegroundColor DarkYellow
        ssh khaotic@192.168.0.245 "bash ~/DevOps-Starter-Kit/deploy/deploy.sh"
        
        Write-Host "Redeployment completed successfully!" -ForegroundColor Green
    }
}