# protoc 実行ファイルのパス
$protoc = "./proto/protoc-32.1-win64/bin/protoc.exe"

# proto ファイルのディレクトリ
$protoDir = "./proto/client-server"

# C++ 出力ディレクトリ
$cppOut = "./PortfolioGameClient/Game/Scripts/Proto"

# Rust 出力ディレクトリ
$rustOut = "./PortfolioGameServer/game/project/src/proto"

# 対象の proto ファイル
$protoFiles = @("types.proto", "math.proto")

# C++ 用コード生成
Write-Host "Running protoc for C++..."
& $protoc `
    --proto_path=$protoDir `
    --cpp_out=$cppOut `
    ($protoFiles | ForEach-Object { Join-Path $protoDir $_ })
if ($LASTEXITCODE -ne 0) {
	# C++コード生成に失敗
	Write-Host "protoc failed with exit code $LASTEXITCODE"
	exit $LASTEXITCODE
}
Write-Host "Completed."

# Rust 用コード生成
Write-Host "Running protoc for Rust..."
& $protoc `
    --proto_path=$protoDir `
    --rust_out=$rustOut `
    --rust_opt=experimental-codegen=enabled,kernel=upb `
    ($protoFiles | ForEach-Object { Join-Path $protoDir $_ })
if ($LASTEXITCODE -ne 0) {
	# Rustコード生成に失敗
	Write-Host "protoc failed with exit code $LASTEXITCODE"
	exit $LASTEXITCODE
}

Write-Host "Completed."

Write-Host "Completed protoc."

pause
