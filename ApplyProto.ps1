# 設定ファイルの読み込み
$configPath = "./portfolio-proto/protoc.config.json"
$config = Get-Content $configPath -Raw | ConvertFrom-Json

$protoc = $config.protoc
$protoDir = $config.protoDir

# 各ターゲットに対してコード生成
foreach ($target in $config.targets) {
	Write-Host "Running protoc for $($target.name)..."

	$files = $target.files | ForEach-Object { Join-Path $protoDir $_ }

	switch ($target.lang) {
		"cpp" {
			& $protoc `
				--proto_path=$protoDir `
				--cpp_out=$($target.out) `
				$files
		}
		"rust" {
			& $protoc `
				--proto_path=$protoDir `
				--rust_out=$($target.out) `
				--rust_opt=$($target.rustOpt) `
				$files
		}
		default {
			Write-Host "Unknown lang '$($target.lang)' for target '$($target.name)'"
			exit 1
		}
	}

	if ($LASTEXITCODE -ne 0) {
		Write-Host "protoc failed for '$($target.name)' with exit code $LASTEXITCODE"
		exit $LASTEXITCODE
	}

	Write-Host "Completed."
}

Write-Host "Completed protoc."

pause
