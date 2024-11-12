url := "https://github.com/V-Sekai/world-editor/releases/download/latest.v-sekai-editor-181/v-sekai-world.zip"
output := "v-sekai-world.zip"
extract-dir := "export"
sha256 := "bcef4c5e55b84fdd7613d53f2bf00bad877eb6e49bf05b916774001cbb7bda80"
app-path := "{{extract-dir}}/godot_macos_editor_double.app"
executable-path := "{{app-path}}/Contents/MacOS/Godot"

all: editor-download editor-sign

editor-download: download verify extract create-gdignore

editor-sign: make-executable sign-app

clean:
    rm -rf {{extract-dir}}/*

download:
    mkdir -p "{{extract-dir}}"
    if [ -f "{{extract-dir}}/{{output}}" ]; then \
        echo "File already exists, skipping download."; \
    else \
        curl --location --output "{{extract-dir}}/{{output}}" "{{url}}"; \
    fi

verify:
    echo "Verifying SHA256..."
    if echo "{{sha256}}  {{extract-dir}}/{{output}}" | shasum -a 256 --check -; then \
        echo "SHA256 matches."; \
    else \
        echo "SHA256 does not match, exiting."; \
        exit 1; \
    fi

extract:
    7z x {{extract-dir}}/{{output}} -o{{extract-dir}}/temp -aoa
    rsync -a --remove-source-files {{extract-dir}}/temp/v-sekai-world/* {{extract-dir}}/
    rm -rf {{extract-dir}}/temp {{extract-dir}}/v-sekai-world
    find {{extract-dir}} -name "godot.web.editor.double.wasm32.dlink.*" ! -name "godot.web.editor.double.wasm32.dlink.zip" -exec rm -f {} +
    find {{extract-dir}} -name "godot.web.template_release.double.wasm32.dlink.*" ! -name "godot.web.template_release.double.wasm32.dlink.zip" -exec rm -f {} +
    find {{extract-dir}} -name "godot.web.template_debug.double.wasm32.dlink.*" ! -name "godot.web.template_debug.double.wasm32.dlink.zip" -exec rm -f {} +

create-gdignore:
    touch {{extract-dir}}/.gdignore

make-executable:
    #!/usr/bin/env bash
    chmod +x "{{extract-dir}}/godot.macos.editor.double.arm64"
    chmod +x "{{extract-dir}}/godot.macos.template_debug.double.arm64"
    chmod +x "{{extract-dir}}/godot.macos.template_release.double.arm64"
    chmod +x "{{extract-dir}}/godot_macos_editor_double.app/Contents/MacOS/Godot"

sign-app:
    #!/usr/bin/env bash
    codesign --deep --force --sign - "{{extract-dir}}/godot.macos.editor.double.arm64"
    codesign --deep --force --sign - "{{extract-dir}}/godot.macos.template_debug.double.arm64"
    codesign --deep --force --sign - "{{extract-dir}}/godot.macos.template_release.double.arm64"
    codesign --deep --force --sign - "{{extract-dir}}/godot_macos_editor_double.app/Contents/MacOS/Godot"
