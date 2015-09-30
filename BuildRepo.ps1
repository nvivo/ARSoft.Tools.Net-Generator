Set-PSDebug -Trace 0

$workdir = "ARSoft.Tools.Net-final"
$origin = "https://github.com/nvivo/ARSoft.Tools.Net.git"

function clearFolder($path) {
    Get-ChildItem $path -Exclude .git | ForEach-Object {
        Remove-Item -Path $_.FullName -Force -Recurse
    }
}

if (Test-Path $workdir) {
    Remove-Item -Path $workdir -Force -Recurse
}

if (Test-Path $workdir) {
    echo "Could not remove $workdir - exiting..."
    Exit
}

git init $workdir

cd $workdir
git remote add origin $origin
cd ..

Get-ChildItem "." -Filter "ARSoft.Tools.Net*.zip" | ForEach-Object {
    

    $fullname = $_.FullName
    $version = $_.Basename.Substring(17, 5)
    $releasenotes = Get-Content "$fullname.txt" -Raw 
    $commit = "Release $version`n$releasenotes"

    clearFolder $workdir

    & 7za x $fullname -aou "-o$workdir"
	
    cd $workdir

    $lastwrite = (Get-ChildItem -Recurse -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime.ToString("u")

    $env:GIT_COMMITTER_DATE = $lastwrite

	cp ../README.finalrepo.md README.md
	
    git add -A
    git commit -m $commit --date=$lastwrite --author="AlexReinert <unknown@codeplex>"
    git tag $version
    
    cd ..
}
