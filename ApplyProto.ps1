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
& $protoc `
    --proto_path=$protoDir `
    --cpp_out=$cppOut `
    ($protoFiles | ForEach-Object { Join-Path $protoDir $_ })

# Rust 用コード生成
& $protoc `
    --proto_path=$protoDir `
    --rust_out=$rustOut `
    --rust_opt=experimental-codegen=enabled,kernel=upb `
    ($protoFiles | ForEach-Object { Join-Path $protoDir $_ })

pause
